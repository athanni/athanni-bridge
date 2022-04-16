// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import './Portal.sol';

/// RootPortal serves as gateway on Ethereum that connects into Theta.
contract RootPortal is Portal {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;

    /// Deposits the amount of tokens to this portal and stores the address which is
    /// going to receive the respective tokens on the other chain.
    function send(
        address token,
        address to,
        uint256 amount
    ) public returns (uint256) {
        require(amount > 0, 'RootPortal: ZERO_SEND');

        // Register the details of the transfer.
        uint256 id = _counter.current();
        _counter.increment();
        store(id, token, msg.sender, to, amount);

        IERC20 erc20 = IERC20(token);
        erc20.safeTransferFrom(msg.sender, address(this), amount);
        return id;
    }

    /// Deposits ETH to this portal and stores the address which is going to receive the
    /// respective token on the other chain.
    function sendETH(address to) public payable returns (uint256) {
        uint256 amount = msg.value;
        require(amount > 0, 'RootPortal: ZERO_SEND');

        // Register the details of the transfer.
        uint256 id = _counter.current();
        _counter.increment();

        // Because ETH is not a ERC20 token, we need another unique address to record this transfer.
        // Address of this contract itself works.
        address token = address(this);
        store(id, token, msg.sender, to, amount);
        return id;
    }

    /// Withdraws the tokens from the portal after it has been verified that respective tokens
    /// were burnt on the other end of the portal.
    function withdraw(
        address token,
        /// The id works a nonce and is used to keep a 1-to-1 record of transfer against the Child Portal.
        uint256 _id,
        address from,
        address to,
        uint256 amount
    ) public onlyOwner {
        require(amount > 0, 'RootPortal: ZERO_WITHDRAW');
        // Add the partition.
        uint256 id = _partitionedId(_id);
        store(id, token, from, to, amount);

        IERC20 erc20 = IERC20(token);
        erc20.safeTransfer(to, amount);
    }

    /// Withdraws ETH from the portal after it has been verified that respective tokens were burnt on the other
    /// end of the portal.
    function withdrawETH(
        uint256 _id,
        address from,
        address to,
        uint256 amount
    ) public onlyOwner {
        require(amount > 0, 'RootPortal: ZERO_WITHDRAW');
        // Add the partition.
        uint256 id = _partitionedId(_id);

        /// ETH is not a ERC20 token so use this contract's address itself for the record.
        address token = address(this);
        store(id, token, from, to, amount);

        address payable receiver = payable(to);
        (bool sent, ) = receiver.call{value: amount}('');
        require(sent, 'RootPortal: ETH_WITHDRAW_FAILED');
    }
}
