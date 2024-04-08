// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {LibAppStorage,Collateral,AppStorage,Liquidation} from "../libraries/LibAppStorage.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IERC721} from "../interfaces/IERC721.sol";
import {LibCollateral} from "./LibCollateral.sol";
import {LibAdmin} from "./LibAdmin.sol";
import {LibPayment} from "./LibPayment.sol";

library LibLiquidation {

    event ChangedItemStatusTo(
        uint256 collateralId, 
        uint8 newStauts
    );
    
    event TransferToLiquidator(
        uint256 collateralId, 
        address liquidatorAddress,
        uint8 newStauts,
        uint256 profit
    );

    // function _encodeLiqudation(Liqudation memory liqudation) internal pure returns (bytes memory) {
    //     return abi.encode(liqudation);
    // }

    // function _decodeLiqudation(bytes memory data) internal pure returns (Liqudation memory liqudation) {
    //     (liqudation) = abi.decode(data, (Liqudation));
    // }
    
    function _getCollateralID(uint256 _collateralId) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        //bytes memory encodedData = s.idToLuqidationData[_colleteralId];
        // decode the encoded data and retrieve the APR value
        Liquidation memory decodedData = s.idToLiquidationData[_collateralId];
        return decodedData.collateralId;
    }
    function _getLiquidationType(uint256 _collateralId) internal view returns (uint8) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        //bytes memory encodedData = s.idToLuqidationData[_colleteralId];
        // decode the encoded data and retrieve the APR value
        Liquidation memory decodedData = s.idToLiquidationData[_collateralId];
        return decodedData.liquidationType;
    }
    function _getLiquidationTimestamp(uint256 _collateralId) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        //bytes memory encodedData = s.idToLuqidationData[_colleteralId];
        // decode the encoded data and retrieve the APR value
        Liquidation memory decodedData = s.idToLiquidationData[_collateralId];
        return decodedData.liquidationTimestamp;
    }
    function _getLiquidationListingPrice(uint256 _collateralId) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        //bytes memory encodedData = s.idToLuqidationData[_colleteralId];
        // decode the encoded data and retrieve the APR value
        Liquidation memory decodedData = s.idToLiquidationData[_collateralId];
        return decodedData.listingPrice;
    }

    function _changeColleteralDataLender(uint256 _collateralId)  internal{
        AppStorage storage s = LibAppStorage.diamondStorage();

        Collateral memory _collateral = s.idToCollateral[_collateralId];
        //Colleteral memory decodedData = LibColleteral._decodeColleteral(encodedData);
        _collateral.paybackDeadline = 0;
        _collateral.status = 7;
        //bytes memory _encodedData = LibColleteral._encodeColleteral(decodedData);
        s.idToCollateral[_collateralId] = _collateral;
    }
    function _changeColleteralDataLiqudationMarket(
        uint256 _collateralId,
        uint256 _timestamp
    )  internal{
        AppStorage storage s = LibAppStorage.diamondStorage();
        //bytes memory encodedData = s.idToColleretal[_collateralId];
        Collateral memory _collateral = s.idToCollateral[_collateralId];

        _collateral.status = 6;
        _collateral.paybackDeadline = 0;
        _collateral.listDeadline = _timestamp + 14 days;
        //bytes memory _encodedData = LibColleteral._encodeColleteral(decodedData);
        s.idToCollateral[_collateralId] = _collateral;
    }

    function _setLiqColleteral(
        Liquidation memory liquidationData
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        
        //bytes memory encodedData = _encodeLiqudation(liqudationData);

        //s.idToLuqidationData[liqudationData.colleteralId] = encodedData;
        
        //Liquidation memory decodedData = s.idToLuqidationData[_collateralId];
        
        if (liquidationData.liquidationType == 2) {
            {
                _changeColleteralDataLender(liquidationData.collateralId);
            }
            IERC721(LibCollateral._getCollateralAddress(liquidationData.collateralId)).transferFrom(
                s.diamondAddress,
                liquidationData.lenderAddress,
                LibCollateral._getTokenID(liquidationData.collateralId)
            );
            emit ChangedItemStatusTo(liquidationData.collateralId, 7);

        } else {
            {
                _changeColleteralDataLiqudationMarket(
                    liquidationData.collateralId,
                    liquidationData.liquidationTimestamp
                );
            }
            emit ChangedItemStatusTo(liquidationData.collateralId, 6);
        }
    }

    // function _getLiqudationData(uint256 _collateralId) internal view returns(Liqudation memory liqudation){
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     bytes memory existedLiqudation = s.idToLuqidationData[_collateralId];
    //     (liqudation) = _decodeLiqudation(existedLiqudation);
    // }


    function _verifiyTransferToLiquidator(
        uint256 _collateralId
    ) internal view {
        //AppStorage storage s = LibAppStorage.diamondStorage();
        //require(s.idToLoan[_collateralId].length >0,"P10");//Didnt finded loan"
        require(LibCollateral._getLiquidationType(_collateralId) == 1, "P11");//Item is not open for liqudator
        require(LibCollateral._getItemStatus(_collateralId) == 6, "P12");//This colleteral not liqudite
    }

    function _calculateLiquidatorTotalFee(uint256 _collateralId) internal view returns(uint256,uint256){
        uint256 artirageValue = LibAdmin._getLiquidationTresholdCollateral(_collateralId)-LibCollateral._getExpectedPrice(_collateralId);
        uint256 lender  = LibCollateral._getExpectedPrice(_collateralId)+((artirageValue*20)/100);//lender
        uint256 fee  = LibAdmin._calculateLiqudationFee(LibCollateral._getCollateralAddress(_collateralId),artirageValue);//liqudatorxs
        return (lender,fee);
    }


    function _transferToLiquidator(
        uint256 _collateralId,
        address _sender
    )internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        _verifiyTransferToLiquidator(_collateralId);
        {
            //bytes memory existedColleteral = s.idToColleretal[_collateralId];
            //Colleteral memory decodedData = LibColleteral._decodeColleteral(existedColleteral);
            Collateral memory _collateral = s.idToCollateral[_collateralId];
            _collateral.status = 9;
            //bytes memory _encodedData = LibColleteral._encodeColleteral(decodedData);
            s.idToCollateral[_collateral.collateralId] = _collateral;
        }

        (uint256 lender,uint256 fee) = _calculateLiquidatorTotalFee(_collateralId);

        
        uint256 allowance = IERC20(LibCollateral._getPaymentToken(_collateralId)).allowance(_sender, s.diamondAddress);
        require(allowance >=  LibLiquidation._getLiquidationListingPrice(_collateralId), "P013");//Check the token allowance for liqudation market

        IERC20(LibCollateral._getPaymentToken(_collateralId)).transferFrom(_sender ,LibPayment._getLenderAddress(_collateralId), lender);
        IERC20(LibCollateral._getPaymentToken(_collateralId)).transferFrom(_sender, s.diamondAddress, fee);

        IERC721(LibCollateral._getCollateralAddress(_collateralId)).transferFrom(s.diamondAddress, _sender, LibCollateral._getTokenID(_collateralId));
        
        emit TransferToLiquidator(_collateralId, _sender,9,fee);
    }
}