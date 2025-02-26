// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
}

contract Bank {
    // 存储用户的余额
    mapping(address => mapping(address => uint256)) private balances;

    // 存款事件
    event Deposit(address indexed user, address indexed token, uint256 amount);

    // 取款事件
    event Withdrawal(address indexed user, address indexed token, uint256 amount);

    // 存款函数
    function deposit(address token, uint256 amount) public {
      require(amount > 0, "Deposit amount must be greater than zero");

      // 调用 ERC20 的 transferFrom 方法
      bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
      require(success, "Transfer failed");

      // 更新用户余额
      balances[msg.sender][token] += amount;
      emit Deposit(msg.sender, token, amount);
    }

    // 取款函数
    function withdraw(address token, uint256 amount) public {
      require(amount > 0, "Withdrawal amount must be greater than zero");
      require(balances[msg.sender][token] >= amount, "Insufficient balance");

      // 更新用户余额
      balances[msg.sender][token] -= amount;

      // 调用 ERC20 的 transfer 方法
      require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
      emit Withdrawal(msg.sender, token, amount);
    }

    // 查询余额函数
    function getBalance(address token) public view returns (uint256) {
      return balances[msg.sender][token];
    }
}