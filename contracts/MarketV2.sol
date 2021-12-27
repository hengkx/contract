// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MarketV2 {
    using SafeMath for uint256;
    using Strings for uint256;

    struct Order {
        /* Order contract address. */
        address tokenAddress;
        /* Order contract id. */
        uint256 tokenId;
        /* Order token type 721 or 1155. */
        uint256 tokenType;
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

    mapping(bytes32 => bool) _cancelOrders;
    mapping(bytes32 => uint256) _tradedAmounts;

    function name() public pure returns (string memory) {
        return "Tom Xu";
    }

    function symbol() public pure returns (string memory) {
        return "hengkx";
    }

    function hashToSign(Order memory order) public pure returns (bytes32) {
        bytes32 hash = keccak256(
            abi.encode(
                order.tokenAddress,
                order.tokenId,
                order.tokenType,
                order.maker,
                order.price,
                order.amount,
                order.listingTime,
                order.expirationTime,
                order.salt
            )
        );
        return hash;
        // return uint256(hash).toHexString();
    }

    struct Sig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function validateOrder(Order memory order, Sig memory sig)
        public
        pure
        returns (bool)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n66",
                uint256(hashToSign(order)).toHexString()
            )
        );
        return ecrecover(hash, sig.v, sig.r, sig.s) == order.maker;
    }

    function cancelOrder(Order memory order, Sig memory sig) external {
        require(validateOrder(order, sig), "Invalid order");
        require(order.maker == msg.sender, "Not owner");
        _cancelOrders[hashToSign(order)] = true;
    }

    function isApproved(Order memory order) public view returns (bool) {
        if (order.tokenType == 721) {
            return
                IERC721(order.tokenAddress).getApproved(order.tokenId) ==
                address(this) ||
                IERC721(order.tokenAddress).isApprovedForAll(
                    order.maker,
                    address(this)
                );
        } else if (order.tokenType == 1155) {
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
        Sig memory sig,
        uint256 amount
    ) public payable {
        bytes32 hash = hashToSign(order);
        require(isApproved(order), "Not approved");
        require(validateOrder(order, sig), "Invalid order");
        require(order.price == msg.value.div(amount), "Invalid price");
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
        if (order.tokenType == 721) {
            IERC721(order.tokenAddress).getApproved(order.tokenId);
            IERC721(order.tokenAddress).safeTransferFrom(
                order.maker,
                msg.sender,
                order.tokenId
            );
        } else if (order.tokenType == 1155) {
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
