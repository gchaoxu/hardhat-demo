// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Bank is Ownable {
    // 记录用户的余额
    mapping(address => mapping(address => uint256)) public balances;

    // 事件
    event Deposit(address indexed user, address indexed token, uint256 amount);

    // TODO 这里为什么要继承 Ownable 及其构造函数
    constructor(address initialOwner) Ownable(initialOwner){}

    // Deposit 方法
    function deposit(
      address token,
      uint256 amount,
      uint256 expiry,
      uint8 v,
      bytes32 r,
      bytes32 s
    ) public {
      // 验证签名
      bytes32 structHash = keccak256(abi.encode(
        keccak256("Deposit(address owner,uint256 amount,uint256 expiry)"),
        msg.sender,
        amount,
        expiry
      ));

      bytes32 digest = keccak256(abi.encodePacked(
        "\x19 Ethereum Signed Message:\n32",
        structHash
      ));

      address signer = ecrecover(digest, v, r, s);
      require(signer == msg.sender, "Invalid signature");
      require(block.timestamp < expiry, "Signature expired");

      // 调用 ERC20Permit 的 permit 方法
      ERC20Permit(token).permit(msg.sender, address(this), amount, expiry, v, r, s);
      require(ERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");

      // 更新用户余额
      balances[msg.sender][token] += amount;

      emit Deposit(msg.sender, token, amount);
    }
}