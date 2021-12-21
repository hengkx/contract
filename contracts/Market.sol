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
        uint256 erc
    ) {
        if (erc == 1155) {
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

    modifier onlyOrderOwner(uint256 orderId) {
        MarketItem memory item = idToMarketItem[orderId];
        uint256 tokenId = item.tokenId;
        if (item.erc == 1155) {
            ERC1155Tradable nft = ERC1155Tradable(item.tokenAddress);

            require(
                nft.balanceOf(msg.sender, tokenId) > 0,
                "Ownable: caller is not the owner"
            );
        } else {
            ERC721Tradable nft = ERC721Tradable(item.tokenAddress);
            require(
                nft.ownerOf(tokenId) == msg.sender,
                "Ownable: caller is not the owner"
            );
        }
        _;
    }

    struct MarketItem {
        uint256 orderId;
        address tokenAddress;
        uint256 tokenId;
        address payable seller;
        uint256 price;
        uint256 amount;
        uint256 erc;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event Sale(
        uint256 indexed orderId,
        address indexed tokenAddress,
        uint256 indexed tokenId,
        address seller,
        uint256 price,
        uint256 amount,
        uint256 erc
    );

    event CancelSale(uint256 indexed orderId);

    event Buy(uint256 indexed orderId, address indexed buyer, uint256 amount);

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
        uint256 erc
    ) public onlyOwner(tokenAddress, tokenId, erc) {
        require(price > 0, "Price must be greater than 0");

        if (erc == 1155) {
            ERC1155Tradable nft = ERC1155Tradable(tokenAddress);
            uint256 balance = nft.balanceOf(msg.sender, tokenId);
            require(balance >= amount, "Invalid quantity");
        } else {
            bytes memory key = getKey(tokenAddress, tokenId);
            require(_assetPrices[key] == 0, "Price has been set");
            _assetPrices[key] = price;
        }
        _itemIds.increment();
        uint256 orderId = _itemIds.current();
        idToMarketItem[orderId] = MarketItem(
            orderId,
            tokenAddress,
            tokenId,
            payable(msg.sender),
            price,
            amount,
            erc
        );
        emit Sale(
            orderId,
            tokenAddress,
            tokenId,
            msg.sender,
            price,
            amount,
            erc
        );
    }

    function cancelOrder(uint256 orderId) public onlyOrderOwner(orderId) {
        MarketItem memory item = idToMarketItem[orderId];
        if (item.erc == 721) {
            bytes memory key = getKey(item.tokenAddress, item.tokenId);
            delete _assetPrices[key];
        }
        delete idToMarketItem[orderId];
        emit CancelSale(orderId);
    }

    function getPrice(uint256 orderId) public view returns (uint256) {
        return idToMarketItem[orderId].price;
    }

    function _settlement(Tradable.Recipient[] memory recipients, uint256 money)
        private
    {
        uint256 paid = 0;
        uint256 len = recipients.length;
        for (uint256 i = 0; i < len - 1; i++) {
            Tradable.Recipient memory recipient = recipients[i];
            uint256 currentFee = money.mul(recipient.points).div(100);
            payable(address(recipient.recipient)).transfer(currentFee);
            paid += currentFee;
        }
        payable(address(recipients[len - 1].recipient)).transfer(
            money.sub(paid)
        );
    }

    function settlement(
        address tokenAddress,
        address owner,
        uint256 tokenId,
        uint256 money,
        uint256 quantity
    ) public {
        Tradable nft = Tradable(tokenAddress);
        // 版税
        uint256 fee = money.mul(nft.getSellerFeeBasisPoints()).div(100);
        // 实际分给卖家的钱
        uint256 receipts = money.sub(fee);
        // 第一次参与分成的数量（解决第一次销售多个owner问题）
        uint256 firstAmount = nft.getFistAmount(owner, tokenId);
        if (firstAmount >= quantity) {
            _settlement(nft.getSaleRecipients(), receipts);
        } else if (firstAmount > 0) {
            uint256 firstReceipts = receipts.div(quantity).mul(firstAmount);
            _settlement(nft.getSaleRecipients(), firstReceipts);
            payable(address(owner)).transfer(receipts.sub(firstReceipts));
        } else {
            payable(address(owner)).transfer(receipts);
        }
        _settlement(nft.getFeeRecipients(), fee);
    }

    function buy(uint256 orderId, uint256 quantity) public payable {
        MarketItem memory item = idToMarketItem[orderId];
        uint256 price = item.price;
        require(price > 0, "No sales");
        require(price == msg.value.div(quantity), "Invalid price");
        address tokenAddress = item.tokenAddress;
        uint256 tokenId = item.tokenId;
        if (item.erc == 721) {
            ERC721Tradable nft = ERC721Tradable(tokenAddress);
            address owner = nft.ownerOf(tokenId);
            require(owner != msg.sender, "It's already yours");
            settlement(tokenAddress, owner, tokenId, msg.value, 1);
            nft.safeTransferFrom(owner, msg.sender, tokenId);
            bytes memory key = getKey(tokenAddress, tokenId);
            delete _assetPrices[key];
        } else {
            ERC1155Tradable nft = ERC1155Tradable(tokenAddress);
            uint256 balance = nft.balanceOf(item.seller, item.tokenId);
            require(balance >= quantity, "Invliad quantity");
            require(item.amount >= quantity, "Invliad sale quantity");
            settlement(tokenAddress, item.seller, tokenId, msg.value, quantity);
            nft.safeTransferFrom(
                item.seller,
                msg.sender,
                tokenId,
                quantity,
                ""
            );
        }

        if (idToMarketItem[orderId].amount > quantity) {
            idToMarketItem[orderId].amount -= quantity;
        } else {
            delete idToMarketItem[orderId];
        }
        emit Buy(orderId, msg.sender, quantity);
    }
}
