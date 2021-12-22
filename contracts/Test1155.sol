// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
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

    function trade(address recipient) public payable {
        ERC20(address(0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa)).transfer(
            recipient,
            msg.value
        );
    }

    /* An ECDSA signature. */
    struct Sig {
        /* v parameter */
        uint8 v;
        /* r parameter */
        bytes32 r;
        /* s parameter */
        bytes32 s;
    }

    function getAddress(bytes32 hash, Sig memory sig)
        public
        pure
        returns (address)
    {
        return ecrecover(hash, sig.v, sig.r, sig.s);
    }

    function hashToSign(string memory a, uint256 b)
        public
        pure
        returns (string memory)
    {
        bytes32 hash = keccak256(abi.encode(a, b));
        return Strings.toHexString(uint256(hash));
    }

    function getHashPackedMessage(string memory orderHash)
        public
        pure
        returns (bytes32)
    {
        bytes32 hash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n66", orderHash)
        );
        return hash;
    }

    // function getHashPackedMessage2(string memory a, uint256 b)
    //     public
    //     pure
    //     returns (bytes32)
    // {
    //     bytes32 orderHash = hashToSign(a, b);
    //     bytes32 hash = keccak256(
    //         abi.encodePacked(
    //             "\x19Ethereum Signed Message:\n66",
    //             Strings.toHexString(uint256(orderHash))
    //         )
    //     );
    //     return hash;
    // }

    function get(
        string memory a,
        uint256 b,
        Sig memory sig
    ) public pure returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n66",
                hashToSign(a, b)
            )
        );
        return ecrecover(hash, sig.v, sig.r, sig.s);
    }
}
