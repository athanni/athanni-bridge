// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

/// Portal is wormhole which receives tokens on one end in a network and ejects tokens on the
/// other end on a different network.
abstract contract Portal is Ownable {
    using Counters for Counters.Counter;

    /// The counter for transfer id.
    Counters.Counter internal _counter;

    /// The address of the TNT20 token that is transferred against a transfer id.
    mapping(uint256 => address) public tokenAddress;

    /// The address which transferred the amount against a transfer id.
    mapping(uint256 => address) public transferredBy;

    /// The address which is receiving the amount against a transfer id.
    mapping(uint256 => address) public transferredTo;

    /// The amount that is received against a transfer id.
    mapping(uint256 => uint256) public transferredAmount;

    /// The uint256 id used in the above mapping. There are two ways in which ids are used. It can
    /// either be generated within this portal or is generated on another portal. A portal always
    /// has a unique linked portal on the other end. To separate the id generated in this portal from
    /// ids generated on another, this partition is used.
    /// The result: the id value is uint255 in reality.
    uint256 private immutable _parition = 1 << 255;

    /// Get the partitioned id of an external id.
    function _partitionedId(uint256 id) internal pure returns (uint256) {
        return id + _parition;
    }

    /// Store the record of transfer.
    function store(
        uint256 id,
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        require(
            tokenAddress[id] == address(0) &&
                transferredBy[id] == address(0) &&
                transferredTo[id] == address(0) &&
                transferredAmount[id] == 0,
            'Portal: DUPLICATE_TRANSFER'
        );

        tokenAddress[id] = token;
        transferredBy[id] = from;
        transferredTo[id] = to;
        transferredAmount[id] = amount;
    }
}
