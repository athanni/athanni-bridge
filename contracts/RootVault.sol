// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

/// RootVault is a contract on Ethereum on which an ERC20 token is deposited before
/// it can be minted on Theta as TNT20 token.
contract RootVault {
    address public immutable token;

    constructor(address _token) {
        token = _token;
    }
}
