// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;
// import {LibPool} from "../libraries/LibPool.sol";
// import {LibDiamond} from "../libraries/LibDiamond.sol";
// import {Collateral,Pool,PoolLoan} from "../libraries/LibAppStorage.sol";

// contract PoolFacet{

//     function createPool(
//         Pool memory pool
//     ) external {
//         LibPool._createPool(pool);
//     }

//     function setPoolBalance(
//         uint256 _poolId,
//         uint256 _balance
//     ) external {
//         LibPool._setPoolBalance(_poolId, _balance);
//     }


//     function takeLoan(
//         uint256 _poolId,
//         Collateral memory _colleteral
//     ) external {
//         LibPool._takeLoan(_poolId,msg.sender, _colleteral);
//     }
// }
