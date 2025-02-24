// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Bank {
  address public owner;
  mapping (address => uint256) public deposits;

  constructor() {
    owner = msg.sender;
  }

  modifier OnlyOwner () {
    require(msg.sender == owner, 'Not Owner!');
    _;
  }

  receive( ) external payable {
    deposits[msg.sender] += msg.value;
  }

 // 银行的部署人，取出所有的存款
  function withdrawAll() public OnlyOwner {
    uint b  = address(this).balance;

    payable(owner).transfer(b);
  }

  // 取款
  function withdraw () public {
    (bool success, ) = msg.sender.call{value: deposits[msg.sender]}(new bytes(0));
    require(success, 'transfer faild');

    deposits[msg.sender] = 0;
  }

  // 存款 
  function deposit(uint amount) public payable {
    deposits[msg.sender] += amount;
  }

  // 获取存款
  function myDeposit() public view returns(uint256) {
    return deposits[msg.sender];
  }

}