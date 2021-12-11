// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ERC721Tradable.sol";

contract Market {
    mapping(bytes => uint256) private _assetPrices;

    modifier onlyOwner(address tokenAddress, uint256 tokenId) {
        ERC721Tradable nft = ERC721Tradable(tokenAddress);
        require(
            nft.ownerOf(tokenId) == msg.sender,
            "Ownable: caller is not the owner"
        );
        _;
    }

    function getKey(address tokenAddress, uint256 tokenId)
        private
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(tokenAddress, tokenId);
    }

    function createSellOrder(
        address tokenAddress,
        uint256 tokenId,
        uint256 price
    ) public onlyOwner(tokenAddress, tokenId) {
        bytes memory key = getKey(tokenAddress, tokenId);
        require(_assetPrices[key] == 0, "Price has been set");
        require(price > 0, "Price must be greater than 0");
        _assetPrices[key] = price;
    }

    function cancelOrder(address tokenAddress, uint256 tokenId)
        public
        onlyOwner(tokenAddress, tokenId)
    {
        bytes memory key = getKey(tokenAddress, tokenId);
        delete _assetPrices[key];
    }

    function getPrice(address tokenAddress, uint256 tokenId)
        public
        view
        returns (uint256)
    {
        bytes memory key = getKey(tokenAddress, tokenId);
        return _assetPrices[key];
    }

    function buy(address tokenAddress, uint256 tokenId) public payable {
        ERC721Tradable nft = ERC721Tradable(tokenAddress);
        bytes memory key = getKey(tokenAddress, tokenId);
        require(_assetPrices[key] > 0, "No sales");
        address owner = nft.ownerOf(tokenId);
        require(_assetPrices[key] == msg.value, "Invalid price");
        require(owner != msg.sender, "It's already yours");
        uint256 fee = SafeMath.div(msg.value, 10);
        payable(owner).transfer(msg.value - fee);
        payable(address(0x43d6914F10151A3dB15D7aB32bf4c5cD44c48210)).transfer(
            fee
        );
        nft.safeTransferFrom(owner, msg.sender, tokenId);
    }
}
