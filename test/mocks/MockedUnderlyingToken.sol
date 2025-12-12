// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockedUnderlyingToken is ERC20 {
  constructor() ERC20("Mock Stablecoin", "MST") {}

  function mint(address to, uint256 amount) external {
    _mint(to, amount);
  }

  function burnFrom(address from, uint256 amount) external {
    _burn(from, amount);
  }
}
