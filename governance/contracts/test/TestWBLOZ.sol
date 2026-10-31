// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Test wBLOZ for the BSC testnet (8 decimals like the real wrapped BLOZ). No value. Anyone can take
///        1 000 tokens per day from the faucet. Never deploy on mainnet.
contract TestWBLOZ is ERC20 {
    uint256 public constant FAUCET_AMOUNT = 1_000 * 1e8;
    mapping(address => uint256) public lastFaucet;

    constructor() ERC20("Test Wrapped BLOZ", "tWBLOZ") {
        _mint(msg.sender, 1_000_000 * 1e8);
    }

    function decimals() public pure override returns (uint8) {
        return 8;
    }

    function faucet() external {
        require(block.timestamp - lastFaucet[msg.sender] >= 1 days, "faucet: once a day");
        lastFaucet[msg.sender] = block.timestamp;
        _mint(msg.sender, FAUCET_AMOUNT);
    }
}

/// Re-entrancy attacker: a "recipient" that tries to call back into the governor while being paid.
interface IGovernorExecute {
    function execute(uint256 proposalId) external;
}

contract ReentrantRecipient {
    IGovernorExecute public gov;
    uint256 public target;
    uint256 public calls;
    bool public reentered;

    function arm(IGovernorExecute g, uint256 id) external {
        gov = g;
        target = id;
    }

    receive() external payable {
        calls += 1;
        if (calls == 1) {
            try gov.execute(target) {
                reentered = true;
            } catch {
                reentered = false;
            }
        }
    }
}

/// A recipient that refuses BNB (to test that a failed payment keeps the proposal executable until it expires).
contract RejectingRecipient {
    receive() external payable {
        revert("no thanks");
    }
}
