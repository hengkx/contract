// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Tradable.sol";

contract ERC1155Tradable is Tradable, ERC1155Pausable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIds;

    mapping(uint256 => mapping(address => uint256)) private _firstSales;

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
        ERC1155("")
    {}

    function uri(uint256 tokenId) public view override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function mint(
        address to,
        uint256 amount,
        string memory url
    ) public whenNotPaused returns (uint256) {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _mint(to, tokenId, amount, "");
        _setTokenURI(tokenId, url);
        _creators[tokenId] = to;
        _firstSales[tokenId][to] = amount;
        tokenSupply[tokenId] = amount;
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

    function pause() public virtual whenNotPaused {
        _pause();
    }

    function unpause() public virtual whenPaused {
        _unpause();
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) internal override {
        super._safeTransferFrom(from, to, tokenId, amount, data);
        _firstSales[tokenId][from] -= amount;
        _tokenTransferCounts[tokenId] += 1;
    }

    function getFistAmount(address owner, uint256 tokenId)
        public
        pure
        override
        returns (uint256)
    {
        // return _firstSales[tokenId][owner];
    }

    mapping(uint256 => uint256) public tokenSupply;

    function totalSupply(uint256 _id) public view returns (uint256) {
        return tokenSupply[_id];
    }

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        _burn(account, id, value);
        delete _creators[id];
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        _burnBatch(account, ids, values);
        for (uint256 i = 0; i < ids.length; i++) {
            delete _creators[ids[i]];
        }
    }
}
