// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaymentExecutor {

    address public owner;

    struct Payment {
        address recipient;
        uint amount;
        uint executeAfter;
        uint reward;
        bool executed;
    }

    mapping(uint => Payment) public payments;
    uint public paymentCount;

    mapping(address => bool) public approvedAgents;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAgent() {
        require(approvedAgents[msg.sender], "Not approved agent");
        _;
    }

    // --- Agent Management ---

    function approveAgent(address _agent) public onlyOwner {
        approvedAgents[_agent] = true;
    }

    function removeAgent(address _agent) public onlyOwner {
        approvedAgents[_agent] = false;
    }

    // --- Payment Logic ---

    function createPayment(
        address _recipient,
        uint _amount,
        uint _delay,
        uint _reward
    ) public payable {
        require(msg.value == _amount + _reward, "Incorrect funding");

        payments[paymentCount] = Payment(
            _recipient,
            _amount,
            block.timestamp + _delay,
            _reward,
            false
        );

        paymentCount++;
    }

    function executePayment(uint _id) public onlyAgent {
        Payment storage payment = payments[_id];

        require(!payment.executed, "Already executed");
        require(block.timestamp >= payment.executeAfter, "Too early");
        require(address(this).balance >= payment.amount + payment.reward, "Insufficient balance");

        payment.executed = true;

        // pay recipient
        payable(payment.recipient).transfer(payment.amount);

        // reward agent
        payable(msg.sender).transfer(payment.reward);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
