// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Loan,Bid} from "../libraries/LibAppStorage.sol";
import {LibBid} from "../libraries/LibBid.sol";
import {LibBidAccept} from "../libraries/LibBidAccept.sol";


contract BidFacet {

    function createBid(
        Bid memory lenderBid
    ) external {
        LibBid._createBid(lenderBid, block.timestamp, msg.sender);
    }

    function createBidBundle(
        Bid[] memory lenderBid
    ) external {
        require(lenderBid.length==5,"5 item");
        for (uint256 i = 0; i < lenderBid.length; i++){
            LibBid._createBid(lenderBid[i], block.timestamp, msg.sender);
        }
    }

    function acceptBid(
        Loan memory lendersLoan,
        uint256 _index
    ) external  {
        if(_index == 0){
            LibBidAccept._acceptFirstBid(lendersLoan, block.timestamp);
        }
        else if(_index == 1){
            LibBidAccept._acceptSecondBid(lendersLoan, block.timestamp);
        }
    }

}