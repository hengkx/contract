// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "./Tradable.sol";

contract Market is EIP712, ReentrancyGuard {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    // TODO remove 最新板块未使用
    mapping(bytes => uint256) private _assetPrices;
    // TODO remove 最新板块未使用
    Counters.Counter private _itemIds;
    // 2981协议标识
    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    struct Order {
        /* Order contract address. */
        address tokenAddress;
        /* Order contract id. */
        uint256 tokenId;
        /* Order maker address. */
        address maker;
        address currency;
        /* Order unit price. */
        uint256 price;
        /* Order total sell amount. */
        uint256 amount;
        /* Order listing timestamp. */
        uint256 listingTime;
        /* Order expiration timestamp - 0 for no expiry. */
        uint256 expirationTime;
        /* Order salt to prevent duplicate hashes. */
        uint256 salt;
        /* 1 sell 2 offer 3 auction */
        uint256 side;
        address serviceFeeAddress;
        /* 服务费千分比 其余的百分比 */
        uint256 serviceFeePoint;
        /* nft的接收人 */
        address tokenReceiver;
    }

    // 订单类型HASH
    bytes32 constant ORDER_TYPE_HASH =
        keccak256(
            "Order(address tokenAddress,uint256 tokenId,address maker,address currency,uint256 price,uint256 amount,uint256 listingTime,uint256 expirationTime,uint256 salt,uint256 side,address serviceFeeAddress,uint256 serviceFeePoint,address tokenReceiver)"
        );
    // 取消订单事件
    event CancelOrder(bytes32 indexed hash);
    // 订单交易事件
    event OrderMatched(
        bytes32 indexed sellHash,
        bytes32 indexed buyHash,
        address maker,
        address taker,
        address tokenReceiver,
        uint256 amount,
        uint256 price
    );
    // 存储订单取消或已完成
    mapping(bytes32 => bool) public cancelledOrFinalized;
    // 存储订单已完成数量
    mapping(bytes32 => uint256) _tradedAmounts;

    constructor() EIP712("Culture Vault", "1.0.0") {}

    // 合约合约类型
    function getTokenStandard(
        address tokenAddress
    ) public view returns (uint256) {
        if (IERC721(tokenAddress).supportsInterface(0x80ac58cd)) {
            return 721;
        } else if (IERC1155(tokenAddress).supportsInterface(0xd9b67a26)) {
            return 1155;
        }
        return 0;
    }

    // 获取订单HASH
    function hashOrder(Order memory order) public pure returns (bytes32) {
        bytes32 hashStruct = keccak256(
            abi.encode(
                ORDER_TYPE_HASH,
                order.tokenAddress,
                order.tokenId,
                order.maker,
                order.currency,
                order.price,
                order.amount,
                order.listingTime,
                order.expirationTime,
                order.salt,
                order.side,
                order.serviceFeeAddress,
                order.serviceFeePoint,
                order.tokenReceiver
            )
        );
        return hashStruct;
    }

    // 校验订单
    function validateOrder(
        Order memory order,
        bytes memory signature
    ) public view returns (bool) {
        // 判断订单日期是否合法
        if (
            order.listingTime > block.timestamp ||
            (order.expirationTime != 0 &&
                order.expirationTime <= block.timestamp)
        ) {
            return false;
        }

        if (order.maker == msg.sender) {
            return true;
        }

        bytes32 hash = _hashTypedDataV4(hashOrder(order));
        return ECDSA.recover(hash, signature) == order.maker;
    }

    // 取消订单
    function cancelOrder(Order memory order) external {
        require(order.maker == msg.sender, "Not owner");
        bytes32 hash = hashOrder(order);
        cancelledOrFinalized[hash] = true;
        emit CancelOrder(hash);
    }

    // 判断是否有操作订单的权限
    function isApproved(Order memory order) public view returns (bool) {
        uint256 tokenStandard = getTokenStandard(order.tokenAddress);
        if (tokenStandard == 721) {
            return
                IERC721(order.tokenAddress).getApproved(order.tokenId) ==
                address(this) ||
                IERC721(order.tokenAddress).isApprovedForAll(
                    order.maker,
                    address(this)
                );
        } else if (tokenStandard == 1155) {
            return
                IERC1155(order.tokenAddress).isApprovedForAll(
                    order.maker,
                    address(this)
                );
        }
        return false;
    }

    // 转移钱
    function _transferValue(
        address currency,
        address from,
        address to,
        uint256 value
    ) private {
        if (value > 0) {
            // 判断是否主币
            if (currency == address(0)) {
                // payable(to).transfer(value);
                (bool success, ) = to.call{value: value}("");
                require(success, "Transfer failed.");
            } else {
                ERC20(currency).transferFrom(from, to, value);
            }
        }
    }

    // TODO remove 最新版本未使用
    function _settlement(
        Tradable.Recipient[] memory recipients,
        uint256 money,
        address buyer,
        address currency
    ) private {
        uint256 paid = 0;
        uint256 len = recipients.length;
        for (uint256 i = 0; i < len - 1; i++) {
            Tradable.Recipient memory recipient = recipients[i];
            uint256 currentFee = money.mul(recipient.points).div(100);
            _transferValue(currency, buyer, recipient.recipient, currentFee);
            paid += currentFee;
        }
        _transferValue(
            currency,
            buyer,
            address(recipients[len - 1].recipient),
            money.sub(paid)
        );
    }

    // 检测合约是否支持2981协议
    function checkRoyalties(address _contract) internal view returns (bool) {
        bool success = IERC165(_contract).supportsInterface(
            _INTERFACE_ID_ERC2981
        );
        return success;
    }

    // 转移钱
    function settlement(
        address tokenAddress,
        uint256 tokenId,
        uint256 money,
        uint256 quantity,
        address seller,
        address buyer,
        address currency,
        address serviceFeeAddress,
        uint256 serviceFeePoint
    ) public {
        // 服务费千分比 其余的百分比
        uint256 serviceFee = money.mul(serviceFeePoint).div(1000);
        _transferValue(currency, buyer, serviceFeeAddress, serviceFee);
        // 判断是否支持版税协议结算前
        if (checkRoyalties(tokenAddress)) {
            (address receiver, uint256 royaltyAmount) = IERC2981(tokenAddress)
                .royaltyInfo(tokenId, money);
            uint256 fee = money.sub(royaltyAmount).sub(serviceFee);
            _transferValue(currency, buyer, seller, fee);
            _transferValue(currency, buyer, receiver, royaltyAmount);
        } else {
            _transferValue(currency, buyer, seller, money.sub(serviceFee));

            // Tradable nft = Tradable(tokenAddress);
            // // 版税
            // uint256 fee = money.mul(nft.getSellerFeeBasisPoints()).div(100);

            // // 实际分给卖家的钱
            // uint256 receipts = money.sub(fee).sub(serviceFee);
            // // 第一次参与分成的数量（解决第一次销售多个owner问题）
            // uint256 firstAmount = nft.getFistAmount(seller, tokenId);
            // if (firstAmount >= quantity) {
            //     _settlement(nft.getSaleRecipients(), receipts, buyer, currency);
            // } else if (firstAmount > 0) {
            //     uint256 firstReceipts = receipts.div(quantity).mul(firstAmount);
            //     _settlement(
            //         nft.getSaleRecipients(),
            //         firstReceipts,
            //         buyer,
            //         currency
            //     );
            //     _transferValue(
            //         currency,
            //         buyer,
            //         seller,
            //         receipts.sub(firstReceipts)
            //     );
            // } else {
            //     _transferValue(currency, buyer, seller, receipts);
            // }
            // _settlement(nft.getFeeRecipients(), fee, buyer, currency);
        }
    }

    // 转移NFT
    function _transfer(
        address tokenAddress,
        uint256 tokenId,
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 tokenStandard = getTokenStandard(tokenAddress);
        require(tokenStandard != 0, "Not support.");
        if (tokenStandard == 721) {
            IERC721(tokenAddress).safeTransferFrom(from, to, tokenId);
        } else if (tokenStandard == 1155) {
            IERC1155(tokenAddress).safeTransferFrom(
                from,
                to,
                tokenId,
                amount,
                ""
            );
        }
    }

    // 订单执行
    function orderMatch(
        Order memory sellOrder,
        bytes memory sellerSignature,
        Order memory buyOrder,
        bytes memory buyerSignature,
        uint256 amount
    ) public payable nonReentrant {
        // 销售订单Hash
        bytes32 sellHash = hashOrder(sellOrder);
        // 买家订单Hash
        bytes32 buyHash = hashOrder(buyOrder);
        require(
            sellOrder.side == 1 || sellOrder.side == 3,
            "Order side error."
        );
        require(buyOrder.side == 2, "Order side error.");
        require(validateOrder(sellOrder, sellerSignature), "Invalid order.");
        require(!cancelledOrFinalized[sellHash], "Order already canceled.");

        require(validateOrder(buyOrder, buyerSignature), "Invalid order.");
        require(!cancelledOrFinalized[buyHash], "Order already canceled.");
        require(sellOrder.price > 0, "Invalid sell price.");
        require(
            sellOrder.serviceFeeAddress == buyOrder.serviceFeeAddress,
            "Invalid service fee address."
        );
        require(
            sellOrder.serviceFeePoint == buyOrder.serviceFeePoint,
            "Invalid service fee ponit."
        );

        if (msg.value > 0) {
            require(sellOrder.price <= msg.value.div(amount), "Invalid price");
        } else {
            require(sellOrder.price <= buyOrder.price, "Invalid price");
        }

        /* Mark previously signed or approved orders as finalized. */
        if (msg.sender != buyOrder.maker) {
            cancelledOrFinalized[buyHash] = true;
        }
        if (msg.sender != sellOrder.maker) {
            require(
                sellOrder.amount - _tradedAmounts[sellHash] >= amount,
                "Invalid amount."
            );
            if (sellOrder.amount - _tradedAmounts[sellHash] == amount) {
                cancelledOrFinalized[sellHash] = true;
            }
            _tradedAmounts[sellHash] += amount;
        }

        address currency = sellOrder.currency;
        address tokenAddress = sellOrder.tokenAddress;
        address seller = sellOrder.maker;
        uint256 tokenId = sellOrder.tokenId;
        address buyer = buyOrder.maker;
        address tokenReceiver = buyOrder.tokenReceiver != address(0x0)
            ? buyOrder.tokenReceiver
            : buyOrder.maker;
        uint256 realPrice = buyOrder.price.mul(amount);
        address serviceFeeAddress = sellOrder.serviceFeeAddress;
        uint256 serviceFeePoint = sellOrder.serviceFeePoint;
        // 结算
        settlement(
            tokenAddress,
            tokenId,
            realPrice,
            amount,
            seller,
            buyer,
            currency,
            serviceFeeAddress,
            serviceFeePoint
        );
        uint256 total = amount;
        // 转移NFT
        _transfer(tokenAddress, tokenId, seller, tokenReceiver, total);
        // 发送成交事件
        emit OrderMatched(
            sellHash,
            buyHash,
            seller,
            buyer,
            tokenReceiver,
            total,
            realPrice
        );
    }
}
