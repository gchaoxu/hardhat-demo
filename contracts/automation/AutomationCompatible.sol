// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract AutomationCompatible {
  function checkUpKeep () public virtual {}

  function performUpKeep () public virtual {}
}