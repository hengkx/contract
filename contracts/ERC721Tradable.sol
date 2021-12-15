// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Tradable.sol";

contract ERC721Tradable is Tradable, ERC721Pausable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIds;
    mapping(uint256 => uint256) private _firstSales;

    constructor(
        address proxy,
        Recipient[] memory saleRecipients,
        uint256 sellerFeeBasisPoints,
        Recipient[] memory feeRecipients,
        string memory url
    )
        Tradable(
            proxy,
            saleRecipients,
            sellerFeeBasisPoints,
            feeRecipients,
            url
        )
        ERC721("NFT", "hengkx")
    {}

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

    function mint(address to, string memory uri)
        public
        whenNotPaused
        returns (uint256)
    {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _creators[tokenId] = to;
        _firstSales[tokenId] = 1;
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

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        super._transfer(from, to, tokenId);
        _firstSales[tokenId] = 0;
    }

    function getFistAmount(address, uint256 tokenId)
        public
        view
        override
        returns (uint256)
    {
        return _firstSales[tokenId];
    }
}
