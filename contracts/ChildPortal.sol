// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';
import './Portal.sol';
import './ATNT20.sol';

/// ChildPortal serves as a gateway on Theta network that connects into Ethereum.
contract ChildPortal is Portal {
    using Counters for Counters.Counter;

    /// Mints the token of a given type and sends it. Only run this once respective token
    /// is locked on the Root Portal.
    ///
    /// Note: The tokens can be minted by the owner of Child Portal because of two reasons:
    /// 1. They need to be minted on Theta after successful locking of funds in the Root Portal.
    /// 2. Message passing between Ethereum and Theta is difficult at best at the moment (afaik) to
    ///    make the transfer permissionless.
    function send(
        address token,
        /// The id works a nonce and is used to keep a 1-to-1 record of transfer against the Root Portal.
        uint256 _id,
        address from,
        address to,
        uint256 amount
    ) public onlyOwner {
        require(amount > 0, 'ChildPortal: ZERO_SEND');
        // Add the partition.
        uint256 id = _partitionedId(_id);
        store(id, token, from, to, amount);

        ATNT20 tnt = ATNT20(token);
        tnt.mint(to, amount);
    }

    /// Burns the amount of tokens sent to this vault and stores the address which is
    /// going to receive the respective tokens on the root chain.
    function withdraw(
        address token,
        address to,
        uint256 amount
    ) public returns (uint256) {
        require(amount > 0, 'ChildPortal: ZERO_WITHDRAW');

        // Register the details of the transfer.
        uint256 id = _counter.current();
        _counter.increment();
        store(id, token, msg.sender, to, amount);

        ERC20Burnable erc20 = ERC20Burnable(token);
        erc20.burnFrom(msg.sender, amount);
        return id;
    }
}
