// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

/// ChildVault is a contract on Theta on which a TNT20 token is burnt before
/// it can be withdrawn on Ethereum as ERC20 token/ETH.
contract ChildVault {
    using Counters for Counters.Counter;

    /// The address of the token which can send to this address.
    address public immutable token;

    /// The counter to record all the deposits individually.
    Counters.Counter private _depositCounter;

    /// The mapping of deposit id and the deposit amount.
    mapping(uint256 => uint256) public depositOf;

    /// The address which receives the deposits on the other chain.
    mapping(uint256 => address) private receiverOf;

    constructor(address _token) {
        token = _token;
    }

    /// Burns the amount of tokens sent to this vault and stores the address which is
    /// going to receive the respective tokens on the other chain.
    function transferTo(uint256 amount, address receiver) public returns (uint256) {
        // Register the details of the transfer.
        uint256 id = _depositCounter.current();
        _depositCounter.increment();
        depositOf[id] = amount;
        receiverOf[id] = receiver;

        ERC20Burnable erc20 = ERC20Burnable(token);
        erc20.burnFrom(msg.sender, amount);
        return id;
    }
}
