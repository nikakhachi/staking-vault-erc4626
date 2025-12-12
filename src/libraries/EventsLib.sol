// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library EventsLib {
  event RateUpdate(uint256 indexed previousRate, uint256 indexed newRate, uint256 timestamp);

  event CapUpdate(uint256 indexed previousCap, uint256 indexed newCap, uint256 timestamp);
}
