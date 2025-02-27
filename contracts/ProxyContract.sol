// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * *使用 delegatecall 注意的点 
 * 1. 代理和逻辑合约的存储布局要一致
 * 2. delegatecall 的返回值为 bytes 需要转为具体的类型
 * 3. 不能有函数冲撞
*/

// 原本有问题的合约
contract Counter {
  uint256 private counter;

  //!!! 这里应该是 + amount 但是写成了每次调用函数 + 1
  function add (uint256 amount) public {
    counter += 1;
  }

  function get() public view returns(uint256) {
    return counter;
  }
}

// 新的逻辑合约
contract CounterV1 {
  address private impl;
  uint public counter;

  //这里修复 add  函数
  function add (uint256 amount) public {
    counter += amount;
  }

  function get() public view returns(uint256) {
    return counter;
  }
}

// 代理合约
contract CounterProxy {
  address private impl;
  uint public counter;

  constructor() {}

  function updateTo(address _impl) public {
    impl = _impl;
  }

  // 分别代理
  function delegateAdd (uint256 n) external {
    bytes memory callData = abi.encodeWithSignature('add(uint256)', n);
    (bool ok,) = address(impl).delegatecall(callData);
    if(!ok) revert('Delegate call failed');
  }

  function delegateGet() external returns(uint256) {
    bytes memory callData = abi.encodeWithSignature('get()');
    (bool ok, bytes memory resVal) = address(impl).delegatecall(callData);
    if(!ok) revert('Delegate call failed');

    return abi.decode(resVal, (uint256));
  }
}

library StoreageSlot {
  struct AddressSlot {
    address value;
  }
  function getAddressSlot(bytes32 slot) internal pure returns(AddressSlot storage r) {
    assembly {
      r.slot := slot
    }
  }
}

// 代理合约 V2 解决升级添加的变量，必须在尾部添加
contract CounterProxyV2 {
  bytes32 private constant IMPLEMENTATION_SLOT =  bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);
  uint public counter;

  constructor() {}

  // 分别代理
  function delegateAdd (uint256 n) external {
    bytes memory callData = abi.encodeWithSignature('add(uint256)', n);
    (bool ok,) = _getimplementation().delegatecall(callData);
    if(!ok) revert('Delegate call failed');
  }

  function delegateGet() external returns(uint256) {
    bytes memory callData = abi.encodeWithSignature('get()');
    (bool ok, bytes memory resVal) = _getimplementation().delegatecall(callData);
    if(!ok) revert('Delegate call failed');

    return abi.decode(resVal, (uint256));
  }

  function _getimplementation() private view returns(address) {
    return StoreageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
  }
}