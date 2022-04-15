// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

/// ChildVault is a contract on Theta on which a TNT20 token is burnt before
/// it can be withdrawn on Ethereum as ERC20 token/ETH.
contract ChildVault {
    address public immutable token;

    constructor(address _token) {
        token = _token;
    }
}
