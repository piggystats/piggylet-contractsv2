// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;
// import {LibAppStorage,AppStorage,Collateral,Pool,PoolLoan} from "../libraries/LibAppStorage.sol";
// import {IERC721} from "../interfaces/IERC721.sol";
// import {IERC1155} from "../interfaces/IERC1155.sol";
// import {IERC20} from "../interfaces/IERC20.sol";
// import {LibAdmin} from "../libraries/LibAdmin.sol";
// import {LibCollateral} from "../libraries/LibCollateral.sol";


// // interface IERC20 {
// //     function decimals() external view returns (uint8);
// // }

// library LibPool{
//     struct DiamondStorage {
//         uint256 poolId;
//         mapping(uint256 => uint256) idToGivedLoan; 
//         mapping(uint256 => uint256) idToPaybackLoan; 
//         mapping(uint256 => uint256) idToPoolBalance;
//         //pool's status 
//         mapping(uint256 => mapping(uint8 => uint256)) idStatusLTV;
//         mapping(uint256 => mapping(uint8 => uint256)) idStatusFee;
//         mapping(uint256 => mapping(uint8 => uint256)) idStatusLiqPenalty;
//         mapping(uint256 => mapping(address => bool)) idAcceptedCollateral;//pool accepted collateral
//         // ... any number of other state variables
//     }

//     // return a struct storage pointer for accessing the state variables
//     function diamondStorage() internal pure returns (DiamondStorage storage ds) {
//         bytes32 position = keccak256("diamond.standard.diamond.LibPool");
//         assembly {
//             ds.slot := position
//         }
//     }

//     function _incerementPoolId()internal {
//         DiamondStorage storage ds = diamondStorage();
//         ds.poolId ++;
//     }
//     function _getPoolId() internal view returns(uint256){
//         DiamondStorage storage ds = diamondStorage();
//         return ds.poolId;
//     }

//     event PoolCreate(
//         Pool pool
//     );

//     event LoanTaken(
//         Collateral collateral,
//         PoolLoan pool
//     );


//     function _poolVerify(
//         Pool memory poolParam
//     ) internal view returns(Pool memory){
//         //require(poolParam.paybackDeadline <= 90 && collateralParam.paybackDeadline ==collateralParam.paybackDay , "C005");//Deadine should be less than 90 days s
//         //require(poolParam.fee <= 100, "C006");//List deadline should be less than 30 days 
//         //equire(collateralParam.listDeadline >= 7, "C007");//List deadline should be more than 7 days 
//         //require(collateralParam.apr > 0, "C008");//APR Must be greater than zero"
//         //require(LibAdmin._getWhitelistCollateral(collateralParam.collateralAddress),"C009");//This collection is not supported
//         //require(LibAdmin._getApprovedToken(collateralParam.paymentToken),"C010");//This token is not supported
        
//         //uint256 expectedPrice =_checkPrice(collateralParam.collateralId,collateralParam.collateralAddress, collateralParam.expectedPrice,collateralParam.paymentToken);
//         //collateralParam.expectedPrice = expectedPrice;
//         //collateralParam.listDeadline = _timestamp + (collateralParam.listDeadline * 86400 seconds);
//         poolParam.poolId = _getPoolId();
//         // collateralParam.liquidationType = 0;
//         return poolParam;
//     }

//     function _setPoolBalance(
//         uint256 _poolId,
//         uint256 _balance
//     ) internal {
//         DiamondStorage storage ds = diamondStorage();
//         ds.idToPoolBalance[_poolId]= _balance;
//     }

//     function _increseGiveLoan(
//         uint256 _poolId,
//         uint256 _balance
//     ) internal {
//         DiamondStorage storage ds = diamondStorage();
//         ds.idToPoolBalance[_poolId] += _balance;
//     }

//     function _getPoolBalance(
//         uint256 _poolId
//     ) internal view returns(uint256) {
//         DiamondStorage storage ds = diamondStorage();
//         return ds.idToPoolBalance[_poolId];
//     }


//     function _createPool(
//         Pool memory poolParam
//     )internal {
//         AppStorage storage s = LibAppStorage.diamondStorage();
//         Pool memory verifiedPool= _poolVerify(poolParam);

