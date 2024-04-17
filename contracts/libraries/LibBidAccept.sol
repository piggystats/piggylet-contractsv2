// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {LibAppStorage,AppStorage, Collateral,Loan, Bid} from "../libraries/LibAppStorage.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {LibCollateral} from "./LibCollateral.sol";
import {LibAdmin} from "./LibAdmin.sol";
import {LibPayment} from "./LibPayment.sol";
import {LibBid} from "../libraries/LibBid.sol";

library LibBidAccept {

    event BidAccepted(
        uint256 collateralId,
        address lenderAddress,
        uint256 index,
        uint256 treshold,
        uint256 profit
    );

    function _verifiyBidAccept(
        Loan memory lendersLoan,
        Bid memory lenderBid,
        uint256 _timestamp
    )internal view {
        require(_timestamp <= LibCollateral._getListDeadline(lenderBid.collateralId), "B11");//ListDeadline
        require(LibCollateral._getItemStatus(lenderBid.collateralId) != 5,"B12");//already finded loann
        require(lendersLoan.collateralId == lenderBid.collateralId,"B13");//id not same
        require(lendersLoan.lenderAddress == lenderBid.lenderAddress,"B14");//lender address not same
        require(lendersLoan.liquidationType == lenderBid.liquidationType,"B15");//lender address not same
        //lender address not same
        //LibBid._checkPrice(LibCollateral._getCollateralAddress(lenderBid.collateralId), lenderBid.maxPayedAmount,lenderBid.paymentTokenAddress);
    }

    function _acceptFirstBid(
        Loan memory lendersLoan,
        uint256 _timestamp
    )internal{
        AppStorage storage s = LibAppStorage.diamondStorage();
 
        Bid memory lenderBid = s.idToFirstBid[lendersLoan.collateralId][lendersLoan.lenderAddress];

        _verifiyBidAccept(lendersLoan,lenderBid, _timestamp);
        {
            //bytes memory encodedColleteral= s.idToColleretal[lenderBid.collateralId];
            Collateral storage _collateral = s.idToCollateral[lendersLoan.collateralId];
            
            _collateral.paybackDay = lenderBid.paybackDeadline; //LibBid._getFirstBidPaybackDeadline(lenderBid.collateralId,lenderBid.lenderAddress);
            _collateral.paybackDeadline = lenderBid.paybackDeadline; //LibBid._getFirstBidPaybackDeadline(lenderBid.collateralId,lenderBid.lenderAddress);
            _collateral.apr = lenderBid.apr;//LibBid._getFirstBidApr(lenderBid.collateralId,lenderBid.lenderAddress);
            _collateral.liquidationType = lenderBid.liquidationType;//LibBid._getFirstBidLiqudationType(lenderBid.collateralId,lenderBid.lenderAddress);
            _collateral.paymentToken = lenderBid.paymentTokenAddress;//LibBid._getFirstBidPaymentTokenAddress(lenderBid.collateralId,lenderBid.lenderAddress);
            _collateral.expectedPrice = lenderBid.maxPayedAmount; //LibBid._getFirstBidMaxPayedAmount(lenderBid.collateralId,lenderBid.lenderAddress);
            
            //bytes memory newEncodedColleteral = LibCollateral._encodeColleteral(decodedData);
            //s.idToCollateral[lendersLoan.collateralId] = _collateral;
        }

        (uint256 profit,uint256 tresh) = LibPayment._acceptBid(lendersLoan, _timestamp);

        emit BidAccepted(
            lendersLoan.collateralId,
            lendersLoan.lenderAddress,
            0,
            tresh,
            profit
        );
    }

    function _acceptSecondBid(
        Loan memory lendersLoan,//colleteral id lenderaddress
        uint256 _timestamp
    )internal{
        AppStorage storage s = LibAppStorage.diamondStorage();

        Bid memory lenderBid = s.idToSecondBid[lendersLoan.collateralId][lendersLoan.lenderAddress];

        _verifiyBidAccept(lendersLoan,lenderBid, _timestamp);

        {
            Collateral storage _collateral = s.idToCollateral[lendersLoan.collateralId];
            _collateral.paybackDay = lenderBid.paybackDeadline;//LibBid._getSecondBidPaybackDeadline(lenderBid.collateralId,lenderBid.lenderAddress);
            _collateral.paybackDeadline = lenderBid.paybackDeadline; //LibBid._getSecondBidPaybackDeadline(lenderBid.collateralId,lenderBid.lenderAddress);
            _collateral.apr = lenderBid.apr;//LibBid._getSecondBidApr(lenderBid.collateralId,lenderBid.lenderAddress);
            _collateral.liquidationType =  lenderBid.liquidationType;//LibBid._getSecondBidLiqudationType(lenderBid.collateralId,lenderBid.lenderAddress);
            _collateral.paymentToken = lenderBid.paymentTokenAddress; //LibBid._getSecondBidPaymentTokenAddress(lenderBid.collateralId,lenderBid.lenderAddress);
            _collateral.expectedPrice = lenderBid.maxPayedAmount;//LibBid._getSecondBidMaxPayedAmount(lenderBid.collateralId,lenderBid.lenderAddress);
            //bytes memory newEncodedColleteral = LibCollateral._encodeColleteral(decodedData);
            //s.idToCollateral[lendersLoan.collateralId] = _collateral;
        }
        
        (uint256 profit,uint256 tresh) = LibPayment._acceptBid(lendersLoan, _timestamp);

        
        emit BidAccepted(
            lendersLoan.collateralId,
            lendersLoan.lenderAddress,
            1,
            tresh,
            profit
        );
    }
}