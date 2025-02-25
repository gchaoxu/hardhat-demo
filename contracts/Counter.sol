// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Counter {
  uint256 private counter; // 私有状态变量counter
  address private owner; // 存储合约部署者的地址

  // 构造函数，初始化合约的owner为部署者
  constructor() {
    owner = msg.sender; // 将合约部署者的地址赋值给owner
  }

  // 确保只有合约的部署者才能调用该方法
  modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner can call this function");
    _; // 执行函数的剩余代码
  }

  // 允许只有部署者调用的count函数
  function count() public onlyOwner { 
    counter++; // 增加计数器的值
  }

  // 返回计数器当前值的函数
  function getCounter() public view returns (uint256) { 
    return counter; // 返回计数器的当前值
  }
}