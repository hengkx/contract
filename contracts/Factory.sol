// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC721Tradable.sol";
import "./ERC1155Tradable.sol";

contract Factory {
    event Created(address indexed tradable, uint256 erc);

    function deploy(
        string memory name,
        string memory symbol,
        address proxy,
        Tradable.Recipient[] memory saleRecipients,
        uint256 sellerFeeBasisPoints,
        Tradable.Recipient[] memory feeRecipients,
        string memory url,
        uint256 erc
    ) public {
        address tradable;
        if (erc == 721) {
            tradable = address(
                new ERC721Tradable(
                    name,
                    symbol,
                    proxy,
                    saleRecipients,
                    sellerFeeBasisPoints,
                    feeRecipients,
                    url
                )
            );
        } else {
            tradable = address(
                new ERC1155Tradable(
                    name,
                    symbol,
                    proxy,
                    saleRecipients,
                    sellerFeeBasisPoints,
                    feeRecipients,
                    url
                )
            );
        }
        emit Created(address(tradable), erc);
    }
}
