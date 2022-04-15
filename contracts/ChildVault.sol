// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './ATNT20.sol';

/// ChildVault is a contract on Theta on which a TNT20 token is burnt before
/// it can be withdrawn on Ethereum as ERC20 token/ETH.
///
/// Note: The tokens can be minted by the Owner of Child Vault because of two reasons:
/// 1. They need to be minted on Theta after successful locking of funds in the Root/ETH Vault.
/// 2. Message passing between Root chain and Child chain is not possible/difficult (or that I know of) to
///    make the transfer permissionless.
contract ChildVault is Ownable {
    using Counters for Counters.Counter;

    /// The direction in which a token is transferred to or out the vault.
    enum TransferDirection {
        IN,
        OUT
    }

    /// The counter to record all the deposits individually.
    Counters.Counter private _depositCounter;

    /// The address of the TNT20 token that is transferred against a transfer id.
    mapping(uint256 => address) public tokenAddress;

    /// The direction of transfer against a transfer id.
    mapping(uint256 => TransferDirection) public transferDirection;

    /// The address which transferred the amount against a transfer id.
    mapping(uint256 => address) public transferredBy;

    /// The address which is receiving the amount against a transfer id.
    mapping(uint256 => address) public transferredTo;

    /// The amount that is received against a transfer id.
    mapping(uint256 => uint256) public transferredAmount;

    /// The uint256 id used in the above mapping is generated using the counter when withdrawing
    /// funds out of this contract. And for funds sent from Root network to this Child network
    /// the id is sent from the Root network. So, to store the external id without it conflicting
    /// with the id generated here, a parition is needed. The following value is added to the external
    /// id before storing.
    /// This results: the id value is uint255 in reality.
    uint256 private immutable _parition = 1 << 255;

    /// Mints the token of a given type and sends it. Only run this once respective token
    /// is locked on the Root/ETH vault.
    function send(
        address token,
        /// The id works a nonce and is used to keep a 1-to-1 record of transfer against a RootVault.
        uint256 _id,
        address from,
        address to,
        uint256 amount
    ) public onlyOwner {
        require(amount > 0, 'ChildVault: ZERO_SEND');

        // Add the partition.
        uint256 id = _id + _parition;

        require(
            tokenAddress[id] == address(0) &&
                transferredBy[id] == address(0) &&
                transferredTo[id] == address(0) &&
                transferredAmount[id] == 0,
            'ATNT20: DUPLICATE_TRANSFER'
        );

        tokenAddress[id] = token;
        transferDirection[id] = TransferDirection.IN;
        transferredBy[id] = from;
        transferredTo[id] = to;
        transferredAmount[id] = amount;
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
        require(amount > 0, 'ChildVault: ZERO_WITHDRAW');

        // Register the details of the transfer.
        uint256 id = _depositCounter.current();
        _depositCounter.increment();
        tokenAddress[id] = token;
        transferDirection[id] = TransferDirection.OUT;
        transferredBy[id] = msg.sender;
        transferredTo[id] = to;
        transferredAmount[id] = amount;

        ERC20Burnable erc20 = ERC20Burnable(token);
        erc20.burnFrom(msg.sender, amount);
        return id;
    }
}