//         _incerementPoolId();

//         //bytes memory encodedData = _encodeColleteral(verifiedCollateral);

//         // if(verifiedCollateral.colleteralType == 1){//erc721
//         //     IERC721(verifiedCollateral.collateralAddress).transferFrom(_sender, s.diamondAddress, verifiedCollateral.tokenId);
//         // }
//         // else if(verifiedCollateral.colleteralType == 2){//erc1155
//         //     IERC1155(verifiedCollateral.collateralAddress).safeTransferFrom(_sender, s.diamondAddress, verifiedCollateral.tokenId,verifiedCollateral.amount,"");
//         // }
//         // else if(verifiedCollateral.colleteralType == 3){//erc20
//         //     IERC20(verifiedCollateral.collateralAddress).transferFrom(_sender, s.diamondAddress, verifiedCollateral.amount);
//         // }

//         //IERC721(verifiedCollateral.collateralAddress).transferFrom(_sender, s.diamondAddress, verifiedCollateral.tokenId);

        
//         s.idToPool[verifiedPool.poolId] = verifiedPool;

//         emit PoolCreate(
//             verifiedPool
//         );
//     }

//     function _utilizationRate(
//         uint256 _poolId
//     ) internal view returns(uint256){
//         DiamondStorage storage ds = diamondStorage();
//         //utitization rate = pooldan cikan/pool size * 100
//         //utilization rate eger critical rate >= olursa hepsi critical'a gore hesaplanacak.

//         uint256 utilizationrate = ((ds.idToGivedLoan[_poolId] - ds.idToPaybackLoan[_poolId]/ds.idToPoolBalance[_poolId])*100);
//         return utilizationrate;
//     }

//     function _borrowerRate(
//         uint256 _poolId
//     ) internal view returns(uint256){
//         AppStorage storage s = LibAppStorage.diamondStorage();
//         //utitization rate = pooldan cikan/pool size * 100
//         //utilization rate eger critical rate >= olursa hepsi critical'a gore hesaplanacak.
//         //Base Rate+(Utilization Rate*Slope)
//         // critical Borrower Rate+((Utilization Rate-Borrow Rate)*Slope Critical))
//         Pool memory _pool = s.idToPool[_poolId];

//         uint256 borrowerRate =((_pool.baseRate+(_utilizationRate(_poolId)*_pool.slope))/100);
//         return borrowerRate;
//     }
    
//     function _borrowerRateCritical(
//         uint256 _poolId
//     ) internal view returns(uint256){
//         AppStorage storage s = LibAppStorage.diamondStorage();
//         //utitization rate = pooldan cikan/pool size * 100
//         //utilization rate eger critical rate >= olursa hepsi critical'a gore hesaplanacak.
//         //Base Rate+(Utilization Rate*Slope)
//         // critical = Borrower Rate+((Utilization Rate-Borrow Rate)*Slope Critical))
//         Pool memory _pool = s.idToPool[_poolId];

//         uint256 borrowerRateCritical =_borrowerRate(_poolId)+ ((_utilizationRate(_poolId)-_borrowerRate(_poolId))*_pool.slopeCritical);
//         return borrowerRateCritical;
//     }


//     function _collateralVerifyPool(
//         Collateral memory collateralParam
//     ) internal view returns(Collateral memory){
//         require(collateralParam.paybackDeadline <= 90 && collateralParam.paybackDeadline ==collateralParam.paybackDay , "C005");//Deadine should be less than 90 days s
//         require(collateralParam.listDeadline <= 30, "C006");//List deadline should be less than 30 days 
//         require(collateralParam.listDeadline >= 7, "C007");//List deadline should be more than 7 days 
//         require(collateralParam.apr > 0, "C008");//APR Must be greater than zero"
        
//         require(LibAdmin._getWhitelistCollateral(collateralParam.collateralAddress),"C009");//This collection is not supported
//         require(LibAdmin._getApprovedToken(collateralParam.paymentToken),"C010");//This token is not supported
        

//         collateralParam.paybackDeadline = 0;
//         collateralParam.paybackDay = 0;
//         collateralParam.listDeadline = 0;
//         collateralParam.status = 3;
//         collateralParam.collateralId = LibCollateral._getCollateralID();
//         collateralParam.liquidationType = 0;
//         return collateralParam;
        
