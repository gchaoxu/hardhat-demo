// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 接口定义Score合约的基本操作
interface IScore {
  function setScore(address student, uint256 score) external; // 设置学生分数
  function getScore(address student) external view returns (uint256); // 获取学生分数
}

// Score合约，用于记录学生分数
contract Score {
    // 记录学生地址到分数的映射
    mapping (address => uint256) private scores;
    
    // 只有老师可以调用此函数来设置学生分数
    modifier onlyTeacher() {
      require(msg.sender == Teacher(addressOfTeacher()).teacherAddress, "Only teacher can modify scores.");
      _;
    }
    
    // 老师地址存储在Teacher合约中（假定已部署并设置了正确的地址）
    function addressOfTeacher() public view returns (address) { /* 函数逻辑由Teacher合约实现 */ }
    
    // 老师可以为学生设置分数，但分数不能超过100
    function setScore(address student, uint256 score) public onlyTeacher {
      require(score <= 100, "Score cannot be greater than 100.");
      scores[student] = score;
    }
    
    // 获取学生分数的公共只读函数
    function getScore(address student) public view returns (uint256) {
      return scores[student];
    }
}

// Teacher合约，作为老师，通过IScore接口调用来修改学生分数
contract Teacher {
  address public teacherAddress; // 老师地址
  address public scoreContractAddress; // Score合约的地址
  IScore public scoreContract; // Score合约的接口实例
  
  constructor(address _scoreContractAddress) {
    scoreContractAddress = _scoreContractAddress; // 部署Teacher合约时传入Score合约的地址
    scoreContract = IScore(scoreContractAddress); // 初始化Score合约的接口实例
    teacherAddress = msg.sender; // 设置老师地址为部署合约的人（假设部署者是老师）
  }
  
  // 老师可以通过此函数获取Score合约的地址来查询学生的分数
  function getScoreContractAddress() public view returns (address) {
    return scoreContractAddress;
  }
  
  // 老师可以通过此函数设置学生分数（通过Score合约的setScore函数）
  function setStudentScore(address student, uint256 score) public {
    require(score <= 100, "Score cannot be greater than 100."); // 确保分数不超过100分限制条件在这里也被检查一次（在调用外部合约时再次检查是安全的）
    scoreContract.setScore(student, score); // 通过接口调用Score合约的setScore函数来设置学生分数
  }
}