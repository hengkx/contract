// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Test {
    function send(address receiver) public payable {
        // ERC20(address(0)).transferFrom(msg.sender, receiver, msg.value);
        payable(msg.sender).transfer(msg.value);
    }
}
