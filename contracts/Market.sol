// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ERC721Tradable.sol";
import "./ERC1155Tradable.sol";

contract Market {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    mapping(bytes => uint256) private _assetPrices;
    Counters.Counter private _itemIds;

    modifier onlyOwner(
        address tokenAddress,
        uint256 tokenId,
        bool is1155
    ) {
        if (is1155) {
            ERC1155Tradable nft = ERC1155Tradable(tokenAddress);

            require(
                nft.balanceOf(msg.sender, tokenId) > 0,
                "Ownable: caller is not the owner"
            );
        } else {
            ERC721Tradable nft = ERC721Tradable(tokenAddress);
            require(
                nft.ownerOf(tokenId) == msg.sender,
                "Ownable: caller is not the owner"
            );
        }
        _;
    }

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        uint256 amount;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event Created(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        uint256 amount
    );

    function getKey(address tokenAddress, uint256 tokenId)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(tokenAddress, tokenId);
    }

    function createSellOrder(
        address tokenAddress,
        uint256 tokenId,
        uint256 price,
        uint256 amount,
        bool is1155
    ) public onlyOwner(tokenAddress, tokenId, is1155) {
        require(price > 0, "Price must be greater than 0");
        if (is1155) {
            _itemIds.increment();
            uint256 itemId = _itemIds.current();
            idToMarketItem[itemId] = MarketItem(
                itemId,
                tokenAddress,
                tokenId,
                payable(msg.sender),
                payable(address(0)),
                price,
                amount
            );
            emit Created(
                itemId,
                tokenAddress,
                tokenId,
                msg.sender,
                address(0),
                price,
                amount
            );
        } else {
            bytes memory key = getKey(tokenAddress, tokenId);
            require(_assetPrices[key] == 0, "Price has been set");
            _assetPrices[key] = price;
        }
    }

    function cancelOrder(
        address tokenAddress,
        uint256 tokenId,
        bool is1155
    ) public onlyOwner(tokenAddress, tokenId, is1155) {
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

    function _settlement(Tradable.Recipient[] memory recipients, uint256 amount)
        private
    {
        uint256 paid = 0;
        uint256 len = recipients.length;
        for (uint256 i = 0; i < len - 1; i++) {
            Tradable.Recipient memory recipient = recipients[i];
            uint256 currentFee = amount.mul(recipient.points).div(100);
            payable(address(recipient.recipient)).transfer(currentFee);
            paid += currentFee;
        }
        payable(address(recipients[len - 1].recipient)).transfer(
            amount.sub(paid)
        );
    }

    function settlement(
        address tokenAddress,
        address owner,
        uint256 tokenId,
        uint256 amount
    ) public {
        Tradable nft = Tradable(tokenAddress);
        uint256 fee = amount.mul(nft.getSellerFeeBasisPoints()).div(100);
        uint256 receipts = amount.sub(fee);
        if (nft.getFistAmount(owner, tokenId) > 0) {
            _settlement(nft.getSaleRecipients(), receipts);
        } else {
            payable(address(owner)).transfer(receipts);
        }
        _settlement(nft.getFeeRecipients(), fee);
    }

    function buy(address tokenAddress, uint256 tokenId) public payable {
        ERC721Tradable nft = ERC721Tradable(tokenAddress);
        bytes memory key = getKey(tokenAddress, tokenId);
        require(_assetPrices[key] > 0, "No sales");
        address owner = nft.ownerOf(tokenId);
        require(_assetPrices[key] == msg.value, "Invalid price");
        require(owner != msg.sender, "It's already yours");
        settlement(tokenAddress, owner, tokenId, msg.value);
        nft.safeTransferFrom(owner, msg.sender, tokenId);
        delete _assetPrices[key];
    }

    function buy1155(uint256 itemId, uint256 amount) public payable {
        MarketItem memory item = idToMarketItem[itemId];
        require(item.price > 0, "No sales");
        ERC1155Tradable nft = ERC1155Tradable(item.nftContract);
        uint256 balance = nft.balanceOf(item.seller, item.tokenId);
        require(balance >= amount, "Invliad amount");
        settlement(item.nftContract, item.seller, item.tokenId, msg.value);
        nft.safeTransferFrom(item.seller, msg.sender, item.tokenId, amount, "");
        delete idToMarketItem[itemId];
    }
}
