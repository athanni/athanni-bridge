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
        // Register the details of the transfer.
        uint256 id = _counter.current();
        _counter.increment();
        store(id, token, msg.sender, to, TransferDirection.OUT, amount);

        IERC20 erc20 = IERC20(token);
        erc20.safeTransferFrom(msg.sender, address(this), amount);
        return id;
    }

    /// Deposits ETH to this portal and stores the address which is going to receive the
    /// respective token on the other chain.
    function sendETH(address to, uint256 amount) public payable returns (uint256) {
        // Register the details of the transfer.
        uint256 id = _counter.current();
        _counter.increment();

        // Because ETH is not a ERC20 token, we need another unique address to record this transfer.
        // Address of this contract itself works.
        address token = address(this);
        store(id, token, msg.sender, to, TransferDirection.OUT, amount);
        return id;
    }
}
