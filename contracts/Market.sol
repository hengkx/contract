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
        view
        returns (bytes memory)
    {
        ERC721Tradable nft = ERC721Tradable(tokenAddress);
        return abi.encodePacked(tokenAddress, nft.ownerOf(tokenId), tokenId);
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

    function _settlement(
        ERC721Tradable.Recipient[] memory recipients,
        uint256 amount
    ) private {
        uint256 paid = 0;
        uint256 len = recipients.length;
        for (uint256 i = 0; i < len - 1; i++) {
            ERC721Tradable.Recipient memory recipient = recipients[i];
            uint256 currentFee = SafeMath.div(
                SafeMath.mul(amount, recipient.points),
                100
            );
            payable(address(recipient.recipient)).transfer(currentFee);
            paid += currentFee;
        }
        payable(address(recipients[len - 1].recipient)).transfer(
            SafeMath.sub(amount, paid)
        );
    }

    function buy(address tokenAddress, uint256 tokenId) public payable {
        ERC721Tradable nft = ERC721Tradable(tokenAddress);
        bytes memory key = getKey(tokenAddress, tokenId);
        require(_assetPrices[key] > 0, "No sales");
        address owner = nft.ownerOf(tokenId);
        require(_assetPrices[key] == msg.value, "Invalid price");
        require(owner != msg.sender, "It's already yours");
        uint256 fee = SafeMath.div(
            SafeMath.mul(msg.value, nft.getSellerFeeBasisPoints()),
            100
        );
        uint256 amount = SafeMath.sub(msg.value, fee);
        if (nft.getTracnsferCount(tokenId) == 0) {
            _settlement(nft.getSaleRecipients(), amount);
        } else {
            payable(address(owner)).transfer(amount);
        }
        _settlement(nft.getFeeRecipients(), fee);

        nft.safeTransferFrom(owner, msg.sender, tokenId);
    }
}
