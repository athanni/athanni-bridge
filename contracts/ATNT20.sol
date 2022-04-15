// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

/// ATNT20 is a contract on the Theta chain which is a TNT20 token that represents ERC20 token/ETH
/// on Ethereum. The ATNT20 is a token that is minted 1:1 to the ERC20 token/ETH.
///
/// Note: The tokens sent to Theta are Ownable by the admin because of two reasons:
/// 1. They need to be minted on Theta after successful locking of funds in the Root/ETH Vault.
/// 2. Message passing between Root chain and Theta chain is not possible yet (or that I know of) to
///    make the transfer permissionless.
contract ATNT20 is ERC20, ERC20Burnable, Ownable {
    /// The address which transferred the amount from the Root chain against a transfer id.
    mapping(uint256 => address) public transferredBy;

    /// The address which is receiving the amount in Child chain against a transfer id.
    mapping(uint256 => address) public transferredTo;

    /// The amount that is received against a transfer id.
    mapping(uint256 => uint256) public transferredAmount;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    /// Mint the token for a given transfer id and amount to an address. This can be called
    /// only by the owner at the moment. In the future this is going to be permissionless.
    function transferTo(
        uint256 id,
        address from,
        address to,
        uint256 amount
    ) public onlyOwner {
        require(
            transferredBy[id] == address(0) && transferredTo[id] == address(0) && transferredAmount[id] == 0,
            'ATNT20: DUPLICATE_TRANSFER'
        );

        // For record keeping of who transferred how much.
        transferredBy[id] = from;
        transferredTo[id] = to;
        transferredAmount[id] = amount;
        _mint(to, amount);
    }
}
