// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Bid} from "../libraries/LibAppStorage.sol";
import {LibBidUpdate} from "../libraries/LibBidUpdate.sol";

contract BidUpdateFacet {


    function updateFirstBid(
        Bid memory lenderBid
    ) external {
        LibBidUpdate._updateFirstBid(lenderBid, block.timestamp, msg.sender);
    }
    function updateSecondBid(
        Bid memory lenderBid
    ) external {
        LibBidUpdate._updateSecondBid(lenderBid, block.timestamp, msg.sender);
    }

    function cancelFirstBid(
        uint256 _colleteralId
    )external {
        LibBidUpdate._cancelFirstBid(_colleteralId, block.timestamp, msg.sender);
    }
    function cancelSecondBid(
        uint256 _colleteralId
    )external {
        LibBidUpdate._cancelSecondBid(_colleteralId, block.timestamp, msg.sender);
    }
}