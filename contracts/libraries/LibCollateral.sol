// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {LibAppStorage,AppStorage,Collateral,Loan, Bid} from "../libraries/LibAppStorage.sol";
import {IERC721} from "../interfaces/IERC721.sol";
import {IERC1155} from "../interfaces/IERC1155.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {LibAdmin} from "../libraries/LibAdmin.sol";

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

    function _getTokenType(uint256 _collateralId) internal view returns (uint8) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Collateral memory decodedData = s.idToCollateral[_collateralId];
        return decodedData.collateralType;
    }
    function _getAmount(uint256 _collateralId) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Collateral memory decodedData = s.idToCollateral[_collateralId];
        return decodedData.amount;
    }



    function _collateralVerify(
        Collateral memory collateralParam,
        uint256 _timestamp
    ) internal view returns(Collateral memory){
        require(collateralParam.paybackDeadline <= 90 && collateralParam.paybackDeadline ==collateralParam.paybackDay , "C1");//Deadine should be less than 90 days s
        require(collateralParam.listDeadline <= 30 && collateralParam.listDeadline >= 7, "C2");//List deadline should be less than 30 days 
        require(collateralParam.apr >= 1  &&collateralParam.apr <= 999 , "C3");//APR Must be greater than zero"
        require(LibAdmin._getWhitelistCollateral(collateralParam.collateralAddress),"C4");//This collection is not supported
        require(LibAdmin._getApprovedToken(collateralParam.paymentToken),"C5");//This token is not supported
        

        collateralParam.listDeadline = _timestamp + (collateralParam.listDeadline * 86400 seconds);
        collateralParam.collateralId = _getCollateralID();
        collateralParam.liquidationType = 0;
        return collateralParam;
    }

    function _collateralVerifyForSearch(
        Collateral memory collateralParam,
        uint256 _timestamp
    ) internal view returns(Collateral memory){
        require(collateralParam.paybackDeadline <= 90 && collateralParam.paybackDeadline == collateralParam.paybackDay , "C6");//Deadine should be less than 90 days 
        require(collateralParam.listDeadline <= 30 && collateralParam.listDeadline >= 7, "C7");//List deadline should be less than 30 days 
        require(collateralParam.status == 2, "C8");//This item cant search bids
        require(LibAdmin._getWhitelistCollateral(collateralParam.collateralAddress),"C9");//This collection is not supported
        
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

        // IERC721(verifiedCollateral.collateralAddress).transferFrom(
        //     _sender, 
        //     s.diamondAddress, 
        //     verifiedCollateral.tokenId
        // );

        if (collateralParam.collateralType == 1) {
            IERC721(verifiedCollateral.collateralAddress).transferFrom(
            _sender, 
            s.diamondAddress, 
            verifiedCollateral.tokenId
        );
        } else if(collateralParam.collateralType == 3){
            IERC20(verifiedCollateral.collateralAddress).transferFrom(
                _sender, 
                s.diamondAddress, 
                collateralParam.amount
            );
        }

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
        require(_getSeller(collateralParam.collateralId) == _sender, "C10");//You are not the borroer
        require(_getItemStatus(collateralParam.collateralId) != 5,"C11");//finded loan
        require(_getItemStatus(collateralParam.collateralId)== 1 || _getItemStatus(collateralParam.collateralId) == 2,"C12");//not supported
        require(collateralParam.paybackDeadline <= 90 && collateralParam.paybackDeadline == collateralParam.paybackDay , "C13");//Deadine should be less than 90 days 
        require(collateralParam.listDeadline <= 30 && collateralParam.listDeadline >= 7, "C14");//List deadline should be less than 30 days 
        require(collateralParam.apr >= 1  &&collateralParam.apr <= 999 , "C15");//APR Must be greater than zero"
        require(LibAdmin._getWhitelistCollateral(collateralParam.collateralAddress),"C16");//This collection is not supported
        require(LibAdmin._getApprovedToken(collateralParam.paymentToken),"C17");//This token is not supported

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
        require(_collateral.collateralId == collateralParam.collateralId,"C18");//id missmach
        require(_collateral.collateralAddress == collateralParam.collateralAddress,"C19");
        require(_collateral.tokenId == collateralParam.tokenId,"C20");//address missmatch
        
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
        
        require(_getSeller(_collateralId) == _sender, "C21");//You are not the borroer
        require(_getItemStatus(_collateralId)== 1 || _getItemStatus(_collateralId) == 2,"C22");//not supported

        // bytes memory existedColleteral = s.idToCollateral[_collateralId];
        Collateral memory _collateral = s.idToCollateral[_collateralId];

        _collateral.status = 11;
        //bytes memory _encodedData = _encodeColleteral(decodedData);
        s.idToCollateral[_collateralId] = _collateral;

        // IERC721(_getCollateralAddress(_collateralId)).transferFrom(s.diamondAddress, _getSeller(_collateralId), _getTokenID(_collateralId));

        if (_collateral.collateralType == 1) {
            IERC721(_getCollateralAddress(_collateralId)).transferFrom(
                s.diamondAddress, _getSeller(_collateralId), 
                _getTokenID(_collateralId)
                );
        } else if(_collateral.collateralType == 3){
            IERC20(_getCollateralAddress(_collateralId)).transfer(
                _sender, 
                _collateral.amount
            );
        }
        emit ChangedItemStatusTo(_collateralId, 11);

    }
}
