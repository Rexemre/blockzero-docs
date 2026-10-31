// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Group treasury of a Block Zero community group
/// @notice One minimal-proxy clone per group (created by the governor). It pays out wBLOZ and NOTHING else: the token
///         is fixed at creation, there is no native-coin path, no generic call and no token argument in `pay`. It pays
///         only when the governor tells it to, which the governor does only after a vote passed, the timelock ran out
///         and nothing is paused. Nobody else - not the founder, not the platform, not the deployer - can move anything
///         out. There is no owner, no upgrade and no rescue function: BNB or other tokens sent here by mistake stay
///         stuck on purpose (a rescue path would be an attack surface); `receive` is absent, so a plain BNB transfer
///         reverts. If a group wants to move to a new contract, it votes a wBLOZ payment to the new address.
contract BlozGroupTreasury is ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public governor;
    bytes32 public groupId;
    IERC20 public token; // wBLOZ, set once

    event Initialized(address indexed governor, bytes32 indexed groupId, address indexed token);
    event Paid(address indexed token, address indexed to, uint256 amount, uint256 indexed proposalId);

    error AlreadyInitialized();
    error NotGovernor();
    error ZeroAddress();

    /// Called once by the governor right after cloning. The implementation itself is initialized in its constructor
    /// with a dead governor so nobody can take it over.
    function initialize(address governor_, bytes32 groupId_, IERC20 token_) external {
        if (governor != address(0)) revert AlreadyInitialized();
        if (governor_ == address(0) || address(token_) == address(0)) revert ZeroAddress();
        governor = governor_;
        groupId = groupId_;
        token = token_;
        emit Initialized(governor_, groupId_, address(token_));
    }

    constructor() {
        governor = address(0xdead); // the implementation is never used directly
    }

    /// Pay `amount` wBLOZ to `to`. Only the governor, only after a passed vote. There is no way to name another asset.
    function pay(address to, uint256 amount, uint256 proposalId) external nonReentrant {
        if (msg.sender != governor) revert NotGovernor();
        if (to == address(0)) revert ZeroAddress();
        emit Paid(address(token), to, amount, proposalId);
        token.safeTransfer(to, amount);
    }

    /// wBLOZ held by this treasury.
    function balance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}
