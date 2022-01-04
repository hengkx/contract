// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MarketV2 is EIP712 {
    using SafeMath for uint256;
    using Strings for uint256;

    struct Order {
        /* Order contract address. */
        address tokenAddress;
        /* Order contract id. */
        uint256 tokenId;
        /* Order maker address. */
        address maker;
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
    }

    bytes32 constant ORDER_TYPE_HASH =
        keccak256(
            "Order(address tokenAddress,uint256 tokenId,address maker,uint256 price,uint256 amount,uint256 listingTime,uint256 expirationTime,uint256 salt)"
        );

    mapping(bytes32 => bool) _cancelOrders;
    mapping(bytes32 => uint256) _tradedAmounts;

    constructor() EIP712("Tom Xu", "1.0.0") {}

    function name() public pure returns (string memory) {
        return "Tom Xu";
    }

    function symbol() public pure returns (string memory) {
        return "hengkx";
    }

    function getTokenStandard(address tokenAddress)
        public
        view
        returns (uint256)
    {
        if (IERC721(tokenAddress).supportsInterface(0x80ac58cd)) {
            return 721;
        } else if (IERC1155(tokenAddress).supportsInterface(0xd9b67a26)) {
            return 1155;
        }
        return 0;
    }

    function hashOrder(Order memory order) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    ORDER_TYPE_HASH,
                    order.tokenAddress,
                    order.tokenId,
                    order.maker,
                    order.price,
                    order.amount,
                    order.listingTime,
                    order.expirationTime,
                    order.salt
                )
            );
    }

    function getDigest(Order memory order) public view returns (bytes32) {
        return _hashTypedDataV4(hashOrder(order));
    }

    function validateOrder(Order memory order, bytes memory signature)
        public
        view
        returns (bool)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n66",
                uint256(getDigest(order)).toHexString()
            )
        );
        return ECDSA.recover(hash, signature) == order.maker;
    }

    function cancelOrder(Order memory order, bytes memory signature) external {
        require(validateOrder(order, signature), "Invalid order");
        require(order.maker == msg.sender, "Not owner");
        _cancelOrders[hashOrder(order)] = true;
    }

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

    function trade(
        Order memory order,
        bytes memory signature,
        uint256 amount
    ) public payable {
        bytes32 hash = hashOrder(order);
        require(isApproved(order), "Not approved.");
        require(validateOrder(order, signature), "Invalid order.");
        require(order.price == msg.value.div(amount), "Invalid price.");
        require(!_cancelOrders[hash], "Order already canceled.");
        require(
            order.amount - _tradedAmounts[hash] >= amount,
            "Invalid amount."
        );
        uint256 commission = msg.value.div(100);
        payable(address(0x9454c9090074e7377ed6f8645708Dd529B3b0C15)).transfer(
            commission
        );
        payable(address(order.maker)).transfer(msg.value.sub(commission));
        _tradedAmounts[hash] += amount;
        uint256 tokenStandard = getTokenStandard(order.tokenAddress);
        if (tokenStandard == 721) {
            IERC721(order.tokenAddress).safeTransferFrom(
                order.maker,
                msg.sender,
                order.tokenId
            );
        } else if (tokenStandard == 1155) {
            IERC1155(order.tokenAddress).safeTransferFrom(
                order.maker,
                msg.sender,
                order.tokenId,
                amount,
                ""
            );
        }
    }
}
