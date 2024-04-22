// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * NFT基类
 */
abstract contract Tradable {
    using SafeMath for uint256;

    struct Recipient {
        // 接收者地址
        address recipient;
        // 分成比例
        uint256 points;
    }

    // 代理合约地址
    address internal _proxyAddress;
    // 卖家分成比例
    Recipient[] private _saleRecipients;
    // 卖家分成比例
    uint256 private _sellerFeeBasisPoints;
    // 手续费分成比例
    Recipient[] private _feeRecipients;
    // 合约元数据链接
    string private _contractURI;

    // NFT对应的铸造者
    mapping(uint256 => address) internal _creators;
    // NFT对应的元数据链接
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

    function getProxyAddress() public view returns (address) {
        return _proxyAddress;
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

    /**
     * 设置NFT的元数据链接
     */
    function _setTokenURI(
        uint256 tokenId,
        string memory _tokenURI
    ) internal virtual {
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * 获取第一次销售分成的数量
     */
    function getFistAmount(
        address owner,
        uint256 tokenId
    ) public view virtual returns (uint256);

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }
}
