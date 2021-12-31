// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC721Tradable.sol";
import "./ERC1155Tradable.sol";

contract Factory {
    event Created(address indexed tokenAddress, uint256 indexed tokenStandard);
    event Mint(
        address indexed tokenAddress,
        uint256 indexed tokenStandard,
        address indexed to,
        string uri,
        uint256 amount
    );

    mapping(address => uint256) private _tokenMapStandards;

    function deploy(
        address proxy,
        Tradable.Recipient[] memory saleRecipients,
        uint256 sellerFeeBasisPoints,
        Tradable.Recipient[] memory feeRecipients,
        string memory url,
        uint256 tokenStandard
    ) public {
        address tradable;
        if (tokenStandard == 721) {
            tradable = address(
                new ERC721Tradable(
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
                    proxy,
                    saleRecipients,
                    sellerFeeBasisPoints,
                    feeRecipients,
                    url
                )
            );
        }
        _tokenMapStandards[tradable] = tokenStandard;
        emit Created(address(tradable), tokenStandard);
    }

    function mint(
        address tokenAddress,
        address to,
        string memory uri,
        uint256 amount
    ) public {
        if (_tokenMapStandards[tokenAddress] == 721) {
            ERC721Tradable tradable = ERC721Tradable(tokenAddress);
            tradable.mint(to, uri);
        } else {
            ERC1155Tradable tradable = ERC1155Tradable(tokenAddress);
            tradable.mint(to, amount, uri);
        }
        emit Mint(
            tokenAddress,
            _tokenMapStandards[tokenAddress],
            to,
            uri,
            amount
        );
    }
}
