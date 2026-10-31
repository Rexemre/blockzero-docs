// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Linear vote weight for the Block Zero community ("one BLOZ, one vote")
/// @notice weight = whole BLOZ (rounded down) of the LOWER of two balances: the one at the proposal's snapshot and the one
///         a holding period earlier. Coins that were borrowed, or bought less than the holding period before the vote,
///         therefore have no say. As an 18-decimal fixed-point number so tallies keep their old scale
///         (1 whole BLOZ = 1e18). Balances are in sats (1 BLOZ = 1e8 sats, the decimals of wBLOZ).
/// @dev    Mirrors bloz_bot/votecount.py (web counting) exactly.
library LinearWeight {
    uint256 internal constant ONE = 1e18;
    uint256 internal constant SATS_PER_BLOZ = 1e8;

    function weightOf(uint256 satsAtSnapshot, uint256 satsAtHold) internal pure returns (uint256) {
        uint256 low = satsAtSnapshot < satsAtHold ? satsAtSnapshot : satsAtHold;
        return (low / SATS_PER_BLOZ) * ONE;
    }
}
