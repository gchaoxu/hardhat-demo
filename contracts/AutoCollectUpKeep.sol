// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import './automation/AutomationCompatible.sol';

interface IBank {
  function collect() external;
}

contract AutoCollectUpKeep is AutomationCompatible {
  address public immutable token;
  address public immutable bank;

  constructor(address _token, address _bank) {
    token = _token;
    bank = _bank;
  }

  function checkUpKeep (bytes calldata checkData) external view override returns (bool upkeepNeeded, bytes memory performData) {
    if(IERC20(token).balanceOf(bank) > 5e18) {
      upkeepNeeded = true;
    }
  }

  function performUpKeep (bytes calldata performData) external override {
    if(IERC20(token).balanceOf(bank) > 5e18) {
      IBank(bank).collect();
    }
  }
}
