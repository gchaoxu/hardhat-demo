// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// ERC20 标准接口
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract MyToken is IERC20 {
    // 代币元数据
    string private _name;
    string private _symbol;
    uint8 private immutable _decimals;
    
    // 总量与余额
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // 可配置的权限管理
    address private _owner;
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner");
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _owner = msg.sender;
        
        // 初始发行
        _mint(msg.sender, initialSupply);
    }

    // 代币名称
    function name() public view returns (string memory) {
        return _name;
    }

    // 代币符号
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    // 小数位数
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    // 总供应量
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    // 查询余额
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    // 转账
    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    // 授权额度
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // 授权操作
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    // 代扣转账
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }

    // 增发代币（需管理员权限）
    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    // 销毁代币（公开可调用）
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // 内部转账逻辑
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");
        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "Insufficient balance");
        
        _balances[from] = fromBalance - amount;
        _balances[to] += amount;
        
        emit Transfer(from, to, amount);
    }

    // 内部铸造逻辑
    function _mint(address account, uint256 amount) private {
        require(account != address(0), "Mint to zero address");
        
        _totalSupply += amount;
        _balances[account] += amount;
        
        emit Transfer(address(0), account, amount);
    }

    // 内部销毁逻辑
    function _burn(address account, uint256 amount) private {
        require(account != address(0), "Burn from zero address");
        
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "Burn amount exceeds balance");
        
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
    }

    // 授权管理
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Approve from zero address");
        require(spender != address(0), "Approve to zero address");
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // 授权额度检查
    function _spendAllowance(address owner, address spender, uint256 amount) private {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }
}