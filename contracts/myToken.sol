// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract myToken is ERC20 {
  constructor() ERC20(unicode"我和皮皮小猫", 'P-withcat') {
    _mint(msg.sender, 1000 * 10 ** 18);
  }
}