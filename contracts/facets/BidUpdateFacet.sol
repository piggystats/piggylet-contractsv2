// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Bid} from "../libraries/LibAppStorage.sol";
import {LibBidUpdate} from "../libraries/LibBidUpdate.sol";

contract BidUpdateFacet {

    function updateBid(
        Bid memory lenderBid,
        uint256 _index
    ) external {
        if(_index == 0){
            LibBidUpdate._updateFirstBid(lenderBid, block.timestamp, msg.sender);
        }
        else if(_index == 1){
            LibBidUpdate._updateSecondBid(lenderBid, block.timestamp, msg.sender);
        }
    
    }
    // function updateSecondBid(
    //     Bid memory lenderBid
    // ) external {
    //     LibBidUpdate._updateSecondBid(lenderBid, block.timestamp, msg.sender);
    // }

    // function updateFirstBid(
    //     Bid memory lenderBid
    // ) external {
    //     LibBidUpdate._updateFirstBid(lenderBid, block.timestamp, msg.sender);
    // }
    // function updateSecondBid(
    //     Bid memory lenderBid
    // ) external {
    //     LibBidUpdate._updateSecondBid(lenderBid, block.timestamp, msg.sender);
    // }


    function cancelBid(
        uint256 _colleteralId,
        uint256 _index
    )external {
        if(_index == 0){
            LibBidUpdate._cancelFirstBid(_colleteralId, block.timestamp, msg.sender);
        }
        else if(_index == 1){
            LibBidUpdate._cancelSecondBid(_colleteralId, block.timestamp, msg.sender);
        }
    }
    // function cancelFirstBid(
    //     uint256 _colleteralId
    // )external {
    //     LibBidUpdate._cancelFirstBid(_colleteralId, block.timestamp, msg.sender);
    // }
    // function cancelSecondBid(
    //     uint256 _colleteralId
    // )external {
    //     LibBidUpdate._cancelSecondBid(_colleteralId, block.timestamp, msg.sender);
    // }
}