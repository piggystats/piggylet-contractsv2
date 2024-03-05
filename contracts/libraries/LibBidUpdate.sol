// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {LibAppStorage,AppStorage, Collateral,Loan, Bid} from "../libraries/LibAppStorage.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {LibCollateral} from "./LibCollateral.sol";
import {LibAdmin} from "./LibAdmin.sol";
import {LibBid} from "./LibBid.sol";
import {LibFloorPrice} from "../libraries/LibFloorPrice.sol";


library LibBidUpdate {
    event BidUpdated(
        uint256 collateralID,
        uint256 index,
        Bid bidInfo
    );


    event BidCancelled(
        uint256 collateralID,
        address lenderAddress,
        uint256 index
    );


    function _cancelFirstBid(
        uint256 _collateralId,
        uint256 _timestamp,
        address _sender
    )internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(LibBid._getFirstBidLenderAddress(_collateralId,_sender) == _sender,"B012");//You cant cancel this bid
        require(_timestamp <=LibBid._getFirstBidListDeadline(_collateralId, _sender),"B013");//this bid because its not usable
        delete s.idToFirstBid[_collateralId][_sender];
        emit BidCancelled(_collateralId,_sender, 0);
    }
    function _cancelSecondBid(
        uint256 _collateralId,
        uint256 _timestamp,
        address _sender
    )internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(LibBid._getSecondBidLenderAddress(_collateralId,_sender) == _sender,"B012");
        require(_timestamp <=LibBid._getSecondBidListDeadline(_collateralId, _sender),"B013"); 
        delete s.idToSecondBid[_collateralId][_sender];
        emit BidCancelled(_collateralId, _sender,1);
    }

     function _verifiyUpdate(
        Bid memory lenderBid,
        uint256 _timestamp,
        address _sender
    )internal view returns(Bid memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(LibAdmin._getApprovedToken(lenderBid.paymentTokenAddress),"B008");
        require(lenderBid.paybackDeadline <= 90 , "B018");//Deadine should be less than 90 days 
        require(lenderBid.bidListDeadline <= 30, "B019");//List deadline should be less than 30 days 
        require(lenderBid.bidListDeadline >= 7, "B020");//List deadline should be more than 7 days 
        require(lenderBid.apr > 0, "B021");//APR Must be greater than zero"
        require(_sender == lenderBid.lenderAddress, "B015");//this address cant update bid
        uint256 allowance = IERC20(lenderBid.paymentTokenAddress).allowance(_sender, s.diamondAddress);
        require(allowance >= lenderBid.maxPayedAmount, "B016");//Check the token allowance for bid

        uint256 expectedPrice = LibBid._checkPrice(LibCollateral._getCollateralAddress(lenderBid.collateralId), lenderBid.maxPayedAmount,lenderBid.paymentTokenAddress);
        lenderBid.maxPayedAmount = expectedPrice;
        lenderBid.bidListDeadline = _timestamp + (lenderBid.bidListDeadline * 86400 seconds);
        return lenderBid;
    }

    function _updateFirstBid(
        Bid memory lenderBid,
        uint256 _timestamp,
        address _sender
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        Bid memory verifiedBid = _verifiyUpdate(lenderBid, _timestamp, _sender);

        Bid memory decodedData = s.idToFirstBid[lenderBid.collateralId][_sender];
        require(decodedData.collateralId == verifiedBid.collateralId,"B017");//id missmatch
        
        
        //bytes memory _newBid = LibBid._encodeBid(verifiedBid);
        s.idToFirstBid[verifiedBid.collateralId][_sender] = verifiedBid;

        emit BidUpdated(lenderBid.collateralId, 0,verifiedBid);
    }

    function _updateSecondBid(
        Bid memory lenderBid,
        uint256 _timestamp,
        address _sender
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        Bid memory verifiedBid = _verifiyUpdate(lenderBid, _timestamp, _sender);
        Bid memory decodedData =  s.idToSecondBid[lenderBid.collateralId][_sender];

        require(decodedData.collateralId == verifiedBid.collateralId,"B017");

        
        //bytes memory _newBid = LibBid._encodeBid(verifiedBid);
        s.idToSecondBid[verifiedBid.collateralId][_sender] = verifiedBid;

        emit BidUpdated(lenderBid.collateralId,1, verifiedBid);
    }
}