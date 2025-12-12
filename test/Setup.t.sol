// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {StakingVault} from "../src/StakingVault.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {MockedUnderlyingToken} from "./mocks/MockedUnderlyingToken.sol";

contract StakingVaultSetupTest is Test {
  StakingVault public vault;
  MockedUnderlyingToken public underlyingToken;

  address public admin = address(0x1);
  address public user = address(0x2);

  uint256 public constant SECONDS_PER_YEAR = 365 days;

  function setUp() public {
    underlyingToken = new MockedUnderlyingToken();

    vault = new StakingVault(admin, "Staking Vault", "SV", IERC20(address(underlyingToken)));

    vm.prank(admin);
    vault.setCap(type(uint256).max);
  }
}
