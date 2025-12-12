// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {StakingVault} from "../src/StakingVault.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {MockedUnderlyingToken} from "./mocks/MockedUnderlyingToken.sol";

import {console} from "forge-std/console.sol";

contract StakingVaultTest is Test {
  StakingVault public vault;
  MockedUnderlyingToken public stablecoin;
  address public admin;
  address public user;

  uint256 public constant SECONDS_PER_YEAR = 365 days;

  function setUp() public {
    admin = address(0x1);
    user = address(0x2);

    stablecoin = new MockedUnderlyingToken();

    vault = new StakingVault(admin, "Staking Vault", "SV", IERC20(address(stablecoin)));

    vm.prank(admin);
    vault.setCap(type(uint256).max);

    vm.prank(admin);
    vault.update(0.000000003022265993024580000e27);
  }

  function test_10PercentAfter365Days() public {
    uint256 depositAmount = 1000e18; // 1000 tokens

    stablecoin.mint(user, depositAmount);

    vm.startPrank(user);

    stablecoin.approve(address(vault), depositAmount);
    uint256 shares = vault.deposit(depositAmount, user);

    console.log("total assets", vault.totalAssets());

    skip(SECONDS_PER_YEAR);

    console.log("total assets", vault.totalAssets());

    vault.redeem(shares, user, user);

    console.log("total assets", vault.totalAssets());

    console.log("final balance", stablecoin.balanceOf(user));
  }
}
