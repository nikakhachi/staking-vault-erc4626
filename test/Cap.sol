// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {StakingVaultSetupTest} from "./Setup.t.sol";
import {EventsLib} from "../src/libraries/EventsLib.sol";
import {console} from "forge-std/console.sol";

contract StakingVaultCapTest is StakingVaultSetupTest {
  function test_setCap_succesfull(uint256 newCap) public {
    vm.startPrank(admin);

    uint256 previousCap = vault.cap();

    vm.expectEmit(true, true, false, true);
    emit EventsLib.CapUpdate(previousCap, newCap, block.timestamp);
    vault.setCap(newCap);

    assertEq(vault.cap(), newCap);
  }

  function test_setCap_unauthorized(uint256 newCap, address user) public {
    vm.assume(user != admin);

    vm.prank(user);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
    vault.setCap(newCap);
  }
}
