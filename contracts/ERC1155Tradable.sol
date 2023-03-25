// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import "./Tradable.sol";
import "./ProxyRegistry.sol";

contract ERC1155Tradable is
    Tradable,
    ERC1155Pausable,
    DefaultOperatorFilterer,
    Ownable
{
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIds;

    mapping(uint256 => mapping(address => uint256)) private _firstSales;

    string private _name;
    string private _symbol;

    constructor(
        string memory name_,
        string memory symbol_,
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
    {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function mint(
        uint256 tokenId,
        address to,
        uint256 amount,
        string memory url
    ) public whenNotPaused onlyOwner returns (uint256) {
        _mint(to, tokenId, amount, "");
        _setTokenURI(tokenId, url);
        _creators[tokenId] = to;
        _firstSales[tokenId][to] = amount;
        tokenSupply[tokenId] = amount;
        return tokenId;
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view override returns (bool) {
        ProxyRegistry proxyRegistry = ProxyRegistry(_proxyAddress);
        if (proxyRegistry.proxies(operator)) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    function pause() public virtual onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public virtual onlyOwner whenPaused {
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
        if (_creators[tokenId] == from) {
            if (_firstSales[tokenId][from] >= amount) {
                _firstSales[tokenId][from] -= amount;
            } else {
                _firstSales[tokenId][from] = 0;
            }
        }
    }

    function getFistAmount(
        address owner,
        uint256 tokenId
    ) public view override returns (uint256) {
        return _firstSales[tokenId][owner];
    }

    mapping(uint256 => uint256) public tokenSupply;

    function totalSupply(uint256 _id) public view returns (uint256) {
        return tokenSupply[_id];
    }

    function burn(address account, uint256 id, uint256 value) public {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _burn(account, id, value);
        tokenSupply[id] -= value;
        if (tokenSupply[id] == 0) {
            delete _tokenURIs[id];
        }
        delete _creators[id];
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _burnBatch(account, ids, values);
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            delete _creators[ids[i]];
            tokenSupply[id] -= values[i];
            if (tokenSupply[id] == 0) {
                delete _tokenURIs[id];
            }
        }
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override onlyAllowedOperator(from) {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}
