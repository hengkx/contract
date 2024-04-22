// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * 代理合约注册
 */
contract ProxyRegistry is Ownable {
    mapping(address => bool) public proxies;

    /**
     * @dev Allows owner to add a shared proxy address
     */
    function addProxyAddress(address _address) public onlyOwner {
        proxies[_address] = true;
    }

    /**
     * @dev Allows owner to remove a shared proxy address
     */
    function removeProxyAddress(address _address) public onlyOwner {
        delete proxies[_address];
    }
}
