// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Test1155 is ERC1155 {
    constructor() ERC1155("") {}

    function buy(
        address tokenAddress,
        address from,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public payable {
        payable(from).transfer(msg.value);
        ERC1155(tokenAddress).safeTransferFrom(
            from,
            msg.sender,
            id,
            amount,
            data
        );
    }

    function trade(address recipient, uint256 amount) public payable {
        ERC20(address(0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa)).transfer(
            recipient,
            amount
        );
    }
}
