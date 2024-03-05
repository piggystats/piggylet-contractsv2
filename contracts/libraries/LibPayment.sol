// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {LibAppStorage,AppStorage,  Collateral,Loan } from "../libraries/LibAppStorage.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IERC721} from "../interfaces/IERC721.sol";
import {LibCollateral} from "./LibCollateral.sol";
import {LibAdmin} from "./LibAdmin.sol";
import {LibFloorPrice} from "./LibFloorPrice.sol";
import {LibLiquidation} from "./LibLiquidation.sol";
import {LibPladFacet} from "./LibPladFacet.sol";


library LibPayment {

    event ChangedItemStatusTo(uint256 collateralId, uint8 newStauts);

    event GivedLoan(
        uint256 collateralId,
        address lenderAddress,
        uint8 liquidationType,
        uint256 treshold,
        uint256 profit
    );
    event Payback(
        uint256 collateralId,
        uint256 profit
    );


    // function _encodeLoan(Loan memory lenderLoan) internal pure returns (bytes memory) {
    //     return abi.encode(lenderLoan);
    // }

    // function _decodeLoan(bytes memory data) internal pure returns (Loan memory lendersLoan) {
    //     (lendersLoan) = abi.decode(data, (Loan));
    // }

    function _getLenderAddress(uint256 _collateralId) internal view returns (address) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        //bytes memory encodedData = s.idToLoan[_collateralId];
        // decode the encoded data and retrieve the APR value
        Loan memory decodedData = s.idToLoan[_collateralId];
        return decodedData.lenderAddress;
    }
    // function _getcollateralId(uint256 _collateralId) internal view returns (uint256) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     // retrieve the encoded data for the specified tokenId
    //     bytes memory encodedData = s.idToLoan[_collateralId];
    //     // decode the encoded data and retrieve the APR value
    //     Loan memory decodedData = _decodeLoan(encodedData);
    //     return decodedData.collateralId;
    // }
    function _getLiquidationType(uint256 _collateralId) internal view returns (uint8) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // retrieve the encoded data for the specified tokenId
        Loan memory decodedData = s.idToLoan[_collateralId];
        return decodedData.liquidationType;
    }

    function _verifyLoan(
        Loan memory lendersLoan,
        uint256 _timeStamp
    ) internal view {
        //AppStorage storage s = LibAppStorage.diamondStorage();
        //require(s.idToLoan[lendersLoan.collateralId].length ==0,"P1");//Already findeded loan
        require(LibCollateral._getListDeadline(lendersLoan.collateralId) >= _timeStamp, "P2");//List Deadline
        require(LibCollateral._getItemStatus(lendersLoan.collateralId) == 1, "P3");//This colleteral not sended for loan
        require(LibCollateral._getSeller(lendersLoan.collateralId) != lendersLoan.lenderAddress, "P4");//You cant give loan yourself
        
        uint256 ltv = LibAdmin._getLoanToValueCollateralId(lendersLoan.collateralId);
        
        if(LibAdmin._getPaymentStatusForToken(LibCollateral._getPaymentToken(lendersLoan.collateralId)) == 2){
            uint256 floorPrice = LibFloorPrice._getFloorPrice(LibCollateral._getCollateralAddress(lendersLoan.collateralId));
            require(LibCollateral._getExpectedPrice(lendersLoan.collateralId) <=((floorPrice*ltv)/100),"P5");//Price cant be max loan amount
        }
        else if(LibAdmin._getPaymentStatusForToken(LibCollateral._getPaymentToken(lendersLoan.collateralId)) == 1){
            IERC20 token = IERC20(LibCollateral._getPaymentToken(lendersLoan.collateralId));
            uint256 tokenDecimal =  token.decimals();
            uint256 floorPrice = LibFloorPrice._getFloorPrice(LibCollateral._getCollateralAddress(lendersLoan.collateralId));
            uint256 floorPriceUSD = (floorPrice*LibAdmin._getETHPrice()/(10**(18-tokenDecimal))/uint256(1000000)); //100
            require(LibCollateral._getExpectedPrice(lendersLoan.collateralId) <=((floorPriceUSD*ltv)/100),"P5");//Price cant be max loan amount
        }
    }


    
    function _addLiqFee(
        uint256 _collateralId,
        uint256 _amount
    ) internal view returns(uint256){
        //eger token weth ise direkt ekle gitsin
        if(LibAdmin._getPaymentStatusForToken(LibCollateral._getPaymentToken(_collateralId)) == 2){
            //uint256 floorPrice = LibFloorPrice._getFloorPrice(LibCollateral._getCollateralAddress(lendersLoan.collateralId));
            return _amount + LibAdmin._getLiqFee();
        }
        else if(LibAdmin._getPaymentStatusForToken(LibCollateral._getPaymentToken(_collateralId)) == 1){
            //uint256 floorPrice = LibFloorPrice._getFloorPrice(LibCollateral._getCollateralAddress(lendersLoan.collateralId));
            IERC20 token = IERC20(LibCollateral._getPaymentToken(_collateralId));
            uint256 tokenDecimal =  token.decimals();
            //su an stable currency calisiyoruz once bunu bi currency'e donusturmemiz lazim
            uint256 liqFeeUsdt = (LibAdmin._getLiqFee()*LibAdmin._getETHPrice()/(10**(18-tokenDecimal))/uint256(1000000)); //100
            return _amount + liqFeeUsdt;
        }
    }


    function convertToEthUSDT(uint256 amountInUSD) internal view returns(uint256) {
        //IERC20 token = IERC20(tokenAddress);
        //return token.decimals();
        uint256 amountInWei = (amountInUSD * 10**6) / LibAdmin._getETHPrice();
        return amountInWei * 10**12; // Convert to wei
    }

    function convertDaiToEth(uint256 daiAmount) internal view returns (uint256) {
        // Assuming 1 ETH = $2000
        uint256 ethAmount = daiAmount * 10**6 / LibAdmin._getETHPrice();
        return ethAmount;
    }

    function _calculatePladFee(
        uint256 _collateralId,
        uint256 _fee
    ) internal view returns(uint256){
        if(LibAdmin._getPaymentStatusForToken(LibCollateral._getPaymentToken(_collateralId)) == 2){
            //eger weth ise direkt cakiyoruz
            //LibPladFacet._setCollateralBorrowerFee(_collateralId, _fee);
            return _fee;
        }
        else if(LibAdmin._getPaymentStatusForToken(LibCollateral._getPaymentToken(_collateralId)) ==1){
            IERC20 token = IERC20(LibCollateral._getPaymentToken(_collateralId));
            uint256 tokenDecimal =  token.decimals();
            //eger token decimal'i var iste bunu donusturmemiz lazim
            if(tokenDecimal ==6){
                //USDT'yi 18 basamaga donusturup kaydettims
                //LibPladFacet._setCollateralBorrowerFee(_collateralId, convertUsdtToEthPrice(LibCollateral._getPaymentToken(_collateralId), _fee)); 
                //return convertUsdtToEthPrice(LibCollateral._getPaymentToken(_collateralId), _fee);
                return convertToEthUSDT(_fee);
            }
            else if(tokenDecimal == 18){
                //dai ile verilmis loanlarda bu islemi gerceklestirdim
                //LibPladFacet._setCollateralBorrowerFee(_collateralId, convertDaiToEthPrice(_fee)); 
                return convertDaiToEth(_fee);
            }
        }
    }


    function _giveLoan(
        Loan memory lendersLoan,//colleteral id lender address
        uint256 _timeStamp
    )internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        _verifyLoan(lendersLoan,_timeStamp);

        //bytes memory encodedColleteral= s.idToCollateral[lendersLoan.collateralId];

        Collateral memory _collateral = s.idToCollateral[lendersLoan.collateralId];
        _collateral.listDeadline =0;
        _collateral.liquidationType = lendersLoan.liquidationType;
        _collateral.paybackDeadline = _timeStamp + (LibCollateral._getPaybackDeadline(lendersLoan.collateralId) * 86400 seconds);
        _collateral.status = 5;

        //bytes memory newEncodedColleteral = LibCollateral._encodeColleteral(decodedData);
        s.idToCollateral[lendersLoan.collateralId] = _collateral;

        //bytes memory encodedLoan = _encodeLoan(lendersLoan);
        //Loan memory decodedData = s.idToLoan[lendersLoan.collateralId];
        s.idToLoan[lendersLoan.collateralId] = lendersLoan;



        if(LibPladFacet.getContractAddress() == address(0) || LibPladFacet._getLevel(LibCollateral._getSeller(lendersLoan.collateralId)) == 0){
            (uint256 payedAmount,uint256 piggysProfit)= _calculateFeeLoan(lendersLoan.collateralId,lendersLoan.lenderAddress);

            // LibAdmin._setLiquidationTresholdCollateral(lendersLoan.collateralId, payedAmount+(payedAmount*uint256(15)/uint256(100)));
            uint8  _colleteralStatus = LibAdmin._getCollateralStatus(LibCollateral._getCollateralAddress(lendersLoan.collateralId));

            LibAdmin._setLiquidationTresholdCollateral(
                lendersLoan.collateralId, 
                payedAmount+(payedAmount*LibAdmin._getStatusToLiqPenalty(_colleteralStatus))/uint256(100));
            
            IERC20(LibCollateral._getPaymentToken(lendersLoan.collateralId)).transferFrom(lendersLoan.lenderAddress, LibCollateral._getSeller(lendersLoan.collateralId), (payedAmount - piggysProfit));
            IERC20(LibCollateral._getPaymentToken(lendersLoan.collateralId)).transferFrom(lendersLoan.lenderAddress, s.diamondAddress, piggysProfit); //piggys fee
            
            emit GivedLoan(
                lendersLoan.collateralId,
                lendersLoan.lenderAddress,
                lendersLoan.liquidationType,
                payedAmount+(payedAmount*LibAdmin._getStatusToLiqPenalty(_colleteralStatus))/uint256(100),
                piggysProfit
            );
        }else{
            (uint256 payedAmount,uint256 piggysProfit)= _calculateFeeLoanTier(lendersLoan.collateralId,lendersLoan.lenderAddress,LibCollateral._getSeller(lendersLoan.collateralId));

            uint8  _colleteralStatus = LibAdmin._getCollateralStatus(LibCollateral._getCollateralAddress(lendersLoan.collateralId));

            LibAdmin._setLiquidationTresholdCollateral(
                lendersLoan.collateralId, 
                payedAmount+(payedAmount*LibAdmin._getStatusToLiqPenalty(_colleteralStatus))/uint256(100));
            
            LibPladFacet._giveFeeToNft(LibCollateral._getSeller(lendersLoan.collateralId),_calculatePladFee(lendersLoan.collateralId,piggysProfit));
            
            IERC20(LibCollateral._getPaymentToken(lendersLoan.collateralId)).transferFrom(lendersLoan.lenderAddress, LibCollateral._getSeller(lendersLoan.collateralId), (payedAmount - piggysProfit));
            IERC20(LibCollateral._getPaymentToken(lendersLoan.collateralId)).transferFrom(lendersLoan.lenderAddress, s.diamondAddress, piggysProfit); //piggys fee
            
            emit GivedLoan(
                lendersLoan.collateralId,
                lendersLoan.lenderAddress,
                lendersLoan.liquidationType,
                payedAmount+(payedAmount*LibAdmin._getStatusToLiqPenalty(_colleteralStatus))/uint256(100),
                piggysProfit
            );
        }

        
    }

    function _acceptBid(
        Loan memory lendersLoan,//colleteral id lender address
        uint256 _timeStamp
    )internal returns(uint256){
        AppStorage storage s = LibAppStorage.diamondStorage();
        _verifyLoan(lendersLoan,_timeStamp);

        //bytes memory encodedColleteral= s.idToCollateral[lendersLoan.collateralId];

        Collateral memory _collateral = s.idToCollateral[lendersLoan.collateralId];
        _collateral.listDeadline =0;
        _collateral.paybackDeadline = _timeStamp + (LibCollateral._getPaybackDeadline(lendersLoan.collateralId) * 86400 seconds);
        _collateral.status = 5;

        //bytes memory newEncodedColleteral = LibCollateral._encodeColleteral(decodedData);
        s.idToCollateral[lendersLoan.collateralId] = _collateral;

        //bytes memory encodedLoan = _encodeLoan(lendersLoan);
        //Loan memory decodedData = s.idToLoan[lendersLoan.collateralId];
        s.idToLoan[lendersLoan.collateralId] = lendersLoan;
        
        //eger tier 0 ise bu
        if(LibPladFacet.getContractAddress() == address(0) || LibPladFacet._getLevel(LibCollateral._getSeller(lendersLoan.collateralId)) == 0){

            (uint256 payedAmount,uint256 piggysProfit)=_calculateFeeLoan(lendersLoan.collateralId,lendersLoan.lenderAddress);
            
            uint8  _colleteralStatus = LibAdmin._getCollateralStatus(LibCollateral._getCollateralAddress(lendersLoan.collateralId));
            
            LibAdmin._setLiquidationTresholdCollateral(
                lendersLoan.collateralId, 
                payedAmount+(payedAmount*LibAdmin._getStatusToLiqPenalty(_colleteralStatus)/uint256(100)));

            IERC20(LibCollateral._getPaymentToken(lendersLoan.collateralId)).transferFrom(lendersLoan.lenderAddress, LibCollateral._getSeller(lendersLoan.collateralId), (payedAmount - piggysProfit));
            IERC20(LibCollateral._getPaymentToken(lendersLoan.collateralId)).transferFrom(lendersLoan.lenderAddress, s.diamondAddress, piggysProfit); //piggys fee

            return piggysProfit;
        }
        else{
            (uint256 payedAmount,uint256 piggysProfit)=_calculateFeeLoanTier(lendersLoan.collateralId,lendersLoan.lenderAddress,LibCollateral._getSeller(lendersLoan.collateralId));

            uint8  _colleteralStatus = LibAdmin._getCollateralStatus(LibCollateral._getCollateralAddress(lendersLoan.collateralId));
            
            LibAdmin._setLiquidationTresholdCollateral(
                lendersLoan.collateralId, 
                payedAmount+(payedAmount*LibAdmin._getStatusToLiqPenalty(_colleteralStatus)/uint256(100)));

            LibPladFacet._giveFeeToNft(LibCollateral._getSeller(lendersLoan.collateralId),_calculatePladFee(lendersLoan.collateralId,piggysProfit));
            
            IERC20(LibCollateral._getPaymentToken(lendersLoan.collateralId)).transferFrom(lendersLoan.lenderAddress, LibCollateral._getSeller(lendersLoan.collateralId), (payedAmount - piggysProfit));
            IERC20(LibCollateral._getPaymentToken(lendersLoan.collateralId)).transferFrom(lendersLoan.lenderAddress, s.diamondAddress, piggysProfit); //piggys fee
            
            return piggysProfit;
        }
    }

    function _calculateFeeLoan(
        uint256 _collateralId,
        address _sender
    ) internal view returns(uint256,uint256){
        AppStorage storage s = LibAppStorage.diamondStorage();

        uint256 payedAmount = LibCollateral._getExpectedPrice(_collateralId);
        //loan fee
        uint256 platformFee = LibAdmin._calculateLoanFee(LibCollateral._getCollateralAddress(_collateralId),payedAmount);
        
        uint256 allowance = IERC20(LibCollateral._getPaymentToken(_collateralId)).allowance(_sender, s.diamondAddress);
        require(allowance >= payedAmount+_addLiqFee(_collateralId, payedAmount), "P009");//Check the token allowance for loan"

        return (payedAmount,platformFee);
    }

    function _calculateFeeLoanTier(
        uint256 _collateralId,
        address _lender,
        address _borrower
    ) internal view returns(uint256,uint256){
        AppStorage storage s = LibAppStorage.diamondStorage();

        uint256 payedAmount = LibCollateral._getExpectedPrice(_collateralId);
        uint8  _status = LibAdmin._getCollateralStatus(LibCollateral._getCollateralAddress(_collateralId));
        uint256 platformFee = LibPladFacet._calculateTierLoanFee(_borrower, payedAmount, _status);
        
        uint256 allowance = IERC20(LibCollateral._getPaymentToken(_collateralId)).allowance(_lender, s.diamondAddress);
        require(allowance >= payedAmount+_addLiqFee(_collateralId, payedAmount), "P009");//Check the token allowance for loan"

        return (payedAmount,platformFee);
    }

    function _verifyPayback(
        uint256 _collateralId,
        uint256 _timestamp,
        address _sender
    ) internal view {
        //AppStorage storage s = LibAppStorage.diamondStorage();
        //require(s.idToLoan[_collateralId].length >0,"P005");//Didnt finded loan
        require(LibCollateral._getPaybackDeadline(_collateralId) >= _timestamp, "P06");//Payback Deadline"
        require(LibCollateral._getItemStatus(_collateralId) == 5, "P07");//This colleteral need finde loan first
        require(LibCollateral._getSeller(_collateralId) == _sender, "P08");//you aren not the person for payback
    }

    function _payback(
        uint256 _collateralId,
        uint256 _timestamp,
        address _sender
    )internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
      
        _verifyPayback(_collateralId,_timestamp,_sender);

        //bytes memory encodedColleteral= s.idToCollateral[_collateralId];
        Collateral memory _collateral = s.idToCollateral[_collateralId];
        _collateral.status = 10;

        s.idToCollateral[_collateralId] = _collateral;

        // bytes memory newEncodedColleteral = LibCollateral._encodeColleteral(decodedData);
        // s.idToCollateral[_collateralId] = newEncodedColleteral;

        if(LibPladFacet.getContractAddress() == address(0) ||  LibPladFacet._getLevel(_getLenderAddress(_collateralId)) == 0){
            (uint256 lenderReturnPayment,uint256 contractsProfit)=_calculateFeePayback(_collateralId, _sender);
            
            IERC20(LibCollateral._getPaymentToken(_collateralId)).transferFrom(_sender, _getLenderAddress(_collateralId), (lenderReturnPayment-contractsProfit));
            IERC20(LibCollateral._getPaymentToken(_collateralId)).transferFrom(_sender, s.diamondAddress, contractsProfit);
            
            IERC721(LibCollateral._getCollateralAddress(_collateralId)).transferFrom(s.diamondAddress, _sender, LibCollateral._getTokenID(_collateralId));
            
            emit Payback(
                _collateralId,
                contractsProfit
            );
        }
        else{
            (uint256 lenderReturnPayment,uint256 contractsProfit)=_calculateFeePaybackTier(_collateralId, _getLenderAddress(_collateralId),_sender);
            //su an borrower payback yapiyor fee lender'a gidecek
            LibPladFacet._giveFeeToNft(_getLenderAddress(_collateralId),_calculatePladFee(_collateralId,contractsProfit));

            IERC20(LibCollateral._getPaymentToken(_collateralId)).transferFrom(_sender, _getLenderAddress(_collateralId), (lenderReturnPayment-contractsProfit));
            IERC20(LibCollateral._getPaymentToken(_collateralId)).transferFrom(_sender, s.diamondAddress, contractsProfit);
            
            IERC721(LibCollateral._getCollateralAddress(_collateralId)).transferFrom(s.diamondAddress, _sender, LibCollateral._getTokenID(_collateralId));
            
            emit Payback(
                _collateralId,
                contractsProfit
            );
        }
        
    }

    function _calculateLenderReturnPayment(
        uint256 _collateralId
    )internal view returns(uint256,uint256) {
        uint256 number  = LibCollateral._getApr(_collateralId)*(LibCollateral._getPaybackDay(_collateralId));
        uint256 efcInterest = ((number*uint256(100))/uint256(365));
        uint256 interest =((efcInterest *LibCollateral._getExpectedPrice(_collateralId))/uint256(10000));
        uint256 lenderReturnPayment = interest + LibCollateral._getExpectedPrice(_collateralId);
        return (lenderReturnPayment,interest);
    }

    function  _calculateFeePayback(
        uint256 _collateralId,
        address _sender
    ) internal view returns(uint256,uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();

        (uint256 lenderReturnPayment,uint256 interest)= _calculateLenderReturnPayment(_collateralId);
        
        uint256 contractsProfit = LibAdmin._calculatePaybackFee(LibCollateral._getCollateralAddress(_collateralId),interest);
    
        uint256 allowance = IERC20(LibCollateral._getPaymentToken(_collateralId)).allowance(_sender, s.diamondAddress);
        require(allowance >= lenderReturnPayment, "P008");//Check the token allowance payback

        return(lenderReturnPayment,contractsProfit);
    }

    function  _calculateFeePaybackTier(
        uint256 _collateralId,
        address _lender,
        address _borrower
    ) internal view returns(uint256,uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();

        (uint256 lenderReturnPayment,uint256 interest)= _calculateLenderReturnPayment(_collateralId);

        //status'a bak

        uint8  _colleteralStatus = LibAdmin._getCollateralStatus(LibCollateral._getCollateralAddress(_collateralId));
        // if(_colleteralStatus == 2){
        uint256 contractsProfit = LibPladFacet._calculateTierPaybackFee(_lender, interest,_colleteralStatus);
    
        uint256 allowance = IERC20(LibCollateral._getPaymentToken(_collateralId)).allowance(_borrower, s.diamondAddress);
        require(allowance >= lenderReturnPayment, "P008");//Check the token allowance payback

        return(lenderReturnPayment,contractsProfit);

    }


    function _verifiyTransferToLenderNotLiqColleteral(
        uint256 _collateralId,
        uint256 _timestamp,
        address _sender
    ) internal view{
        //AppStorage storage s = LibAppStorage.diamondStorage();
        //require(s.idToLoan[_collateralId].length >0,"P014");//Didnt finded loan
        require(_timestamp > LibCollateral._getPaybackDeadline(_collateralId), "P015");//Waiting for borrowers payback
        require(LibCollateral._getItemStatus(_collateralId) == 5, "P014");
        require(_sender == _getLenderAddress(_collateralId),"P016");//you are not lender
    }

    function _verifiyTransferToLenderAfterLiqColleteral(
        uint256 _collateralId,
        uint256 _timestamp,
        address _sender
    ) internal view{
        //AppStorage storage s = LibAppStorage.diamondStorage();
        //require(s.idToLoan[_collateralId].length >0,"P014");
        require(LibCollateral._getItemStatus(_collateralId) == 5, "P014");
        require(_timestamp > LibCollateral._getListDeadline(_collateralId), "P017");//Waiting for liqudators
        require(_sender == _getLenderAddress(_collateralId),"P016");
        
    }

    function _transferToLenderAfterLiqMarket(
        uint256 _collateralId,
        uint256 _timestamp,
        address _sender
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        _verifiyTransferToLenderAfterLiqColleteral(_collateralId, _timestamp, _sender);
        {
            //bytes memory existedColleteral = s.idToCollateral[_collateralId];
            Collateral memory _collateral = s.idToCollateral[_collateralId];
            _collateral.status = 7;
            // bytes memory _encodedData = LibCollateral._encodeColleteral(decodedData);
            // s.idToCollateral[_collateralId] = _encodedData;

            s.idToCollateral[_collateralId] = _collateral;

        }
        IERC721(LibCollateral._getCollateralAddress(_collateralId)).transferFrom(s.diamondAddress, _sender, LibCollateral._getTokenID(_collateralId));
        emit ChangedItemStatusTo(_collateralId, 7);
    }

    function _transferToLenderNotLiqColleteral(
        uint256 _collateralId,
        uint256 _timestamp,
        address _sender
    )  internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        _verifiyTransferToLenderNotLiqColleteral(_collateralId, _timestamp, _sender);

        {
            //bytes memory existedColleteral = s.idToCollateral[_collateralId];
            Collateral memory _collateral = s.idToCollateral[_collateralId];
            _collateral.status = 7;
            //bytes memory _encodedData = LibCollateral._encodeColleteral(decodedData);
            s.idToCollateral[_collateralId] = _collateral;
        }
        IERC721(LibCollateral._getCollateralAddress(_collateralId)).transferFrom(s.diamondAddress, _sender, LibCollateral._getTokenID(_collateralId));
        emit ChangedItemStatusTo(_collateralId, 7);
    }

    function _transferToLender(
        uint256 _collateralId,
        uint256 _timestamp,
        address _sender
    ) internal {
        //4 farkli senaryo var
        //1 aldim geri odemedim
        //2 liqte listeledik satilmadi
        //3 aldim nft floor price liq tresholdun altina dustu
        //4 usdc aldim eth valutiondan dolayi liq olma durumu olustu bu
        
        //AppStorage storage s = LibAppStorage.diamondStorage();
        uint8 status = LibCollateral._getItemStatus(_collateralId);
        if(status == 6){
            _transferToLenderAfterLiqMarket(_collateralId, _timestamp, _sender);
        }
        //Loan aldim liq price dustu
        else if(status == 5){
            _transferToLenderNotLiqColleteral(_collateralId, _timestamp, _sender);
        }
        else{
            revert("P019");//Not appropriate status
        }
    }

    function _recoveryColleteralForTest(
        uint256 _collateralId,
        address _sender
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        {
            //bytes memory existedColleteral = s.idToCollateral[_collateralId];
            Collateral memory _collateral = s.idToCollateral[_collateralId];
            _collateral.status = 7;
            //bytes memory _encodedData = LibCollateral._encodeColleteral(decodedData);
            s.idToCollateral[_collateralId] = _collateral;
        }

        IERC721(LibCollateral._getCollateralAddress(_collateralId)).transferFrom(s.diamondAddress, _sender, LibCollateral._getTokenID(_collateralId));
        emit ChangedItemStatusTo(_collateralId, 7);
    }
}