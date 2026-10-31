// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {BlozGroupTreasury} from "./BlozGroupTreasury.sol";
import {LinearWeight} from "./LinearWeight.sol";
import {LogWeight} from "./LogWeight.sol";

interface IBlozVoterID {
    function memberSince(address wallet) external view returns (uint64);
}

interface IBlozVotingVault {
    function getPastDeposit(address account, uint256 blockNumber) external view returns (uint256);
    function token() external view returns (address);
}

/// @title Block Zero group governor: group treasuries + votes with two tallies
/// @notice One contract for all community groups. For every group it creates a treasury (minimal proxy clone) and
///         runs the group's votes. A vote can carry a payment (recipient, token, amount); when it passes, the
///         timelock has run out and nothing is paused, anyone can execute it and the governor tells the group's
///         treasury to pay. Payouts are wBLOZ only (the token of the voting vault, fixed at deploy): no BNB, no other token, no
///         arbitrary call. Nothing else can move money out of a treasury.
///
///         Two tallies, both have to say yes:
///           - people:  one wallet with a Block Zero voter ID (soulbound, one per verified person) = one vote;
///           - tokens:  "one BLOZ, one vote": the whole BLOZ (rounded down) of the voter's wBLOZ deposit in the voting
///                      vault, the lower of the deposit at the proposal's snapshot block and `holdBlocks` earlier
///                      (LinearWeight): deposits after the snapshot or held for less than the holding period don't count.
///         The proposer chooses the counting per proposal (countMode bits: 1 tokens linear, 4 tokens logarithmic
///         (LogWeight), 2 people; linear and logarithmic never together, so 1, 2, 3, 4 or 6). With two counts, a proposal
///         passes only if both tallies say yes (double majority); with one, only that tally decides.
///         Only wallets that were group members when the proposal was created can vote (Merkle root of the member
///         list, published by the community server with the proposal) and only with a voter ID older than the
///         snapshot. The payment recipient can't vote on their own payment.
///
///         Safety: minimum voting period, quorum of people, yes-share threshold, timelock before execution,
///         expiry, per-token maximum amount, emergency pause and veto by a guardian, checks-effects-interactions,
///         re-entrancy guard, no upgrade path (the admin role is meant to be held by a TimelockController).
/// @dev    Votes and proposals can be sent directly (gas paid by the voter) or as EIP-712 signatures relayed by the
///         community server (gas paid by the server, the signer stays the voter). Signatures carry a per-signer
///         nonce and a deadline.
contract BlozGroupGovernor is AccessControl, Pausable, ReentrancyGuard, EIP712, Nonces {
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");
    bytes32 public constant REGISTRAR_ROLE = keccak256("REGISTRAR_ROLE");

    bytes32 public constant BALLOT_TYPEHASH =
        keccak256("Ballot(uint256 proposalId,uint8 support,address voter,uint256 nonce,uint256 deadline)");
    bytes32 public constant PROPOSAL_TYPEHASH = keccak256(
        "Proposal(bytes32 groupId,bytes32 membersRoot,uint32 eligibleCount,address recipient,address token,uint256 amount,uint32 period,uint8 countMode,bytes32 descriptionHash,address proposer,uint256 nonce,uint256 deadline)"
    );

    uint8 public constant AGAINST = 0;
    uint8 public constant FOR = 1;
    uint8 public constant ABSTAIN = 2;
    uint16 public constant BPS = 10_000;
    uint8 public constant MODE_TOKENS = 1; // "one BLOZ, one vote"
    uint8 public constant MODE_PEOPLE = 2; // "one person, one vote"
    uint8 public constant MODE_LOG = 4; // balance tally logarithmic: log2(1 + BLOZ / 10) instead of whole BLOZ
    uint8 public constant MODE_BALANCE = MODE_TOKENS | MODE_LOG; // either of the two balance tallies

    enum State {
        Pending, // created, voting not open yet
        Active, // voting
        Defeated, // ended, not passed
        Succeeded, // passed; payment proposals: waiting for the timelock
        Executable, // payment passed, timelock over, not expired
        Executed,
        Expired, // payment passed but nobody executed it in time
        Cancelled, // by proposer / group owner / registrar
        Vetoed // by the guardian
    }

    struct Config {
        uint32 votingDelay; // seconds between creation and start of voting
        uint32 minPeriodPlain; // minimum voting period without payment
        uint32 minPeriodFinance; // minimum voting period with payment
        uint32 maxPeriod;
        uint32 timelockFinance; // seconds between end of voting and earliest execution
        uint32 gracePeriod; // seconds after the timelock in which a payment can be executed
        uint16 yesBpsPlain; // required share of yes among yes+no (e.g. 5000 = more than half is enough)
        uint16 yesBpsFinance; // e.g. 6000
        uint16 minQuorumPeople; // smallest quorum a group may set
        uint16 maxOpenPerGroup; // open proposals per group
    }

    struct Group {
        address owner;
        address treasury;
        uint64 createdAt;
        uint16 quorumPeople;
        uint16 open; // proposals not yet finalized
        bool exists;
    }

    struct ProposalParams {
        bytes32 groupId;
        bytes32 membersRoot;
        uint32 eligibleCount;
        address recipient; // 0 = no payment
        address token; // 0 = BNB
        uint256 amount; // 0 = no payment
        uint32 period; // voting period in seconds
        uint8 countMode; // bits: 1 tokens linear, 2 people, 4 tokens logarithmic (not 1+4)
        string description;
    }

    struct Proposal {
        bytes32 groupId;
        bytes32 membersRoot;
        bytes32 descriptionHash;
        address proposer;
        address recipient;
        address token;
        uint256 amount;
        uint48 snapshotBlock;
        uint48 snapshotTime;
        uint48 start;
        uint48 end;
        uint48 eta; // earliest execution (payment) / = end (plain)
        uint32 eligibleCount;
        uint16 quorumPeople;
        uint16 yesBps;
        uint32 peopleFor;
        uint32 peopleAgainst;
        uint32 peopleAbstain;
        uint256 weightFor;
        uint256 weightAgainst;
        uint256 weightAbstain;
        bool executed;
        bool cancelled;
        bool vetoed;
        bool finalized; // the group's open counter was released
        uint8 countMode; // appended last: older readers keep their field positions
        uint48 holdBlock; // balance must also have been held at this block (snapshot - holdBlocks)
    }

    IBlozVoterID public immutable voterId;
    IBlozVotingVault public immutable vault;
    address public immutable treasuryImplementation;
    address public immutable WBLOZ; // the only asset a treasury can pay out (= vault.token())

    Config public config;
    uint32 public holdBlocks = 201_600; // holding period for the token tally: 7 days at 3 s per BSC block
    mapping(address => uint256) public maxAmount; // only WBLOZ is ever non-zero; 0 = payouts switched off
    mapping(bytes32 => Group) public groups;
    mapping(bytes32 => mapping(address => bool)) public isProposer;
    uint256 public proposalCount;
    mapping(uint256 => Proposal) private _proposals;
    mapping(uint256 => mapping(address => uint8)) private _voted; // 0 = not voted, else support + 1

    event ConfigChanged(Config config);
    event HoldBlocksChanged(uint32 holdBlocks);
    event MaxAmountChanged(address indexed token, uint256 amount);
    event GroupCreated(bytes32 indexed groupId, address indexed owner, address treasury);
    event GroupOwnerChanged(bytes32 indexed groupId, address indexed owner);
    event GroupQuorumChanged(bytes32 indexed groupId, uint16 quorumPeople);
    event ProposerChanged(bytes32 indexed groupId, address indexed account, bool allowed);
    event ProposalCreated(
        uint256 indexed proposalId,
        bytes32 indexed groupId,
        address indexed proposer,
        bytes32 membersRoot,
        uint32 eligibleCount,
        string description
    );
    event ProposalPayment(uint256 indexed proposalId, address indexed recipient, address indexed token, uint256 amount);
    event ProposalTiming(uint256 indexed proposalId, uint48 snapshotBlock, uint48 start, uint48 end, uint48 eta);
    event VoteCast(uint256 indexed proposalId, address indexed voter, uint8 support, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId, address indexed treasury, address token, address to, uint256 amount);
    event ProposalCancelled(uint256 indexed proposalId, address indexed by);
    event ProposalVetoed(uint256 indexed proposalId, address indexed by, string reason);
    event ProposalFinalized(uint256 indexed proposalId, State state);

    error UnknownGroup();
    error GroupExists();
    error NotGroupOwner();
    error NotProposer();
    error BadConfig();
    error BadQuorum();
    error BadPeriod();
    error BadCountMode();
    error NoWeight();
    error BadRecipient();
    error TokenNotAllowed(address token);
    error AmountTooHigh(uint256 amount, uint256 cap);
    error NoMembers();
    error TooManyOpen();
    error UnknownProposal();
    error WrongState(State actual);
    error AlreadyVoted();
    error BadSupport();
    error NotMember();
    error NoVoterId();
    error RecipientCantVote();
    error SignatureExpired();
    error BadSignature();
    error NotAllowed();

    constructor(
        address admin,
        address guardian,
        address registrar,
        IBlozVoterID voterId_,
        IBlozVotingVault vault_,
        Config memory config_
    ) EIP712("BlozGroupGovernor", "1") {
        require(admin != address(0) && address(voterId_) != address(0) && address(vault_) != address(0), "governor: zero");
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        if (guardian != address(0)) _grantRole(GUARDIAN_ROLE, guardian);
        if (registrar != address(0)) _grantRole(REGISTRAR_ROLE, registrar);
        voterId = voterId_;
        vault = vault_;
        WBLOZ = vault_.token();
        require(WBLOZ != address(0), "governor: token");
        treasuryImplementation = address(new BlozGroupTreasury());
        _setConfig(config_);
    }

    // --- admin (meant to be a TimelockController) --------------------------------------------------------------------
    function setConfig(Config calldata c) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setConfig(c);
    }

    function _setConfig(Config memory c) private {
        if (
            c.maxPeriod == 0 || c.minPeriodPlain > c.maxPeriod || c.minPeriodFinance > c.maxPeriod
                || c.yesBpsPlain < BPS / 2 || c.yesBpsPlain > BPS || c.yesBpsFinance < BPS / 2 || c.yesBpsFinance > BPS
                || c.minQuorumPeople == 0 || c.maxOpenPerGroup == 0 || c.gracePeriod == 0 || c.votingDelay > 7 days
                || c.maxPeriod > 90 days || c.timelockFinance > 30 days
        ) revert BadConfig();
        config = c;
        emit ConfigChanged(c);
    }

    /// Holding period of the token tally in blocks (at most ~30 days).
    function setHoldBlocks(uint32 blocks) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (blocks > 864_000) revert BadConfig();
        holdBlocks = blocks;
        emit HoldBlocksChanged(blocks);
    }

    /// Raise or set a per-token cap (0 = token not allowed). Only the admin (timelock) may raise.
    function setMaxAmount(address token, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (token != WBLOZ) revert TokenNotAllowed(token);
        maxAmount[token] = amount;
        emit MaxAmountChanged(token, amount);
    }

    /// Emergency: the guardian may only LOWER a cap (or switch a token off) without waiting for the timelock.
    function lowerMaxAmount(address token, uint256 amount) external onlyRole(GUARDIAN_ROLE) {
        if (token != WBLOZ) revert TokenNotAllowed(token);
        if (amount >= maxAmount[token]) revert NotAllowed();
        maxAmount[token] = amount;
        emit MaxAmountChanged(token, amount);
    }

    /// Emergency brake: stops new groups, proposals, votes and executions. Guardian or admin.
    function pause() external {
        if (!hasRole(GUARDIAN_ROLE, msg.sender) && !hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert NotAllowed();
        _pause();
    }

    /// Only the admin (timelock) releases the brake: deliberate, delayed, visible.
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    // --- groups ----------------------------------------------------------------------------------------------------------
    /// Create a group and its treasury. The registrar (community server) attests which wallet founded the group.
    function createGroup(bytes32 groupId, address owner, uint16 quorumPeople)
        external
        onlyRole(REGISTRAR_ROLE)
        whenNotPaused
        returns (address treasury)
    {
        if (groupId == bytes32(0) || owner == address(0)) revert BadRecipient();
        if (groups[groupId].exists) revert GroupExists();
        if (quorumPeople < config.minQuorumPeople) revert BadQuorum();
        treasury = Clones.cloneDeterministic(treasuryImplementation, groupId);
        BlozGroupTreasury(treasury).initialize(address(this), groupId, IERC20(WBLOZ));
        groups[groupId] = Group({
            owner: owner,
            treasury: treasury,
            createdAt: uint64(block.timestamp),
            quorumPeople: quorumPeople,
            open: 0,
            exists: true
        });
        emit GroupCreated(groupId, owner, treasury);
    }

    /// Address a group's treasury will have (before or after creation).
    function predictTreasury(bytes32 groupId) external view returns (address) {
        return Clones.predictDeterministicAddress(treasuryImplementation, groupId, address(this));
    }

    function _groupManager(bytes32 groupId) private view returns (Group storage g) {
        g = groups[groupId];
        if (!g.exists) revert UnknownGroup();
        if (msg.sender != g.owner && !hasRole(REGISTRAR_ROLE, msg.sender)) revert NotGroupOwner();
    }

    function setGroupOwner(bytes32 groupId, address owner) external {
        Group storage g = _groupManager(groupId);
        if (owner == address(0)) revert BadRecipient();
        g.owner = owner;
        emit GroupOwnerChanged(groupId, owner);
    }

    function setGroupQuorum(bytes32 groupId, uint16 quorumPeople) external {
        Group storage g = _groupManager(groupId);
        if (quorumPeople < config.minQuorumPeople) revert BadQuorum();
        g.quorumPeople = quorumPeople;
        emit GroupQuorumChanged(groupId, quorumPeople);
    }

    /// Who besides the owner may create proposals (the server mirrors the group's admins here).
    function setProposer(bytes32 groupId, address account, bool allowed) external {
        _groupManager(groupId);
        isProposer[groupId][account] = allowed;
        emit ProposerChanged(groupId, account, allowed);
    }

    // --- proposals -------------------------------------------------------------------------------------------------------
    function propose(ProposalParams calldata p) external whenNotPaused returns (uint256) {
        return _propose(p, msg.sender);
    }

    /// Relayed proposal: `proposer` signed the EIP-712 Proposal struct; anyone may submit it and pay the gas.
    function proposeBySig(ProposalParams calldata p, address proposer, uint256 deadline, bytes calldata signature)
        external
        whenNotPaused
        returns (uint256)
    {
        if (block.timestamp > deadline) revert SignatureExpired();
        bytes32 structHash = _proposalStructHash(p, proposer, _useNonce(proposer), deadline);
        if (ECDSA.recover(_hashTypedDataV4(structHash), signature) != proposer) revert BadSignature();
        return _propose(p, proposer);
    }

    function _propose(ProposalParams calldata p, address proposer) private returns (uint256 id) {
        Group storage g = groups[p.groupId];
        if (!g.exists) revert UnknownGroup();
        if (proposer != g.owner && !isProposer[p.groupId][proposer]) revert NotProposer();
        if (g.open >= config.maxOpenPerGroup) revert TooManyOpen();
        if (p.countMode == 0 || p.countMode > MODE_BALANCE + MODE_PEOPLE || p.countMode & MODE_BALANCE == MODE_BALANCE) revert BadCountMode();
        if (p.membersRoot == bytes32(0) || p.eligibleCount < g.quorumPeople) revert NoMembers();
        bool finance = p.amount != 0 || p.recipient != address(0);
        Config memory c = config;
        if (finance) {
            if (p.amount == 0 || p.recipient == address(0) || p.recipient == g.treasury || p.recipient == address(this)) {
                revert BadRecipient();
            }
            if (p.token != WBLOZ) revert TokenNotAllowed(p.token); // wBLOZ only: no BNB (0), no other token
            uint256 cap = maxAmount[p.token];
            if (cap == 0) revert TokenNotAllowed(p.token);
            if (p.amount > cap) revert AmountTooHigh(p.amount, cap);
            if (p.period < c.minPeriodFinance) revert BadPeriod();
        } else if (p.period < c.minPeriodPlain) {
            revert BadPeriod();
        }
        if (p.period > c.maxPeriod) revert BadPeriod();

        id = ++proposalCount;
        Proposal storage pr = _proposals[id];
        pr.groupId = p.groupId;
        pr.membersRoot = p.membersRoot;
        pr.descriptionHash = keccak256(bytes(p.description));
        pr.proposer = proposer;
        pr.recipient = finance ? p.recipient : address(0);
        pr.token = finance ? p.token : address(0);
        pr.amount = finance ? p.amount : 0;
        pr.snapshotBlock = uint48(block.number);
        pr.countMode = p.countMode;
        pr.holdBlock = block.number > holdBlocks ? uint48(block.number - holdBlocks) : 0;
        pr.snapshotTime = uint48(block.timestamp);
        pr.start = uint48(block.timestamp + c.votingDelay);
        pr.end = uint48(block.timestamp + c.votingDelay + p.period);
        pr.eta = finance ? uint48(pr.end + c.timelockFinance) : pr.end;
        pr.eligibleCount = p.eligibleCount;
        pr.quorumPeople = g.quorumPeople;
        pr.yesBps = finance ? c.yesBpsFinance : c.yesBpsPlain;
        g.open += 1;
        emit ProposalCreated(id, p.groupId, proposer, p.membersRoot, p.eligibleCount, p.description);
        emit ProposalTiming(id, pr.snapshotBlock, pr.start, pr.end, pr.eta);
        if (finance) emit ProposalPayment(id, pr.recipient, pr.token, pr.amount);
    }

    // --- voting ----------------------------------------------------------------------------------------------------------
    function castVote(uint256 proposalId, uint8 support, bytes32[] calldata proof) external whenNotPaused {
        _castVote(proposalId, msg.sender, support, proof);
    }

    /// Relayed ballot: `voter` signed the EIP-712 Ballot struct (free in the wallet); anyone may submit it.
    function castVoteBySig(
        uint256 proposalId,
        uint8 support,
        bytes32[] calldata proof,
        address voter,
        uint256 deadline,
        bytes calldata signature
    ) external whenNotPaused {
        if (block.timestamp > deadline) revert SignatureExpired();
        bytes32 structHash = keccak256(abi.encode(BALLOT_TYPEHASH, proposalId, support, voter, _useNonce(voter), deadline));
        if (ECDSA.recover(_hashTypedDataV4(structHash), signature) != voter) revert BadSignature();
        _castVote(proposalId, voter, support, proof);
    }

    function _castVote(uint256 proposalId, address voter, uint8 support, bytes32[] calldata proof) private {
        Proposal storage pr = _proposal(proposalId);
        State s = _state(pr);
        if (s != State.Active) revert WrongState(s);
        if (support > ABSTAIN) revert BadSupport();
        if (_voted[proposalId][voter] != 0) revert AlreadyVoted();
        if (voter == pr.recipient) revert RecipientCantVote();
        if (!MerkleProof.verifyCalldata(proof, pr.membersRoot, leaf(voter))) revert NotMember();
        // people tally: only wallets with a voter ID older than the snapshot are persons; tokens-only votes need none
        uint64 since = voterId.memberSince(voter);
        bool isPerson = since != 0 && since <= pr.snapshotTime;
        if (pr.countMode == MODE_PEOPLE && !isPerson) revert NoVoterId();
        // token tally: whole BLOZ, the lower of the deposit at the snapshot and one holding period earlier
        uint256 weight = 0;
        if (pr.countMode & MODE_BALANCE != 0) {
            uint256 atSnapshot = vault.getPastDeposit(voter, pr.snapshotBlock);
            uint256 atHold = vault.getPastDeposit(voter, pr.holdBlock);
            weight = pr.countMode & MODE_LOG != 0
                ? LogWeight.weightOf(atSnapshot < atHold ? atSnapshot : atHold)
                : LinearWeight.weightOf(atSnapshot, atHold);
            if (pr.countMode & MODE_PEOPLE == 0 && weight == 0) revert NoWeight();
        }
        _voted[proposalId][voter] = support + 1;
        // "people" counters count persons; in a tokens-only vote they count voting wallets (for the quorum)
        if (pr.countMode & MODE_PEOPLE == 0 || isPerson) {
            if (support == FOR) pr.peopleFor += 1;
            else if (support == AGAINST) pr.peopleAgainst += 1;
            else pr.peopleAbstain += 1;
        }
        if (support == FOR) pr.weightFor += weight;
        else if (support == AGAINST) pr.weightAgainst += weight;
        else pr.weightAbstain += weight;
        emit VoteCast(proposalId, voter, support, weight);
    }

    /// Merkle leaf of a member wallet (OpenZeppelin standard: double keccak of the ABI-encoded address).
    function leaf(address member) public pure returns (bytes32) {
        return keccak256(bytes.concat(keccak256(abi.encode(member))));
    }

    // --- execution / lifecycle -----------------------------------------------------------------------------------------
    /// Pay out a passed payment proposal after the timelock. Anyone may call (the server does it automatically).
    function execute(uint256 proposalId) external nonReentrant whenNotPaused {
        Proposal storage pr = _proposal(proposalId);
        State s = _state(pr);
        if (s != State.Executable) revert WrongState(s);
        uint256 cap = maxAmount[pr.token]; // caps may have been lowered since (emergency): re-check
        if (cap == 0) revert TokenNotAllowed(pr.token);
        if (pr.amount > cap) revert AmountTooHigh(pr.amount, cap);
        pr.executed = true; // effects before the interaction
        _release(proposalId, pr, State.Executed);
        address treasury = groups[pr.groupId].treasury;
        emit ProposalExecuted(proposalId, treasury, pr.token, pr.recipient, pr.amount);
        BlozGroupTreasury(treasury).pay(pr.recipient, pr.amount, proposalId);
    }

    /// Proposer, group owner or registrar may cancel before execution.
    function cancel(uint256 proposalId) external {
        Proposal storage pr = _proposal(proposalId);
        State s = _state(pr);
        if (s == State.Executed || s == State.Cancelled || s == State.Vetoed || s == State.Expired || s == State.Defeated) {
            revert WrongState(s);
        }
        Group storage g = groups[pr.groupId];
        if (msg.sender != pr.proposer && msg.sender != g.owner && !hasRole(REGISTRAR_ROLE, msg.sender)) revert NotAllowed();
        pr.cancelled = true;
        _release(proposalId, pr, State.Cancelled);
        emit ProposalCancelled(proposalId, msg.sender);
    }

    /// Guardian veto (objection period): stops a proposal that is not executed yet. Logged with a reason.
    function veto(uint256 proposalId, string calldata reason) external onlyRole(GUARDIAN_ROLE) {
        Proposal storage pr = _proposal(proposalId);
        State s = _state(pr);
        if (s == State.Executed || s == State.Cancelled || s == State.Vetoed) revert WrongState(s);
        pr.vetoed = true;
        _release(proposalId, pr, State.Vetoed);
        emit ProposalVetoed(proposalId, msg.sender, reason);
    }

    /// Release the group's open-proposal slot of a proposal that ended without execution (Defeated, Expired, or a
    /// plain proposal that Succeeded). Anyone may call.
    function finalize(uint256 proposalId) external {
        Proposal storage pr = _proposal(proposalId);
        State s = _state(pr);
        if (s == State.Defeated || s == State.Expired || (s == State.Succeeded && pr.amount == 0)) {
            _release(proposalId, pr, s);
        } else {
            revert WrongState(s);
        }
    }

    function _release(uint256 proposalId, Proposal storage pr, State s) private {
        if (pr.finalized) return;
        pr.finalized = true;
        Group storage g = groups[pr.groupId];
        if (g.open > 0) g.open -= 1;
        emit ProposalFinalized(proposalId, s);
    }

    // --- views -------------------------------------------------------------------------------------------------------------
    function _proposal(uint256 id) private view returns (Proposal storage pr) {
        pr = _proposals[id];
        if (pr.start == 0) revert UnknownProposal();
    }

    function proposal(uint256 id) external view returns (Proposal memory) {
        return _proposal(id);
    }

    function state(uint256 id) external view returns (State) {
        return _state(_proposal(id));
    }

    function hasVoted(uint256 id, address voter) external view returns (bool) {
        return _voted[id][voter] != 0;
    }

    function voteOf(uint256 id, address voter) external view returns (bool voted, uint8 support) {
        uint8 v = _voted[id][voter];
        return (v != 0, v == 0 ? 0 : v - 1);
    }

    /// The two tallies and whether each of them says yes right now.
    function tallies(uint256 id)
        external
        view
        returns (
            uint32 peopleFor,
            uint32 peopleAgainst,
            uint32 peopleAbstain,
            uint256 weightFor,
            uint256 weightAgainst,
            uint256 weightAbstain,
            bool peopleYes,
            bool tokensYes,
            bool quorumReached
        )
    {
        Proposal storage pr = _proposal(id);
        (peopleYes, tokensYes, quorumReached) = _outcome(pr);
        return (
            pr.peopleFor,
            pr.peopleAgainst,
            pr.peopleAbstain,
            pr.weightFor,
            pr.weightAgainst,
            pr.weightAbstain,
            peopleYes,
            tokensYes,
            quorumReached
        );
    }

    function _outcome(Proposal storage pr) private view returns (bool peopleYes, bool tokensYes, bool quorumReached) {
        uint256 voters = uint256(pr.peopleFor) + pr.peopleAgainst + pr.peopleAbstain;
        quorumReached = voters >= pr.quorumPeople;
        uint256 pf = pr.peopleFor;
        uint256 pa = pr.peopleAgainst;
        peopleYes = pf > pa && pf * BPS >= (pf + pa) * pr.yesBps;
        uint256 wf = pr.weightFor;
        uint256 wa = pr.weightAgainst;
        tokensYes = wf > wa && wf * BPS >= (wf + wa) * pr.yesBps;
    }

    /// Passed = quorum + yes in every tally the proposer chose (people, tokens or both = double majority). If the
    /// two tallies disagree, the proposal is rejected and a re-worded one can be submitted.
    function _passed(Proposal storage pr) private view returns (bool) {
        (bool peopleYes, bool tokensYes, bool quorumReached) = _outcome(pr);
        if (!quorumReached) return false;
        if (pr.countMode & MODE_PEOPLE != 0 && !peopleYes) return false;
        if (pr.countMode & MODE_BALANCE != 0 && !tokensYes) return false;
        return true;
    }

    function _state(Proposal storage pr) private view returns (State) {
        if (pr.vetoed) return State.Vetoed;
        if (pr.cancelled) return State.Cancelled;
        if (pr.executed) return State.Executed;
        uint256 t = block.timestamp;
        if (t < pr.start) return State.Pending;
        if (t <= pr.end) return State.Active;
        if (!_passed(pr)) return State.Defeated;
        if (pr.amount == 0) return State.Succeeded;
        if (t < pr.eta) return State.Succeeded;
        if (t <= uint256(pr.eta) + config.gracePeriod) return State.Executable;
        return State.Expired;
    }

    /// EIP-712 digests, so wallets and the server can check what they sign.
    function ballotDigest(uint256 proposalId, uint8 support, address voter, uint256 nonce, uint256 deadline)
        external
        view
        returns (bytes32)
    {
        return _hashTypedDataV4(keccak256(abi.encode(BALLOT_TYPEHASH, proposalId, support, voter, nonce, deadline)));
    }

    function proposalDigest(ProposalParams calldata p, address proposer, uint256 nonce, uint256 deadline)
        external
        view
        returns (bytes32)
    {
        return _hashTypedDataV4(_proposalStructHash(p, proposer, nonce, deadline));
    }

    /// EIP-712 struct hash of a Proposal. Two abi.encode chunks packed together equal one abi.encode of all
    /// (static) fields; split only to keep the compiler's stack small.
    function _proposalStructHash(ProposalParams calldata p, address proposer, uint256 nonce, uint256 deadline)
        private
        pure
        returns (bytes32)
    {
        bytes memory head = abi.encode(PROPOSAL_TYPEHASH, p.groupId, p.membersRoot, p.eligibleCount, p.recipient, p.token);
        bytes memory tail = abi.encode(p.amount, p.period, p.countMode, keccak256(bytes(p.description)), proposer, nonce, deadline);
        return keccak256(bytes.concat(head, tail));
    }

    function domainSeparator() external view returns (bytes32) {
        return _domainSeparatorV4();
    }
}
