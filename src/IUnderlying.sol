// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IUnderlying {
  function mint(address, uint256) external;

  function burnFrom(address, uint256) external;
}
