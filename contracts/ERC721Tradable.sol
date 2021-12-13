// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721Tradable is ERC721Pausable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIds;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => address) private _creators;
    mapping(uint256 => uint256) private _tokenTransferCounts;

    struct Recipient {
        address recipient;
        uint256 points;
    }

    address private _proxyAddress;
    Recipient[] private _saleRecipients;
    uint256 private _sellerFeeBasisPoints;
    Recipient[] private _feeRecipients;
    string private _contractURI;

    constructor(
        address proxy,
        Recipient[] memory saleRecipients,
        uint256 sellerFeeBasisPoints,
        Recipient[] memory feeRecipients,
        string memory url
    ) ERC721("NFT", "hengkx") {
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

    function getCreator(uint256 tokenId) public view returns (address) {
        return _creators[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        _tokenURIs[tokenId] = _tokenURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        string memory _tokenURI = _tokenURIs[tokenId];
        return _tokenURI;
    }

    function mint(address recipient, string memory uri)
        public
        whenNotPaused
        returns (uint256)
    {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _mint(recipient, tokenId);
        _setTokenURI(tokenId, uri);
        _creators[tokenId] = recipient;
        return tokenId;
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        override
        returns (bool)
    {
        if (_proxyAddress == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    function burn(uint256 tokenId) public virtual whenNotPaused {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Burnable: caller is not owner nor approved"
        );
        _burn(tokenId);
        delete _creators[tokenId];
    }

    function pause() public virtual whenNotPaused {
        _pause();
    }

    function unpause() public virtual whenPaused {
        _unpause();
    }

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        super._transfer(from, to, tokenId);
        _tokenTransferCounts[tokenId] += 1;
    }

    function getTracnsferCount(uint256 tokenId) public view returns (uint256) {
        return _tokenTransferCounts[tokenId];
    }
}
