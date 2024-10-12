/* 
    这一个实战主要是加深大家对 3 个取钱方法的使用。
    任何人都可以发送金额到合约
    只有 owner 可以取款
    3 种取钱方式
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract EtherWallet {
    // 定义了一个可支付的地址，代表合约的拥有者，且是不可改变的（immutable） 
    address payable public immutable owner;
    // Log 事件用于记录函数调用的信息，包括函数名、调用者地址、转账金额和附加的数据。
    event Log(string funName, address from, uint256 value, bytes data);
    constructor() {
        // 在构造函数中，将合约的创建者（msg.sender）设置为合约的唯一拥有者。
        owner = payable(msg.sender);
    }
    receive() external payable {
        // receive() 函数允许合约接收以太币。当合约收到以太币时，会触发 Log 事件记录相关信息。
        emit Log("receive", msg.sender, msg.value, "");
    }
    // withdraw1 允许合约拥有者提取固定的 100 wei（以太币的最小单位）。
    // 使用 transfer 方法将 100 wei 发送给调用者。
    function withdraw1() external {
        require(msg.sender == owner, "Not owner");
        // owner.transfer 相比 msg.sender 更消耗Gas
        // owner.transfer(address(this).balance);
        payable(msg.sender).transfer(100);
    }
    // withdraw2 允许提取固定的 200 wei。
    // 使用 send 方法，该方法返回一个布尔值，表示发送是否成功。
    function withdraw2() external {
        require(msg.sender == owner, "Not owner");
        bool success = payable(msg.sender).send(200);
        require(success, "Send Failed");
    }
    // withdraw3 允许提取合约中全部余额。
    // 使用 call 方法，这是一个更灵活的低级调用，可以发送任意数量的以太币。需要注意，如果目标地址的接收函数失败，此方法会导致该交易失败。
    function withdraw3() external {
        require(msg.sender == owner, "Not owner");
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Call Failed");
    }
    // getBalance 函数允许任何人查询合约的当前余额。
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}