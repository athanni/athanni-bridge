// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

/// RootVault is a contract on Ethereum on which an ERC20 token is deposited before
/// it can be minted on Theta as TNT20 token.
contract RootVault {
    using Counters for Counters.Counter;

    /// The address of the token which can send to this address.
    address public immutable token;

    /// The counter to record all the deposits individually.
    Counters.Counter private _depositCounter;

    /// The mapping of deposit id and the deposit amount.
    mapping(uint256 => uint256) private _deposits;

    /// The address which receives the deposits on the other chain.
    mapping(uint256 => address) private _receivers;

    constructor(address _token) {
        token = _token;
    }

    /// Deposits the amount of tokens to this vault and stores the address which is
    /// going to receive the respective tokens on the other chain.
    function transferTo(uint256 amount, address receiver) public returns (uint256) {
        // Register the details of the transfer.
        uint256 id = _depositCounter.current();
        _depositCounter.increment();
        _deposits[id] = amount;
        _receivers[id] = receiver;

        IERC20 erc20 = IERC20(token);
        bool transferred = erc20.transferFrom(msg.sender, address(this), amount);
        require(transferred, 'RootVault: TRANSFER_FAILED');
        return id;
    }
}
