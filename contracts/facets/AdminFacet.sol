// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Collateral,Loan,FloorPrice,Bid,Liquidation} from "../libraries/LibAppStorage.sol";
import {LibAdmin} from "../libraries/LibAdmin.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
// import {LibCalculatePlatformFee} from "../libraries/LibCalculatePlatformFee.sol";

contract AdminFacet{

    function setTokenAddressPaymentStatus(address _token,uint8 _status) external {
        LibDiamond.enforceIsContractOwner();
        LibAdmin._setPaymentStatusForToken(_token,_status);
    }
    function getTokenAddressPaymentStatus(address _token)external view returns(uint8){
        return LibAdmin._getPaymentStatusForToken(_token);
    }

    function setCollateralStatus(address _collateralAddress,uint8 _status) external  {
        LibDiamond.enforceIsContractOwner();
        LibAdmin._setCollateralStatus(_collateralAddress,_status);
    }


    function setTransferToLenderFee(uint256 _fee) external   {
        LibDiamond.enforceIsContractOwner();
        LibAdmin._setLiqFee(_fee);
    }

    function getTransferToLenderFee() external view returns(uint256) {
        return LibAdmin._getLiqFee();
    }


    function bundeCollateralStatus(address[] memory _collateralAddress,uint8[] memory _status) external  {
        LibDiamond.enforceIsContractOwner();
        require(_collateralAddress.length == _status.length &&_collateralAddress.length  <=20,"A0002");
        for (uint256 i = 0; i < _collateralAddress.length; i++){
            LibAdmin._setCollateralStatus(_collateralAddress[i],_status[i]);
        }
    }
    function getCollateralStatus(address _collateralAddress)external view returns(uint8){
        return LibAdmin._getCollateralStatus(_collateralAddress);
    }

    

    function setWhitelistToken(address tokenAddress, bool _setAsWhitelisted) external   {
        LibDiamond.enforceIsContractOwner();
        LibAdmin._setApprovedToken(tokenAddress, _setAsWhitelisted);
    }

    function getWhiteListToken(address _erc20Currency) external view returns(bool) {
        return LibAdmin._getApprovedToken(_erc20Currency);
    }

    function setWhitelistCollateral(address _nftContract, bool _setAsWhitelisted) external  {
        LibDiamond.enforceIsContractOwner();
        LibAdmin._setWhitelistCollateral(_nftContract, _setAsWhitelisted);
    }

    function bundleWhitelistCollateral(address[] memory _nftContract, bool[] memory _setAsWhitelisted) external  {
        LibDiamond.enforceIsContractOwner();
        require(_nftContract.length == _setAsWhitelisted.length &&_nftContract.length<=20,"A0002");
        for (uint256 i = 0; i < _nftContract.length; i++){
            LibAdmin._setWhitelistCollateral(_nftContract[i], _setAsWhitelisted[i]);
        }
    }

    function setLoanFee(uint8 _status, uint256 _fee) external  {
        LibDiamond.enforceIsContractOwner();
        LibAdmin._setCollateralStatusToLoanFee(_status, _fee);
    }
    function setPaybackFee(uint8 _status, uint256 _fee) external  {
        LibDiamond.enforceIsContractOwner();
        LibAdmin._setCollateralStatusToPaybackFee(_status, _fee);
    }
    function setLiqudationFee(uint8 _status, uint256 _fee) external  {
        LibDiamond.enforceIsContractOwner();
        LibAdmin._setCollateralStatusToLiqudationFee(_status, _fee);
    }
    function getLoanFee(uint8 _status)external view returns(uint256){
        return LibAdmin._getCollateralStatusToLonFee(_status);
    }
    function getPaybackFee(uint8 _status)external view returns(uint256){
        return LibAdmin._getCollateralStatusToPaybackFee(_status);
    }
    function getLiqudationFee(uint8 _status)external view returns(uint256){
        return LibAdmin._getCollateralStatusToLiqudationFee(_status);
    }

    function getwhitelistCollateral(address _nftContract)external view returns(bool){
        return LibAdmin._getWhitelistCollateral(_nftContract);
    }

    function setDiamondAddress(address _diamond)external{
        LibDiamond.enforceIsContractOwner();
        return LibAdmin._setDiamondAddress(_diamond);
    }
    function getDiamondAddress()external view returns(address){
        return LibAdmin._getDiamondAddress();
    }

    function setEthereumPrice(uint256 _price) external{
        LibDiamond.enforceIsContractOwner();
        return LibAdmin._setETHPrice(_price);
    }
    function getEthereumPrice()external view returns(uint256){
        return LibAdmin._getETHPrice();
    }

    //get liqudation treshold
    function getLiqudationTreshold(uint256 _collateralId) external view returns(uint256){
        return LibAdmin._getLiquidationTresholdCollateral(_collateralId);
    }


    function setLoanToValueStatus(uint8 _status, uint256 _loanToValue) external {
        LibDiamond.enforceIsContractOwner();
        LibAdmin._setCollateralStatusToLoanToValue(_status, _loanToValue);
    }

    function getLoanToValueStatus(uint8 _status) external view returns(uint256){
        return LibAdmin._getCollateralStatusToLoanToValue(_status);
    }

    function getLoanToValueStatusCollateralAddress(address _collateralAddress) external view returns(uint256){
        return LibAdmin._getLoanToValueCollateralAddress(_collateralAddress);
    }



    function transferFees(address _tokenAddress,uint256 _amount)external {
        LibDiamond.enforceIsContractOwner();
        LibAdmin._transferFee(_tokenAddress,_amount,msg.sender);
    }

    function getCollateral(uint256 _collateralId) external view returns(Collateral memory collateral){
        (collateral) = LibAdmin._getCollateralInfo(_collateralId);
    }

    function getLoan(uint256 _collateralId) external view returns(Loan memory lenderLoan){
        (lenderLoan) = LibAdmin._getLoanInfo(_collateralId);
    }
    
    function getFirstBid(uint256 _collateralId) external view returns(Bid memory){
        return LibAdmin._getFirstBid2(_collateralId,msg.sender);
    }
    function getSecondBid(uint256 _collateralId) external view returns(Bid memory){
        return LibAdmin._getSecondBid2(_collateralId,msg.sender);
    }

    function getLiqudationData(uint256 _collateralId) external view returns(Liquidation memory liqudation){
        (liqudation) = LibAdmin._getLiqudationData(_collateralId);
    }
    function getFloorPrice(address _collateralAddress) external view returns(FloorPrice memory floorPrice){
        (floorPrice) = LibAdmin._getFloorPrice(_collateralAddress);
    }

    function setStatusToPenalty(uint8 _status, uint256 _penalty) external  {
        LibDiamond.enforceIsContractOwner();
        LibAdmin._setStatusToLiqPenalty(_status, _penalty);
    }

    function getStatusToPenalty(uint8 _status)external view returns(uint256){
        return LibAdmin._getStatusToLiqPenalty(_status);
    }


    function bundleLoanToValueStatus(uint8[] memory _status, uint256[] memory _loanToValue) external {
        LibDiamond.enforceIsContractOwner();
        require(_status.length == _loanToValue.length &&_status.length <=20,"A0002");
        for (uint256 i = 0; i < _status.length; i++){
                LibAdmin._setCollateralStatusToLoanToValue(_status[i], _loanToValue[i]);
        }
    }

    function getStatusToLoanToValue(uint8 _status)external view returns(uint256){
        return LibAdmin._getCollateralStatusToLoanToValue(_status);
    }


    function unlistedCollateral(uint256 _id) external  {
        LibDiamond.enforceIsContractOwner();
        LibAdmin._transferToBorrowerChangedStatus(_id);
    }

}