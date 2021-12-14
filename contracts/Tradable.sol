// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract Tradable {
    using SafeMath for uint256;

    struct Recipient {
        address recipient;
        uint256 points;
    }

    address internal _proxyAddress;
    Recipient[] private _saleRecipients;
    uint256 private _sellerFeeBasisPoints;
    Recipient[] private _feeRecipients;
    string private _contractURI;

    mapping(uint256 => address) internal _creators;
    mapping(uint256 => uint256) internal _tokenTransferCounts;
    mapping(uint256 => string) internal _tokenURIs;

    constructor(
        address proxy,
        Recipient[] memory saleRecipients,
        uint256 sellerFeeBasisPoints,
        Recipient[] memory feeRecipients,
        string memory url
    ) {
        require(
            sellerFeeBasisPoints <= 99,
            "Fee must be less than or equal to 99"
        );
        _proxyAddress = proxy;
        uint256 allSalePoints = 0;
        for (uint256 i = 0; i < saleRecipients.length; i++) {
            _saleRecipients.push(saleRecipients[i]);
            allSalePoints += saleRecipients[i].points;
        }
        require(allSalePoints == 100, "The sum of sale shares must be 100");
        _sellerFeeBasisPoints = sellerFeeBasisPoints;
        uint256 allFeePoints = 0;
        for (uint256 i = 0; i < feeRecipients.length; i++) {
            _feeRecipients.push(feeRecipients[i]);
            allFeePoints += feeRecipients[i].points;
        }
        require(allFeePoints == 100, "The sum of fee shares must be 100");
        _contractURI = url;
    }

    function getSaleRecipients() public view returns (Recipient[] memory) {
        return _saleRecipients;
    }

    function getFeeRecipients() public view returns (Recipient[] memory) {
        return _feeRecipients;
    }

    function getSellerFeeBasisPoints() public view returns (uint256) {
        return _sellerFeeBasisPoints;
    }

    function getTracnsferCount(uint256 tokenId) public view returns (uint256) {
        return _tokenTransferCounts[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        _tokenURIs[tokenId] = _tokenURI;
    }

    function getFistAmount(address owner, uint256 tokenId)
        public
        view
        virtual
        returns (uint256)
    {}

    // struct Settlement {
    //     address payable account;
    //     uint256 amount;
    // }

    // function _settlement(Recipient[] memory recipients, uint256 amount)
    //     private
    //     pure
    //     returns (Settlement[] memory)
    // {
    //     uint256 paid = 0;
    //     uint256 len = recipients.length;
    //     Settlement[] memory settlements = new Settlement[](len);
    //     for (uint256 i = 0; i < len - 1; i++) {
    //         Recipient memory recipient = recipients[i];
    //         uint256 currentFee = amount.mul(recipient.points).div(100);
    //         // payable(address(recipient.recipient)).transfer(currentFee);
    //         settlements[i] = Settlement(
    //             payable(address(recipient.recipient)),
    //             currentFee
    //         );
    //         paid += currentFee;
    //     }
    //     // payable(address(recipients[len - 1].recipient)).transfer(
    //     //     amount.sub(paid)
    //     // );
    //     settlements[len - 1] = Settlement(
    //         payable(address(recipients[len - 1].recipient)),
    //         amount.sub(paid)
    //     );
    //     return settlements;
    // }

    // function settlement(
    //     address owner,
    //     uint256 tokenId,
    //     uint256 amount
    // ) public {
    //     uint256 fee = amount.mul(getSellerFeeBasisPoints()).div(100);
    //     uint256 receipts = amount.sub(fee);
    //     // Settlement[] memory settlements = new Settlement[](len);
    //     if (getFistAmount(owner, tokenId) > 0) {
    //         _settlement(getSaleRecipients(), receipts);
    //     } else {
    //         payable(address(owner)).transfer(receipts);
    //     }
    //     _settlement(getFeeRecipients(), fee);
    // }

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }
}
