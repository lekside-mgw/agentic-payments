// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaymentExecutor {

    address public owner;

    struct Payment {
        address recipient;
        uint amount;
        bool executed;
    }

    mapping(uint => Payment) public payments;
    uint public paymentCount;

    constructor() {
        owner = msg.sender;
    }

    function createPayment(address _recipient, uint _amount) public {
        payments[paymentCount] = Payment(_recipient, _amount, false);
        paymentCount++;
    }

    function executePayment(uint _id) public {
        Payment storage payment = payments[_id];

        require(!payment.executed, "Already executed");
        require(address(this).balance >= payment.amount, "Insufficient balance");

        payment.executed = true;
        payable(payment.recipient).transfer(payment.amount);
    }

    function deposit() public payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