//     }

//     function _loanVerify(
//         PoolLoan memory _loan
//     ) internal view returns(PoolLoan memory){
//         // require(collateralParam.paybackDeadline <= 90 && collateralParam.paybackDeadline ==collateralParam.paybackDay , "C005");//Deadine should be less than 90 days s
//         // require(collateralParam.listDeadline <= 30, "C006");//List deadline should be less than 30 days 
//         // require(collateralParam.listDeadline >= 7, "C007");//List deadline should be more than 7 days 
//         // require(collateralParam.apr > 0, "C008");//APR Must be greater than zero"
//         // require(LibAdmin._getWhitelistCollateral(collateralParam.collateralAddress),"C009");//This collection is not supported
//         // require(LibAdmin._getApprovedToken(collateralParam.paymentToken),"C010");//This token is not supported
        
//         // collateralParam.expectedPrice = 0;
//         // collateralParam.paybackDeadline = 0;
//         // collateralParam.paybackDay = 0;
//         // collateralParam.listDeadline = 0;
//         // collateralParam.status = 3;
//         // collateralParam.collateralId = LibCollateral._getCollateralID();
//         // collateralParam.liquidationType = 0;
//         return _loan;
        
//     }

//     function _takeLoan(
//         uint256 _poolId,
//         address _sender,
//         Collateral memory _colleteral
//     )internal {
//         AppStorage storage s = LibAppStorage.diamondStorage();

//         Collateral memory verifiedCollateral= _collateralVerifyPool(_colleteral);
//         PoolLoan memory verifiedloan;

//         verifiedloan.collateralId = verifiedCollateral.collateralId;
//         verifiedloan.time = block.timestamp;
//         verifiedloan.amount = verifiedCollateral.expectedPrice;
//         verifiedloan.repayamount = 0;
//         verifiedloan.lenderAddress =_sender;


//         LibCollateral._incerementCollateralID();
        
//         s.idToCollateral[verifiedCollateral.collateralId] = verifiedCollateral;
//         s.idToPoolLoan[verifiedCollateral.collateralId] = verifiedloan;

//         //pool'un gived  loan'i arttir
//         require(
//             IERC20(verifiedCollateral.paymentToken).balanceOf(s.diamondAddress) >= verifiedCollateral.expectedPrice,
//             "Insufficient balance"
//         );

//         // Approve the contract to spend tokens on behalf of the sender
//         require(
//             IERC20(verifiedCollateral.paymentToken).approve(s.diamondAddress, verifiedCollateral.expectedPrice),
//             "Approval failed"
//         );

//         IERC721(verifiedCollateral.collateralAddress).transferFrom(
//             _sender, 
//             s.diamondAddress, 
//             verifiedCollateral.tokenId
//         );

         
//         IERC20(verifiedCollateral.paymentToken).transferFrom(
//             s.diamondAddress, 
//             _sender,
//             verifiedCollateral.expectedPrice
//         );
        
//         emit LoanTaken(
//             verifiedCollateral,
//             verifiedloan
//         );
//     }

//     /*

//         farkli sartlarda bir pool'dan farkli nft koleksyonlari loan alabilmeli
//         ornegin bir pool icinde 
//         birden fazla colleteral adresi birden fazla colleteral tipi
//         ayni pool icinde bir nft koleksyonunun ltv fee liqPenalty birbirinden farkli olabilir. s
//         tatus gibi hatta status


//         utitization rate = pooldan cikan/pool size * 100
//         utilization rate eger critical rate >= olursa hepsi critical'a gore hesaplanacak.


//         //gonderdigi anda para adamin hesabina gecmeli
//         //adama para gonderirken hesabindan %0.95 kadar ekle

//         //lender rate ile alakam yok
//         //payback yaparken de borrower rate'e gore islem yapilmali

//         //borc aldigim zamandan itibaren 2 gun gecti
//         //ilk gunun ortalamasi %16 ikinci gunun ortalamasi %24

//         aldigim loan ile o gunun dailysini aldim loan * 16/100/365


//     */


     



// }