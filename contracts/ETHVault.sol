// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/utils/Counters.sol';

/// ETHVault is a contract on Ethereum on which ETH is deposited before it can be
/// minted on Theta as TNT20 token.
contract ETHVault {
    using Counters for Counters.Counter;

    /// The counter to record all the deposits individually.
    Counters.Counter private _depositCounter;

    /// The mapping of deposit id and the deposit amount.
    mapping(uint256 => uint256) private _deposits;

    /// The address which receives the deposits on the other chain.
    mapping(uint256 => address) private _receivers;

    /// Deposits the amount of ETH to this vault and stores the address which is
    /// going to receive the respective tokens on the other chain.
    function transferTo(address receiver) public payable returns (uint256) {
        uint256 amount = msg.value;

        // Register the details of the transfer.
        uint256 id = _depositCounter.current();
        _depositCounter.increment();
        _deposits[id] = amount;
        _receivers[id] = receiver;

        return id;
    }
}
