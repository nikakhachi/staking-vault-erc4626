// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC4626} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";

import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";

import {IUnderlyingToken} from "./interfaces/IUnderlyingToken.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {EventsLib} from "./libraries/EventsLib.sol";
import {RAY} from "./libraries/ConstantsLib.sol";

contract StakingVault is Ownable2Step, ERC4626 {
  uint256 public compoundFactorAccum = RAY;
  uint256 public currentRate;
  uint256 public lastUpdatedTimestamp;
  uint256 public cap;

  constructor(
    address owner,
    string memory name,
    string memory symbol,
    IERC20 asset
  ) ERC20(name, symbol) ERC4626(asset) Ownable(owner) {
    lastUpdatedTimestamp = block.timestamp;
  }

  // ---- ERC4626 overrides ----

  function _convertToShares(uint256 assets, Math.Rounding) internal view override returns (uint256) {
    uint256 accum = compoundFactorAccum * _compoundFactor();

    return (assets * RAY) / (accum / RAY);
  }

  function _convertToAssets(uint256 shares, Math.Rounding) internal view override returns (uint256) {
    uint256 accum = compoundFactorAccum * _compoundFactor();

    return (shares * (accum / RAY)) / RAY;
  }

  function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal override {
    uint256 totalAssetsAfter = _convertToAssets(shares + totalSupply(), Math.Rounding.Ceil);

    require(cap >= totalAssetsAfter, ErrorsLib.CAP_EXCEEDED);

    IUnderlyingToken(asset()).burnFrom(caller, assets);
    _mint(receiver, shares);

    emit Deposit(caller, receiver, assets, shares);
  }

  function _withdraw(
    address caller,
    address receiver,
    address owner,
    uint256 assets,
    uint256 shares
  ) internal override {
    if (caller != owner) _spendAllowance(owner, caller, shares);

    _burn(owner, shares);
    IUnderlyingToken(asset()).mint(receiver, assets);

    emit Withdraw(caller, receiver, owner, assets, shares);
  }

  function totalAssets() public view override returns (uint256) {
    return _convertToAssets(totalSupply(), Math.Rounding.Ceil);
  }

  // ---- Compound factor calculation ----

  // https://github.com/aave/protocol-v2/blob/master/contracts/protocol/libraries/math/MathUtils.sol#L45
  function _compoundFactor() private view returns (uint256) {
    uint256 n = block.timestamp - lastUpdatedTimestamp;

    uint256 term1 = RAY;
    uint256 term2 = n * currentRate;

    if (n == 0) return term1 + term2;

    uint256 term3 = ((n - 1) * n * ((currentRate * currentRate) / RAY)) / 2;

    if (n == 1) return term1 + term2 + term3;

    uint256 term4 = (n * (n - 1) * (n - 2) * ((currentRate * currentRate) / RAY) * currentRate) / RAY / 6;

    return term1 + term2 + term3 + term4;
  }

  // ---- Vault management ----

  function setCap(uint256 _newCap) external onlyOwner {
    cap = _newCap;

    emit EventsLib.CapUpdate(cap, _newCap, block.timestamp);
  }

  function update(uint256 _newRate) external onlyOwner {
    require(_newRate <= RAY, ErrorsLib.INVALID_RATE);

    uint256 accum = compoundFactorAccum * _compoundFactor();

    compoundFactorAccum = accum / RAY;

    currentRate = _newRate;
    lastUpdatedTimestamp = block.timestamp;

    emit EventsLib.RateUpdate(currentRate, _newRate, block.timestamp);
  }
}
