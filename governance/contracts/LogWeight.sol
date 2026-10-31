// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Logarithmic vote weight for the Block Zero community
/// @notice weight = log2(1 + balance / 10 BLOZ), as an 18-decimal fixed-point number.
///         10 BLOZ -> 1.0, 1 000 BLOZ -> 6.66, 1 000 000 BLOZ -> 16.6. A whale with a million coins has the
///         weight of about 17 small holders instead of 100 000. Balances are in sats (1 BLOZ = 1e8 sats, the
///         decimals of wBLOZ).
/// @dev    Pure integer math, no external library. log2 of an unsigned 60.18 fixed-point number x >= 1e18:
///         integer part by bit length, fractional part by repeated squaring (64 binary digits). Deterministic and
///         bounded: at most ~70 loop iterations, no overflow for any balance below 2^128 sats.
library LogWeight {
    uint256 internal constant ONE = 1e18;
    uint256 internal constant TEN_BLOZ_SATS = 10 * 1e8;

    /// @param sats balance in sats (8 decimals)
    /// @return weight log2(1 + sats / 10 BLOZ) scaled by 1e18 (0 for a zero balance)
    function weightOf(uint256 sats) internal pure returns (uint256 weight) {
        if (sats == 0) return 0;
        // x = (10 BLOZ + sats) / 10 BLOZ as 60.18 fixed point = 1e18 + sats * 1e18 / 1e9
        uint256 x = ONE + (sats * ONE) / TEN_BLOZ_SATS;
        return log2(x);
    }

    /// @notice log2(x) for x >= 1e18 (60.18 fixed point in, 60.18 fixed point out). Reverts below 1e18.
    function log2(uint256 x) internal pure returns (uint256 result) {
        require(x >= ONE, "LogWeight: x < 1");
        // integer part: largest n with x >= 2^n * 1e18
        uint256 n = 0;
        uint256 y = x;
        while (y >= 2 * ONE) {
            y >>= 1;
            n += 1;
        }
        result = n * ONE;
        // y is now in [1e18, 2e18): fractional bits by squaring
        if (y == ONE) return result;
        uint256 delta = ONE;
        for (uint256 i = 0; i < 64; i++) {
            delta >>= 1;
            if (delta == 0) break;
            y = (y * y) / ONE;
            if (y >= 2 * ONE) {
                result += delta;
                y >>= 1;
            }
        }
    }
}
