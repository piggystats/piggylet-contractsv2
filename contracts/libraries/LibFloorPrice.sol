// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;
// import {LibAppStorage,AppStorage, FloorPrice} from "../libraries/LibAppStorage.sol";
// // This library has the state variables 'contractAddress' and 'name'
// //import {LibColleteral} from "./LibColleteral.sol";

// library LibFloorPrice {

//     event FloorPriceEvent(
//         FloorPrice floorPrice
//     );
    
//     // defining state variables
    

//     // function _encodeFloorPrice(FloorPriceData memory floorPriceData) internal pure returns (bytes memory) {
//     //     return abi.encode(floorPriceData);
//     // }

//     // function _decodeFloorPrice(bytes memory data) internal pure returns (FloorPriceData memory floorPriceData) {
//     //     (floorPriceData) = abi.decode(data, (FloorPriceData));
//     // }


//     function _setFloorPrice(FloorPrice memory floorPrice) internal {
//         AppStorage storage s = LibAppStorage.diamondStorage();
//         //bytes memory encodedData = _encodeFloorPrice(floorPriceData);
//         //FloorPriceData memory _floorPrice;

//         s.addressTofloorPrice[floorPrice.collateralAddress] = floorPrice;

//         emit FloorPriceEvent(
//             floorPrice
//         );
        
//     }
    
    
//     // function _getFloorPriceData(address _collateralAddress) internal view returns(FloorPrice memory floorPrice){
//     //     AppStorage storage s = LibAppStorage.diamondStorage();
//     //     FloorPriceData memory _floorPrice = s.addressTofloorPriceData[_collateralAddress];
//     //     (floorPriceData) = _floorPrice;
//     // }

//     function _getFloorPrice(address _collateralAddress) internal view returns (uint256) {
//         AppStorage storage s = LibAppStorage.diamondStorage();
//         // retrieve the encoded data for the specified tokenId
//         FloorPrice memory _floorPrice = s.addressTofloorPrice[_collateralAddress];
//         return _floorPrice.floorPrice;
//     }


// }