// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// ERC-5192 (Minimal Soulbound NFTs)
interface IERC5192 {
    event Locked(uint256 tokenId);
    event Unlocked(uint256 tokenId);

    function locked(uint256 tokenId) external view returns (bool);
}

/// @title Block Zero voter ID: one soulbound token per verified person
/// @notice The community server checks a person off-chain (wallet login, a Discord account that is old enough, a
///         native BLOZ address proven by signature) and then mints exactly one voter ID to that person's wallet.
///         The governor counts a "one person, one vote" ballot only from wallets that hold a voter ID that is older
///         than the vote's snapshot. The token can't be transferred, approved or sold (ERC-5192 locked).
/// @dev    `personRef` is an opaque hash the server derives from a secret salt and the person's identity. It is
///         stored so that the contract itself refuses a second ID for the same person (another wallet) while the
///         first one exists. No personal data goes on-chain. A revoked (burned) ID frees the person reference, so a
///         person who lost a wallet can be re-issued an ID on a new wallet (with a fresh `memberSince`).
contract BlozVoterID is ERC721, AccessControl, IERC5192 {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public nextTokenId = 1;
    string private _baseTokenURI;

    /// wallet -> timestamp of its current voter ID (0 = none)
    mapping(address => uint64) public memberSince;
    /// wallet -> token id of its current voter ID (0 = none)
    mapping(address => uint256) public tokenOf;
    /// token id -> person reference (opaque hash)
    mapping(uint256 => bytes32) public personOf;
    /// person reference -> wallet that currently holds the ID for this person (0 = none)
    mapping(bytes32 => address) public walletOfPerson;

    event VoterIdMinted(uint256 indexed tokenId, address indexed to, bytes32 indexed personRef);
    event VoterIdRevoked(uint256 indexed tokenId, address indexed from, bytes32 indexed personRef, string reason);
    event BaseURIChanged(string baseURI);

    error Soulbound();
    error AlreadyHasId(address wallet);
    error PersonAlreadyHasId(bytes32 personRef, address wallet);
    error NotHolder();
    error ZeroAddress();
    error ZeroPersonRef();

    constructor(address admin, address minter, string memory baseURI_) ERC721("Block Zero Voter ID", "BZVOTER") {
        if (admin == address(0)) revert ZeroAddress();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        if (minter != address(0)) _grantRole(MINTER_ROLE, minter);
        _baseTokenURI = baseURI_;
    }

    // --- issuing -----------------------------------------------------------------------------------------------------
    /// Mint the voter ID of `personRef` to `to`. One per wallet, one per person.
    function mint(address to, bytes32 personRef) external onlyRole(MINTER_ROLE) returns (uint256 tokenId) {
        if (to == address(0)) revert ZeroAddress();
        if (personRef == bytes32(0)) revert ZeroPersonRef();
        if (tokenOf[to] != 0) revert AlreadyHasId(to);
        if (walletOfPerson[personRef] != address(0)) revert PersonAlreadyHasId(personRef, walletOfPerson[personRef]);
        tokenId = nextTokenId++;
        tokenOf[to] = tokenId;
        personOf[tokenId] = personRef;
        walletOfPerson[personRef] = to;
        memberSince[to] = uint64(block.timestamp);
        _mint(to, tokenId); // plain mint: no receiver callback, no re-entrancy
        emit Locked(tokenId);
        emit VoterIdMinted(tokenId, to, personRef);
    }

    /// Withdraw a voter ID (verification turned out wrong, abuse, person asked to move wallets).
    function revoke(uint256 tokenId, string calldata reason) external onlyRole(MINTER_ROLE) {
        address holder = ownerOf(tokenId);
        _clear(holder, tokenId);
        emit VoterIdRevoked(tokenId, holder, personOf[tokenId], reason);
        delete personOf[tokenId];
        _burn(tokenId);
    }

    /// The holder can always drop their own ID.
    function burn(uint256 tokenId) external {
        if (ownerOf(tokenId) != msg.sender) revert NotHolder();
        _clear(msg.sender, tokenId);
        emit VoterIdRevoked(tokenId, msg.sender, personOf[tokenId], "holder");
        delete personOf[tokenId];
        _burn(tokenId);
    }

    function _clear(address holder, uint256 tokenId) private {
        delete tokenOf[holder];
        delete memberSince[holder];
        delete walletOfPerson[personOf[tokenId]];
    }

    // --- views ---------------------------------------------------------------------------------------------------------
    /// True if `wallet` held a voter ID at `timestamp` (i.e. its current ID is at least that old).
    function verifiedAt(address wallet, uint256 timestamp) external view returns (bool) {
        uint64 since = memberSince[wallet];
        return since != 0 && since <= timestamp;
    }

    function locked(uint256 tokenId) external view returns (bool) {
        _requireOwned(tokenId);
        return true;
    }

    // --- soulbound ---------------------------------------------------------------------------------------------------------
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) revert Soulbound(); // transfers never; mint and burn yes
        return super._update(to, tokenId, auth);
    }

    function approve(address, uint256) public pure override {
        revert Soulbound();
    }

    function setApprovalForAll(address, bool) public pure override {
        revert Soulbound();
    }

    // --- metadata ------------------------------------------------------------------------------------------------------------
    function setBaseURI(string calldata baseURI_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseTokenURI = baseURI_;
        emit BaseURIChanged(baseURI_);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return interfaceId == type(IERC5192).interfaceId || super.supportsInterface(interfaceId);
    }
}
