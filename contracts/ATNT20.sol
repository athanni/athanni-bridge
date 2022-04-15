// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

/// ATNT20 is a contract on the Theta chain which is a TNT20 token that represents ERC20 token/ETH
/// on Ethereum. The ATNT20 is a token that is minted 1:1 to the ERC20 token/ETH.
contract ATNT20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}
}
