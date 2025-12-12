// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library ErrorsLib {
  string internal constant CAP_EXCEEDED = "total assets after the deposit exceeds the cap";

  string internal constant INVALID_RATE = "rate cannot be greater than 100% in a day";
}
