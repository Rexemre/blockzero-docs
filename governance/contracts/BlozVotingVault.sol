// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Checkpoints} from "@openzeppelin/contracts/utils/structs/Checkpoints.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

/// @title Voting vault for wBLOZ: deposits with block-number checkpoints
/// @notice wBLOZ is a plain BEP-20 without vote checkpoints, so the governor can't read "who held how much at block N"
///         from the token. Holders deposit wBLOZ here; the vault keeps a history of every balance change. A vote then
///         uses the deposit at the proposal's snapshot block. Tokens deposited after the snapshot don't count, tokens
///         can't be counted twice (the same coins can't sit in two wallets at the snapshot block), and a flash loan
///         can't help (a deposit that is withdrawn in the same block never appears in a past checkpoint).
/// @dev    No owner, no pause, no upgrade: deposit and withdraw are always open. Fee-on-transfer tokens are
///         handled by crediting only what actually arrived.
contract BlozVotingVault is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Checkpoints for Checkpoints.Trace208;

    IERC20 public immutable token;

    mapping(address => Checkpoints.Trace208) private _deposits;
    Checkpoints.Trace208 private _total;

    event Deposited(address indexed account, uint256 amount, uint256 balance);
    event Withdrawn(address indexed account, uint256 amount, uint256 balance);

    error ZeroAmount();
    error NothingReceived();
    error InsufficientDeposit(uint256 have, uint256 want);
    error FutureBlock(uint256 blockNumber, uint256 current);

    constructor(IERC20 token_) {
        require(address(token_) != address(0), "vault: token");
        token = token_;
    }

    /// Deposit `amount` wBLOZ (approve first). Credits what actually arrived.
    function deposit(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        uint256 before = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount);
        uint256 got = token.balanceOf(address(this)) - before;
        if (got == 0) revert NothingReceived();
        uint208 bal = _deposits[msg.sender].latest() + SafeCast.toUint208(got);
        _deposits[msg.sender].push(SafeCast.toUint48(block.number), bal);
        _total.push(SafeCast.toUint48(block.number), _total.latest() + SafeCast.toUint208(got));
        emit Deposited(msg.sender, got, bal);
    }

    /// Withdraw `amount` of your deposit. Always possible.
    function withdraw(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        uint208 have = _deposits[msg.sender].latest();
        if (have < amount) revert InsufficientDeposit(have, amount);
        uint208 bal = have - SafeCast.toUint208(amount);
        _deposits[msg.sender].push(SafeCast.toUint48(block.number), bal);
        _total.push(SafeCast.toUint48(block.number), _total.latest() - SafeCast.toUint208(amount));
        token.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount, bal);
    }

    /// Current deposit of `account`.
    function deposited(address account) external view returns (uint256) {
        return _deposits[account].latest();
    }

    function totalDeposited() external view returns (uint256) {
        return _total.latest();
    }

    /// Deposit of `account` at the end of `blockNumber` (must be in the past).
    function getPastDeposit(address account, uint256 blockNumber) external view returns (uint256) {
        if (blockNumber >= block.number) revert FutureBlock(blockNumber, block.number);
        return _deposits[account].upperLookupRecent(SafeCast.toUint48(blockNumber));
    }

    function getPastTotal(uint256 blockNumber) external view returns (uint256) {
        if (blockNumber >= block.number) revert FutureBlock(blockNumber, block.number);
        return _total.upperLookupRecent(SafeCast.toUint48(blockNumber));
    }
}
