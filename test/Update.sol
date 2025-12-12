// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {StakingVaultSetupTest} from "./Setup.t.sol";
import {EventsLib} from "../src/libraries/EventsLib.sol";
import {console} from "forge-std/console.sol";
import {RAY} from "../src/libraries/ConstantsLib.sol";
import {ErrorsLib} from "../src/libraries/ErrorsLib.sol";

contract StakingVaultUpdateTest is StakingVaultSetupTest {
  function test_update_succesfull(uint256 newRate, uint256 timeToSkip) public {
    newRate = bound(newRate, 0, RAY);
    timeToSkip = bound(timeToSkip, 1 days, 365 days);

    skip(timeToSkip);

    vm.startPrank(admin);
    vm.expectEmit(true, true, false, true);
    emit EventsLib.RateUpdate(vault.currentRate(), newRate, block.timestamp);
    vault.update(newRate);

    assertEq(vault.currentRate(), newRate);
    assertEq(vault.lastUpdatedTimestamp(), block.timestamp);
  }

  function test_update_unauthorized(uint256 newRate, address user) public {
    vm.assume(user != admin);

    vm.prank(user);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
    vault.update(newRate);
  }

  function test_update_invalid_rate(uint256 newRate) public {
    vm.assume(newRate > RAY);

    vm.startPrank(admin);
    vm.expectRevert(bytes(ErrorsLib.INVALID_RATE));
    vault.update(newRate);
  }
}
