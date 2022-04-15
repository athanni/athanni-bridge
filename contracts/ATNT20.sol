// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';

/// ATNT20 is a contract on the Theta chain which is a TNT20 token that represents ERC20 token/ETH
/// on Ethereum. The ATNT20 is a token that is minted 1:1 to the ERC20 token/ETH.
contract ATNT20 is ERC20, ERC20Burnable {
    /// The address of the Child Vault. Only the vault can mint a token.
    address public immutable vault;

    constructor(
        address _vault,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        vault = _vault;
    }

    /// Mint a token when requested by the Child Vault.
    function mint(address to, uint256 amount) public {
        require(msg.sender == vault, 'ATNT20: UNAUTHORIZED');
        _mint(to, amount);
    }
}
