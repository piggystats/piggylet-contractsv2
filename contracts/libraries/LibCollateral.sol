// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {LibAppStorage,AppStorage,Collateral,Loan, Bid} from "../libraries/LibAppStorage.sol";
import {IERC721} from "../interfaces/IERC721.sol";
import {IERC1155} from "../interfaces/IERC1155.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {LibAdmin} from "../libraries/LibAdmin.sol";
import {LibFloorPrice} from "../libraries/LibFloorPrice.sol";


// interface IERC20 {
//     function decimals() external view returns (uint8);
// }

library LibCollateral{
    struct DiamondStorage {
        uint256 collateralID;
    }

    // return a struct storage pointer for accessing the state variables
    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = keccak256("diamond.standard.diamond.LibCollateral");
        assembly {
            ds.slot := position
        }
    }

    function _incerementCollateralID()internal {
        DiamondStorage storage ds = diamondStorage();
        ds.collateralID ++;
    }
    function _getCollateralID() internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        return ds.collateralID;
    }

    event CollateralSendedEvent(
        Collateral colleralBytes
    );

    event UpdateCollateralPayment(
        Collateral colleralBytes
    );

    event ChangedItemStatusTo(uint256 collateralId, uint8 newStauts);

    // function _encodeColleteral(Colleteral memory colleteral) internal pure returns (bytes memory) {
    //     return abi.encode(colleteral);
    // }

    // function _decodeColleteral(bytes memory data) internal pure returns (Colleteral memory colleteral) {
    //     (colleteral) = abi.decode(data, (Colleteral));
    // }


    function _getLiquidationType(uint256 _collateralId) internal view returns (uint8) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        // bytes memory encodedData = s.idToColleretal[_colleteralId];
        // decode the encoded data and retrieve the APR value
        Collateral memory decodedData = s.idToCollateral[_collateralId];
        return decodedData.liquidationType;
    }
    function _getItemStatus(uint256 _collateralId) internal view returns (uint8) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Collateral memory decodedData = s.idToCollateral[_collateralId];
        return decodedData.status;
    }
    function _getPaymentToken(uint256 _collateralId) internal view returns (address) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Collateral memory decodedData = s.idToCollateral[_collateralId];
        return decodedData.paymentToken;
    }
    function _getCollateralAddress(uint256 _collateralId) internal view returns (address) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Collateral memory decodedData = s.idToCollateral[_collateralId];
        return decodedData.collateralAddress;
    }
    function _getApr(uint256 _collateralId) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Collateral memory decodedData = s.idToCollateral[_collateralId];
        return decodedData.apr;
    }
    function _getExpectedPrice(uint256 _collateralId) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Collateral memory decodedData = s.idToCollateral[_collateralId];
        return decodedData.expectedPrice;
    }
    function _getListDeadline(uint256 _collateralId) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Collateral memory decodedData = s.idToCollateral[_collateralId];
        return decodedData.listDeadline;
    }
    function _getPaybackDeadline(uint256 _collateralId) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Collateral memory decodedData = s.idToCollateral[_collateralId];
        return decodedData.paybackDeadline;
    }
    function _getPaybackDay(uint256 _collateralId) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Collateral memory decodedData = s.idToCollateral[_collateralId];
        return decodedData.paybackDay;
    }
    function _getTokenID(uint256 _collateralId) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Collateral memory decodedData = s.idToCollateral[_collateralId];
        return decodedData.tokenId;
    }
    function _getSeller(uint256 _collateralId) internal view returns (address) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Collateral memory decodedData = s.idToCollateral[_collateralId];
        return decodedData.seller;
    }
    // function _getTokenType(uint256 _colleteralId) internal view returns (uint8) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     // retrieve the encoded data for the specified tokenId
    //     bytes memory encodedData = s.idToColleretal[_colleteralId];
    //     // decode the encoded data and retrieve the APR value
    //     Colleteral memory decodedData = _decodeColleteral(encodedData);
    //     return decodedData.colleteralType;
    // }
    // function _getAmount(uint256 _colleteralId) internal view returns (uint256) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     // retrieve the encoded data for the specified tokenId
    //     bytes memory encodedData = s.idToColleretal[_colleteralId];
    //     // decode the encoded data and retrieve the APR value
    //     Colleteral memory decodedData = _decodeColleteral(encodedData);
    //     return decodedData.amount;
    // }

    // function _checkPrice(
    //     address _collateralAddress,
    //     uint256 _expectedPrice,
    //     address _paymentToken
    // )internal view returns(uint256){
    //     require(_expectedPrice > 0, "C001");//Price must be at least 1 wei
    //     //AppStorage storage s = LibAppStorage.diamondStorage(); 
    //     //uint8  _colleteralStatus = LibAdmin._getCollateralStatus(LibCollateral._getCollateralAddress(_collateralId));
    //     //uint256 ltv = LibAdmin._getLoanToValueCollateralAddress(_collateralAddress);

    //     require(ltv > 0,"C002");//LTV is 0
    //     if(LibAdmin._getPaymentStatusForToken(_paymentToken) == 2){
    //         uint256 floorPrice = LibFloorPrice._getFloorPrice(_collateralAddress);
    //         require(_expectedPrice <= ((floorPrice*ltv)/100) && _expectedPrice >= ((floorPrice*10)/100),"C003"); //Price cant be max loan amount
    //         return  _expectedPrice;
    //     }
    //     else if(LibAdmin._getPaymentStatusForToken(_paymentToken) == 1){
    //         IERC20 token = IERC20(_paymentToken);
    //         uint256 tokenDecimal =  token.decimals();
    //         uint256 floorPrice = LibFloorPrice._getFloorPrice(_collateralAddress);//10 eth
    //         uint256 floorPriceUSD = (floorPrice*LibAdmin._getETHPrice()/(10**(18-tokenDecimal))/uint256(1000000));//20kdolar
    //         require(_expectedPrice <=((floorPriceUSD*ltv)/100) && _expectedPrice >= ((floorPriceUSD*10)/100),"C003"); //Price cant be max loan amount
    //         return  _expectedPrice;
    //     }
    //     else{
    //         revert("C004");//payment status not
    //     }
    // }

    function _collateralVerify(
        Collateral memory collateralParam,
        uint256 _timestamp
    ) internal view returns(Collateral memory){
        require(collateralParam.paybackDeadline <= 90 && collateralParam.paybackDeadline ==collateralParam.paybackDay , "C005");//Deadine should be less than 90 days s
        require(collateralParam.listDeadline <= 30, "C006");//List deadline should be less than 30 days 
        require(collateralParam.listDeadline >= 7, "C007");//List deadline should be more than 7 days 
        require(collateralParam.apr >= 1  &&collateralParam.apr <= 999 , "C008");//APR Must be greater than zero"
        require(LibAdmin._getWhitelistCollateral(collateralParam.collateralAddress),"C009");//This collection is not supported
        require(LibAdmin._getApprovedToken(collateralParam.paymentToken),"C010");//This token is not supported
        
        // uint256 expectedPrice =_checkPrice(
        //     collateralParam.collateralAddress, 
        //     collateralParam.expectedPrice,
        //     collateralParam.paymentToken
        // );
        //collateralParam.expectedPrice = expectedPrice;
        collateralParam.listDeadline = _timestamp + (collateralParam.listDeadline * 86400 seconds);
        collateralParam.collateralId = _getCollateralID();
        collateralParam.liquidationType = 0;
        return collateralParam;
    }

    function _collateralVerifyForSearch(
        Collateral memory collateralParam,
        uint256 _timestamp
    ) internal view returns(Collateral memory){
        require(collateralParam.paybackDeadline <= 90 && collateralParam.paybackDeadline ==collateralParam.paybackDay , "C005");//Deadine should be less than 90 days 
        require(collateralParam.listDeadline <= 30, "C006");//List deadline should be less than 30 days 
        require(collateralParam.listDeadline >= 7, "C007");//List deadline should be more than 7 days 
        require(collateralParam.status == 2, "C012");//This item cant search bids
        require(LibAdmin._getWhitelistCollateral(collateralParam.collateralAddress),"C009");//This collection is not supported
        
        collateralParam.listDeadline = _timestamp + (collateralParam.listDeadline * 86400 seconds);
        collateralParam.liquidationType = 0;
        collateralParam.paymentToken == address(0);
        collateralParam.expectedPrice == 0;
        collateralParam.apr == 0;
        collateralParam.collateralId = _getCollateralID();
        return collateralParam;
    }

    function _sendForLoan(
        Collateral memory collateralParam,
        uint256 _timestamp,
        address _sender
    )internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        Collateral memory verifiedCollateral= _collateralVerify(collateralParam,_timestamp);

        _incerementCollateralID();

        s.idToCollateral[verifiedCollateral.collateralId] = verifiedCollateral;

        IERC721(verifiedCollateral.collateralAddress).transferFrom(
            _sender, 
            s.diamondAddress, 
            verifiedCollateral.tokenId
        );

        emit CollateralSendedEvent(
            verifiedCollateral
        );

  
    }

    function _sendCollateralSearchBids(
        Collateral memory collateralParam,
        uint256 _timestamp,
        address _sender
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        Collateral memory verifiedCollateral= _collateralVerifyForSearch(collateralParam,_timestamp);

        _incerementCollateralID();

        //bytes memory encodedData = _encodeColleteral(verifiedCollateral);
        // store the encoded data in the mapping
        s.idToCollateral[verifiedCollateral.collateralId] = verifiedCollateral;

        emit CollateralSendedEvent(
            verifiedCollateral
        );

        IERC721(verifiedCollateral.collateralAddress).transferFrom(_sender, s.diamondAddress, verifiedCollateral.tokenId);
    }

    function _verifyUpdate(
        Collateral memory collateralParam,
        address _sender,
        uint256 _timestamp
    )internal view{
        require(_getSeller(collateralParam.collateralId) == _sender, "C014");//You are not the borroer
        require(_getItemStatus(collateralParam.collateralId) != 5,"C015");//finded loan
        require(_getItemStatus(collateralParam.collateralId)== 1 || _getItemStatus(collateralParam.collateralId) == 2,"C016");//not supported
        require(collateralParam.paybackDeadline <= 90 && collateralParam.paybackDeadline == collateralParam.paybackDay , "C005");//Deadine should be less than 90 days 
        require(collateralParam.listDeadline <= 30, "C006");//List deadline should be less than 30 days 
        require(collateralParam.listDeadline >= 7, "C007");//List deadline should be more than 7 days 
        require(collateralParam.apr >= 1  &&collateralParam.apr <= 999 , "C008");//APR Must be greater than zero"
        require(LibAdmin._getWhitelistCollateral(collateralParam.collateralAddress),"C009");//This collection is not supported
        require(LibAdmin._getApprovedToken(collateralParam.paymentToken),"C010");//This token is not supported
        
        // uint256 expectedPrice =_checkPrice(
        //     collateralParam.collateralAddress, 
        //     collateralParam.expectedPrice,
        //     collateralParam.paymentToken
        // );
        // collateralParam.expectedPrice = expectedPrice;
        collateralParam.liquidationType = 0;
        collateralParam.listDeadline = _timestamp + (collateralParam.listDeadline * 86400 seconds);
    }


    function _updateCollateral(
        Collateral memory collateralParam, 
        uint256 _timestamp,
        address _sender
    ) internal  {
        AppStorage storage s = LibAppStorage.diamondStorage();
        _verifyUpdate(collateralParam,_sender,_timestamp);

        Collateral memory _collateral = s.idToCollateral[collateralParam.collateralId];

        // uint256 expectedPrice =_checkPrice(
        //     collateralParam.collateralAddress, 
        //     collateralParam.expectedPrice,
        //     collateralParam.paymentToken
        // );
        
        //Collateral memory decodedData = _decodeColleteral(encodedData);
        require(_collateral.collateralId == collateralParam.collateralId,"C017");//id missmach
        require(_collateral.collateralAddress == collateralParam.collateralAddress,"C018");
        require(_collateral.tokenId == collateralParam.tokenId,"C020");//address missmatch
        
        _collateral.listDeadline = collateralParam.listDeadline;
        _collateral.paybackDeadline = collateralParam.paybackDeadline;
        _collateral.paybackDay = collateralParam.paybackDeadline;
        _collateral.paymentToken = collateralParam.paymentToken;
        //_collateral.expectedPrice = expectedPrice;
        _collateral.apr = collateralParam.apr;
        _collateral.liquidationType =collateralParam.liquidationType;

        //bytes memory _encodedData = _encodeColleteral(decodedData);

        s.idToCollateral[_collateral.collateralId] = _collateral;
            
        emit UpdateCollateralPayment(
            _collateral
        );
    }

    function _cancelLoanRequest(
        uint256 _collateralId,
        address _sender
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        
        require(_getSeller(_collateralId) == _sender, "C014");//You are not the borroer
        require(_getItemStatus(_collateralId)== 1 || _getItemStatus(_collateralId) == 2,"C016");//not supported

        // bytes memory existedColleteral = s.idToCollateral[_collateralId];
        Collateral memory _collateral = s.idToCollateral[_collateralId];

        _collateral.status = 11;
        //bytes memory _encodedData = _encodeColleteral(decodedData);
        s.idToCollateral[_collateralId] = _collateral;

        IERC721(_getCollateralAddress(_collateralId)).transferFrom(s.diamondAddress, _getSeller(_collateralId), _getTokenID(_collateralId));

        emit ChangedItemStatusTo(_collateralId, 11);

        
        
    }


}