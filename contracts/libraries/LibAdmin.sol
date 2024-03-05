// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {LibAppStorage,AppStorage, Collateral,Loan,FloorPrice, Bid,Liquidation} from "../libraries/LibAppStorage.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {LibCollateral} from "./LibCollateral.sol";
import {LibPayment} from "../libraries/LibPayment.sol";
import {LibFloorPrice} from "../libraries/LibFloorPrice.sol";
import {LibLiquidation} from "../libraries/LibLiquidation.sol";
import {LibBid} from "../libraries/LibBid.sol";
import {IERC721} from "../interfaces/IERC721.sol";

library LibAdmin {
    // defining state variables
    struct DiamondStorage {
        mapping(address => bool) whiteListedToken;
        mapping(address => bool) whiteListedCollateral;
        mapping(address => uint8) addressToPaymentStatus;//token adresin stable mi weth mi
        mapping(address => uint8) addressToCollateralStatus;// nft adresin durumu solid gem green
        //status
        mapping(uint8 => uint256) statusToLoanFee;
        mapping(uint8 => uint256) statusToPaybackFee;
        mapping(uint8 => uint256) statusToLiqudationFee;
        mapping(uint8 => uint256) statusToLiqudationLenderAmount;
        mapping(uint8 => uint256) statusToLiqPenalty;  //green icin farkli 
        mapping(uint8 => uint256) statusToLoanToValue;
        mapping(uint256 => uint256) liqutaionTresholds; // Collateral id liqudation treshold
    }

    event ChangedItemStatusTo(uint256 colleretalId, uint8 newStauts);

    // return a struct storage pointer for accessing the state variables
    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = keccak256("diamond.standard.diamond.LibAdmin");
        assembly {
            ds.slot := position
        }
    }

    function _setPaymentStatusForToken(address _token,uint8 _status) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.addressToPaymentStatus[_token] = _status;
    }

    function _getPaymentStatusForToken(address _token)internal view returns(uint8){
        DiamondStorage storage ds = diamondStorage();
        return ds.addressToPaymentStatus[_token];
    }

    function _setStatusToLiqPenalty(uint8 _status,uint256 _penalty) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.statusToLiqPenalty[_status] = _penalty;
    }
    function _getStatusToLiqPenalty(uint8 _status)internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        return ds.statusToLiqPenalty[_status];
    }

    // //address to loan fee
    // function _setAddressToLoanFee(address _nftContract, uint256 _fee) internal {
    //     DiamondStorage storage ds = diamondStorage();
    //     ds.addressToLoanFee[_nftContract] = _fee;
    // }

    // function _getAddressToLoanFee(address _nftContract)  internal view returns(uint256){
    //     DiamondStorage storage ds = diamondStorage();
    //     return ds.addressToLoanFee[_nftContract];
    // }

    // //address to payback fee
    // function _setAddressToPaybackFee(address _nftContract, uint256 _fee) internal {
    //     DiamondStorage storage ds = diamondStorage();
    //     ds.addressToPaybackFee[_nftContract] = _fee;
    // }

    // function _getAddressToPaybackFee(address _nftContract)  internal view returns(uint256){
    //     DiamondStorage storage ds = diamondStorage();
    //     return ds.addressToPaybackFee[_nftContract];
    // }

    // //address to liqudation fee
    // function _setAddressToLiqudationFee(address _nftContract, uint256 _fee) internal {
    //     DiamondStorage storage ds = diamondStorage();
    //     ds.addressToLiqudationFee[_nftContract] = _fee;
    // }

    // function _getAddressToLiqudationFee(address _nftContract)  internal view returns(uint256){
    //     DiamondStorage storage ds = diamondStorage();
    //     return ds.addressToLiqudationFee[_nftContract];
    // }

    // //address to liqudation lender persatnage
    // function _setAddressToLiqudationLenderFee(address _nftContract, uint256 _fee) internal {
    //     DiamondStorage storage ds = diamondStorage();
    //     ds.addressToLiqudationLenderAmount[_nftContract] = _fee;
    // }

    // function _getAddressToLiqudationLenderFee(address _nftContract)  internal view returns(uint256){
    //     DiamondStorage storage ds = diamondStorage();
    //     return ds.addressToLiqudationLenderAmount[_nftContract];
    // }


    function _setCollateralStatus(address _CollateralAddress,uint8 _status) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.addressToCollateralStatus[_CollateralAddress] = _status;
    }
    function _getCollateralStatus(address _CollateralAddress)internal view returns(uint8){
        DiamondStorage storage ds = diamondStorage();
        return ds.addressToCollateralStatus[_CollateralAddress];
    }

    function _setApprovedToken(address _tokenAddress, bool _setAsWhitelisted) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.whiteListedToken[_tokenAddress] = _setAsWhitelisted;
    }

    function _getApprovedToken(address _tokenAddress)internal view returns(bool){
        DiamondStorage storage ds = diamondStorage();
        return ds.whiteListedToken[_tokenAddress];
    }

    //set a contract address bool
    function _setWhitelistCollateral(address _nftContract, bool _setAsWhitelisted) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.whiteListedCollateral[_nftContract] = _setAsWhitelisted;
    }

    function _getWhitelistCollateral(address _nftContract)internal view returns(bool){
        DiamondStorage storage ds = diamondStorage();
        return ds.whiteListedCollateral[_nftContract];
    }

    function _setLiquidationTresholdCollateral(uint256 _collateralId, uint256 _liqudationTreshold) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.liqutaionTresholds[_collateralId] = _liqudationTreshold;
    }

    function _getLiquidationTresholdCollateral(uint256 _collateralId)  internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        return ds.liqutaionTresholds[_collateralId];
        
        // else if(_getPaymentStatusForToken(_paymentTokenAddress) == PaymentStatus.stableCurrency){
        //     DiamondStorage storage ds = diamondStorage();
        //     IERC20 token = IERC20(_paymentTokenAddress);
        //     uint256 tokenDecimal =  token.decimals();
        //     uint256 liqTresholdETH = ds.liqutaionTresholds[_nftContract];//
        //     uint256 floorPriceUSD = (liqTresholdETH*_getETHPrice()/(10**(18-tokenDecimal))/uint256(1000000));
        //     return floorPriceUSD;
        // }
        
    }
    // function _setLiqudationPenalty(address _nftContract, uint256 _liqudationTreshold) internal {
    //     DiamondStorage storage ds = diamondStorage();
    //     ds.liqutaionPenalty[_nftContract] = _liqudationTreshold;
    // }

    // function _getLiqudationPenalty(address _nftContract)  internal view returns(uint256){
    //     DiamondStorage storage ds = diamondStorage();
    //     return ds.liqutaionPenalty[_nftContract];
    // }

    // function _setLoanToValueCollateral(address _nftContract, uint256 _loanToValue) internal {
    //     DiamondStorage storage ds = diamondStorage();
    //     ds.loanToValue[_nftContract] = _loanToValue;
    // }

    function _setDiamondAddress(address _diamond) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.diamondAddress = _diamond;
    }
    function _getDiamondAddress() internal view returns(address) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.diamondAddress;
    }

    function _setETHPrice(uint256 _price) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.ethPrice = _price;
    }
    function _getETHPrice() internal view returns(uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.ethPrice;
    }

    function _getLoanToValueCollateralId(uint256 _collateralId) internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        AppStorage storage s = LibAppStorage.diamondStorage();

        Collateral memory decodedData = s.idToCollateral[_collateralId];
        
        return ds.statusToLoanToValue[ds.addressToCollateralStatus[decodedData.collateralAddress]];
    }

    function _getLoanToValueCollateralAddress(address _collateralAddress) internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        //AppStorage storage s = LibAppStorage.diamondStorage();

        //Collateral memory decodedData = s.idToCollateral[_collateralId];
        
        return ds.statusToLoanToValue[ds.addressToCollateralStatus[_collateralAddress]];
    }


    function _getCollateralInfo(uint256 _collateralId) internal view returns(Collateral memory collateral) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        Collateral memory decodedData = s.idToCollateral[_collateralId];
        //Collateral memory decodedData = LibCollateral._decodeCollateral(existedCollateral);
        (collateral) =decodedData;
    }
    function _getLoanInfo(uint256 _collateralId) internal view returns(Loan memory lendersLoan){
        AppStorage storage s = LibAppStorage.diamondStorage();
        //bytes memory existedLoan = s.idToLoan[_collateralId];
        (lendersLoan) =s.idToLoan[_collateralId];
    }
        function _getFirstBid2(uint256 _collateralId,address _sender) internal view returns(Bid memory){
        AppStorage storage s = LibAppStorage.diamondStorage();
        //bytes memory existedbid= s.idToFirstBid[_collateralId][_sender];
        return  s.idToFirstBid[_collateralId][_sender];
    }
    function _getSecondBid2(uint256 _collateralId,address _sender) internal view returns(Bid memory){
        AppStorage storage s = LibAppStorage.diamondStorage();
        //bytes memory existedSecondbid= s.idToSecondBid[_collateralId][_sender];
        return s.idToSecondBid[_collateralId][_sender];
    }


    function _getFloorPrice(address _CollateralAddress) internal view returns(FloorPrice memory floorPrice){
        AppStorage storage s = LibAppStorage.diamondStorage();
        //bytes memory existedLiqudation = s.addressToFloorPrice[_CollateralAddress];
        (floorPrice) =s.addressTofloorPrice[_CollateralAddress];
    }
    function _getLiqudationData(uint256 _collateralId) internal view returns(Liquidation memory liqudation){
        AppStorage storage s = LibAppStorage.diamondStorage();
        //bytes memory existedLiqudation = s.idToLuqidationData[_collateralId];
        //Liquidation memory decodedData = s.idToLuqidationData[_collateralId];
        (liqudation) = s.idToLiquidationData[_collateralId];
    }

    function _transferFee(address _tokenAddress,uint256 _amount,address _sender) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        IERC20(_tokenAddress).transferFrom(s.diamondAddress, _sender,_amount);
    }

    function _setCollateralStatusToLoanFee(uint8 _status,uint256 _fee) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.statusToLoanFee[_status] = _fee;
    }
    function _setCollateralStatusToPaybackFee(uint8 _status,uint256 _fee) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.statusToPaybackFee[_status] = _fee;
    }
    function _setCollateralStatusToLiqudationFee(uint8 _status,uint256 _fee) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.statusToLiqudationFee[_status] = _fee;
    }
    function _setCollateralStatusToLiqudationLenderAmount(uint8 _status,uint256 _amount) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.statusToLiqudationLenderAmount[_status] = _amount;
    }
    function _getCollateralStatusToLiqudationLenderAmount(uint8 _status) internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        return ds.statusToLiqudationLenderAmount[_status];
    }

    function _setCollateralStatusToLoanToValue(uint8 _status,uint256 _amount) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.statusToLoanToValue[_status] = _amount;
    }
    function _getCollateralStatusToLoanToValue(uint8 _status) internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        return ds.statusToLoanToValue[_status];
    }


    function _getCollateralStatusToLonFee(uint8 _status) internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        return ds.statusToLoanFee[_status];
    }
    function _getCollateralStatusToPaybackFee(uint8 _status) internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        return ds.statusToPaybackFee[_status];
    }
    function _getCollateralStatusToLiqudationFee(uint8 _status) internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        return ds.statusToLiqudationFee[_status];
    }


    function _calculateLoanFee(address _nftContract,uint256 _amount) internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        uint8 _status = ds.addressToCollateralStatus[_nftContract];
        return ((_amount*ds.statusToLoanFee[_status])/10000);
    }
    function _calculatePaybackFee(address _nftContract,uint256 _amount) internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        uint8 _status = ds.addressToCollateralStatus[_nftContract];
        return ((_amount*ds.statusToPaybackFee[_status])/10000);
    }
    function _calculateLiqudationFee(address _nftContract,uint256 _amount) internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        uint8 _status = ds.addressToCollateralStatus[_nftContract];
        return ((_amount*ds.statusToLiqudationFee[_status])/10000);
    }


    function _changeCollateralUnlisted(uint256 _collateralId)  internal{
        AppStorage storage s = LibAppStorage.diamondStorage();
        //bytes memory encodedData = s.idToColleretal[_collateralId];
        Collateral memory _collateral = s.idToCollateral[_collateralId];
        _collateral.paybackDeadline = 0;
        _collateral.listDeadline = 0;
        _collateral.status = 12;
        //bytes memory _encodedData = LibCollateral._encodeCollateral(decodedData);
        s.idToCollateral[_collateralId] = _collateral;
    }
    
    function _transferToBorrowerChangedStatus(
        uint256 _collateralId
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        _changeCollateralUnlisted(_collateralId);

        emit ChangedItemStatusTo(_collateralId,12);//unlistedCollateral

        IERC721(LibCollateral._getCollateralAddress(_collateralId)).transferFrom(
            s.diamondAddress,
            LibCollateral._getSeller(_collateralId),
            LibCollateral._getTokenID(_collateralId));
            
    }

    // function _calculateLoanFeeAdreess(address _nftContract,uint256 _amount) internal view returns(uint256){
    //     DiamondStorage storage ds = diamondStorage();
    //     //CollateralStatus _status = ds.addressToCollateralStatus[_nftContract];
    //     return ((_amount*ds.addressToLoanFee[_nftContract])/10000);
    // }
    // function _calculatePaybackFeeAdreess(address _nftContract,uint256 _amount) internal view returns(uint256){
    //     DiamondStorage storage ds = diamondStorage();
    //     //CollateralStatus _status = ds.addressToCollateralStatus[_nftContract];
    //     return ((_amount*ds.addressToPaybackFee[_nftContract])/10000);
    // }
    // function _calculateLiqudationFeeAdreess(address _nftContract,uint256 _amount) internal view returns(uint256){
    //     DiamondStorage storage ds = diamondStorage();
    //     //CollateralStatus _status = ds.addressToCollateralStatus[_nftContract];
    //     return ((_amount*ds.addressToLiqudationFee[_nftContract])/10000);
    // }
    
}