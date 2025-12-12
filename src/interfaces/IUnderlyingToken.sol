// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

interface IUnderlyingToken is IERC20 {
  function mint(address, uint256) external;

  function burnFrom(address, uint256) external;
}
