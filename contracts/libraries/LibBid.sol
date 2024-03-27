// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {LibAppStorage,AppStorage, Collateral,Loan, Bid } from "../libraries/LibAppStorage.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {LibCollateral} from "./LibCollateral.sol";
import {LibAdmin} from "./LibAdmin.sol";
import {LibPayment} from "./LibPayment.sol";
import {LibFloorPrice} from "../libraries/LibFloorPrice.sol";


library LibBid {
    
    // struct DiamondStorage {
    //     mapping (uint256 => mapping(address => bytes)) idToFirstBid;
    //     mapping (uint256 => mapping(address => bytes)) idToSecondBid;
    //     // ... any number of other state variables
    // }

    // // return a struct storage pointer for accessing the state variables
    // function diamondStorage() internal pure returns (DiamondStorage storage ds) {
    //     bytes32 position = keccak256("diamond.standard.diamond.storage");
    //     assembly {
    //         ds.slot := position
    //     }
    // }

    event FirstBidCreated(
        Bid bidInfo
    );
    event SecondBidCreated(
        Bid bidInfo
    );

    

    // //Encode - Decode
    // function _encodeBid(Bid memory lenderBid) internal pure returns (bytes memory) {
    //     return abi.encode(lenderBid);
    // }

    // function _decodeBid(bytes memory data) internal pure returns (Bid memory lenderBid) {
    //     (lenderBid) = abi.decode(data, (Bid));
    // }

    //Helper First Bid

    function _getFirstBidLenderAddress(uint256 _collateralId,address _sender) internal view returns (address) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Bid memory decodedFirstBid = s.idToFirstBid[_collateralId][_sender];
        return decodedFirstBid.lenderAddress;
    }
    function _getFirstBidPaymentTokenAddress(uint256 _collateralId,address _sender) internal view returns (address) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Bid memory decodedFirstBid = s.idToFirstBid[_collateralId][_sender];
        return decodedFirstBid.paymentTokenAddress;
    }

    // function _getFirstBidApr(uint256 _collateralId,address _sender) internal view returns (uint256) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     // retrieve the encoded data for the specified tokenId
    //     Bid memory decodedFirstBid = s.idToFirstBid[_collateralId][_sender];
    //     return decodedFirstBid.apr;
    // }
    function _getFirstBidListDeadline(uint256 _collateralId,address _sender) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Bid memory decodedFirstBid = s.idToFirstBid[_collateralId][_sender];
        return decodedFirstBid.bidListDeadline;
    }
    // function _getFirstBidPaybackDeadline(uint256 _collateralId,address _sender) internal view returns (uint256) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     // retrieve the encoded data for the specified tokenId
    //     Bid memory decodedFirstBid = s.idToFirstBid[_collateralId][_sender];
    //     return decodedFirstBid.paybackDeadline;
    // }
    // function _getFirstBidMaxPayedAmount(uint256 _collateralId,address _sender) internal view returns (uint256) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     // retrieve the encoded data for the specified tokenId
    //     Bid memory decodedFirstBid = s.idToFirstBid[_collateralId][_sender];
    //     return decodedFirstBid.maxPayedAmount;
    // }
    // function _getFirstBidLiqudationType(uint256 _collateralId,address _sender) internal view returns (uint8) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     // retrieve the encoded data for the specified tokenId
    //     Bid memory decodedFirstBid = s.idToFirstBid[_collateralId][_sender];
    //     return decodedFirstBid.liqudationType;
    // }

    // // Helper Second Bid
    function _getSecondBidLenderAddress(uint256 _collateralId,address _sender) internal view returns (address) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Bid memory decodedSecondBid = s.idToSecondBid[_collateralId][_sender];
        return decodedSecondBid.lenderAddress;
    }
    // function _getSecondBidPaymentTokenAddress(uint256 _collateralId,address _sender) internal view returns (address) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     // retrieve the encoded data for the specified tokenId
    //     Bid memory decodedSecondBid = s.idToSecondBid[_collateralId][_sender];
    //     return decodedSecondBid.paymentTokenAddress;
    // }

    // function _getSecondBidApr(uint256 _collateralId,address _sender) internal view returns (uint256) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     // retrieve the encoded data for the specified tokenId
    //     Bid memory decodedSecondBid = s.idToSecondBid[_collateralId][_sender];
    //     return decodedSecondBid.apr;
    // }
    function _getSecondBidListDeadline(uint256 _collateralId,address _sender) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Bid memory decodedSecondBid = s.idToSecondBid[_collateralId][_sender];
        return decodedSecondBid.bidListDeadline;
    }
    // function _getSecondBidPaybackDeadline(uint256 _collateralId,address _sender) internal view returns (uint256) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     Bid memory decodedSecondBid = s.idToSecondBid[_collateralId][_sender];
    //     return decodedSecondBid.paybackDeadline;
    // }
    // function _getSecondBidMaxPayedAmount(uint256 _collateralId,address _sender) internal view returns (uint256) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     // retrieve the encoded data for the specified tokenId
    //     Bid memory decodedSecondBid = s.idToSecondBid[_collateralId][_sender];
    //     return decodedSecondBid.maxPayedAmount;
    // }
    // function _getSecondBidLiqudationType(uint256 _collateralId,address _sender) internal view returns (uint8) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     // retrieve the encoded data for the specified tokenId
    //     Bid memory decodedSecondBid = s.idToSecondBid[_collateralId][_sender];
    //     return decodedSecondBid.liqudationType;
    // }

    function _createBid(
        Bid memory lenderBid,
        uint256 _timeStamp,
        address _sender
    )internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        if(s.idToFirstBid[lenderBid.collateralId][_sender].collateralId == 0){
            _createFirstBid(lenderBid,_timeStamp,_sender);
        }
        else if(s.idToFirstBid[lenderBid.collateralId][_sender].collateralId != 0 && s.idToSecondBid[lenderBid.collateralId][_sender].collateralId == 0){
            _createSecondBid(lenderBid,_timeStamp,_sender);
        }
        else{
            revert("B001");//Lender can give only 2 bid for each item.
        }
    }

    // function _checkPrice(
    //     address _collateralAddress,
    //     uint256 _expectedPrice,
    //     address _paymentToken
    // ) internal view returns(uint256){
    //     require(_expectedPrice > 0, "B002");//Price must be at least 1 wei

    //     // if(LibAdmin._getPaymentStatusForToken(_paymentToken) == 2){
    //     //     require(_expectedPrice <= ((LibFloorPrice._getFloorPriceETH(_collateralAddress)*LibAdmin._getLoanToValueCollateralAddress(_collateralAddress))/100),"B004");//Price cant be max loan amount
    //     //     return  _expectedPrice;
    //     // }
    //     // else if(LibAdmin._getPaymentStatusForToken(_paymentToken) == 1){
    //     //     IERC20 token = IERC20(_paymentToken);
    //     //     uint256 tokenDecimal =  token.decimals();
    //     //     uint256 floorPrice = LibFloorPrice._getFloorPriceETH(_collateralAddress);
    //     //     uint256 floorPriceUSD = (floorPrice*LibAdmin._getETHPrice()/(10**(18-tokenDecimal))/uint256(1000000)); //100
    //     //     require(_expectedPrice <= (((floorPriceUSD)*LibAdmin._getLoanToValueCollateralAddress(_collateralAddress))/100),"B004");//Price cant be max loan amount
    //     //     return  _expectedPrice;
    //     // }
    //     uint256 ltv = LibAdmin._getLoanToValueCollateralAddress(_collateralAddress);

    //     require(ltv > 0,"C002");//LTV is 0
    //     if(LibAdmin._getPaymentStatusForToken(_paymentToken) == 2){
    //         uint256 floorPrice = LibFloorPrice._getFloorPrice(_collateralAddress);
    //         require(_expectedPrice <= ((floorPrice*ltv)/100) && _expectedPrice >= ((floorPrice*10)/100),"B004"); //Price cant be max loan amount
    //         return  _expectedPrice;
    //     }
    //     else if(LibAdmin._getPaymentStatusForToken(_paymentToken) == 1){
    //         IERC20 token = IERC20(_paymentToken);
    //         uint256 tokenDecimal =  token.decimals();
    //         uint256 floorPrice = LibFloorPrice._getFloorPrice(_collateralAddress);
    //         uint256 floorPriceUSD = (floorPrice*LibAdmin._getETHPrice()/(10**(18-tokenDecimal))/uint256(1000000));
    //         require(_expectedPrice <=((floorPriceUSD*ltv)/100) && _expectedPrice >= ((floorPriceUSD*10)/100),"B004"); //Price cant be max loan amount
    //         return  _expectedPrice;
    //     }
    //     else{
    //         revert("C004");//payment status not
    //     }
        
    // }

    function _verifyBid(
        Bid memory lenderBid,
        uint256 _timestamp,
        address _sender
    ) internal view returns(Bid memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(s.idToLoan[lenderBid.collateralId].collateralId == 0,"B006");//Already findeded loan
        require(LibCollateral._getSeller(lenderBid.collateralId) != _sender, "B007");//You cant bid yourself
        require(LibAdmin._getApprovedToken(lenderBid.paymentTokenAddress),"B008");//This token is not supported
        require(_timestamp <= LibCollateral._getListDeadline(lenderBid.collateralId), "B010");//ListDeadline
        require(lenderBid.paybackDeadline <= 90 , "B018");//Deadine should be less than 90 days 
        require(lenderBid.bidListDeadline <= 30, "B019");//List deadline should be less than 30 days 
        require(lenderBid.bidListDeadline >= 7, "B020");//List deadline should be more than 7 days 
        //require(lenderBid.apr > 0, "B021");//APR Must be greater than zero"
        require(lenderBid.apr >= 1  && lenderBid.apr <= 999 , "B021");//APR Must be greater than zero"
        // uint256 expectedPrice = _checkPrice(
        //     LibCollateral._getCollateralAddress(lenderBid.collateralId), 
        //     lenderBid.maxPayedAmount,
        //     lenderBid.paymentTokenAddress
        // );
        //lenderBid.maxPayedAmount = expectedPrice;
        lenderBid.bidListDeadline =  _timestamp + (lenderBid.bidListDeadline * 86400 seconds);
        return lenderBid;
    }

    function _createFirstBid(
        Bid memory lenderBid,
        uint256 _timestamp,
        address _sender
    )internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(s.idToFirstBid[lenderBid.collateralId][_sender].collateralId == 0,"B006");

        Bid memory verifiedBid= _verifyBid(lenderBid, _timestamp, _sender);
        //bytes memory encodedData = _encodeBid(verifiedBid);
        s.idToFirstBid[verifiedBid.collateralId][_sender] = verifiedBid;

        emit FirstBidCreated(
            verifiedBid
        );
    }

    function _createSecondBid(
        Bid memory lenderBid,
        uint256 _timestamp,
        address _sender
    )internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        Bid memory verifiedBid= _verifyBid(lenderBid, _timestamp, _sender);
        
        uint8 firstBidPaymentStatus = LibAdmin._getPaymentStatusForToken(_getFirstBidPaymentTokenAddress(lenderBid.collateralId, _sender));
        uint8 verifiedBidPaymentStatus = LibAdmin._getPaymentStatusForToken(lenderBid.paymentTokenAddress);
        
        if(firstBidPaymentStatus == 1 && verifiedBidPaymentStatus == 2){
            //bytes memory encodedData = _encodeBid(verifiedBid);
            s.idToSecondBid[verifiedBid.collateralId][_sender] = verifiedBid;
            emit SecondBidCreated(verifiedBid);
        }
        else if(firstBidPaymentStatus == 2 && verifiedBidPaymentStatus == 1){
            //bytes memory encodedData = _encodeBid(verifiedBid);
            s.idToSecondBid[verifiedBid.collateralId][_sender] = verifiedBid;
            emit SecondBidCreated(verifiedBid);
        }
        else{
            revert("B011");//1 stable currency and 1 wETH each colleteral"
        }
    }


}