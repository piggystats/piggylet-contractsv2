// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibFloorPrice} from "../libraries/LibFloorPrice.sol";
import {FloorPrice} from "../libraries/LibAppStorage.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract FloorPriceFacet  {

    function setFloorPriceData(
        FloorPrice memory floorPrice
    )external {
        LibDiamond.enforceIsContractOwner();
        LibFloorPrice._setFloorPrice(floorPrice);
    }


    function bundleFloorPrice(
        FloorPrice[] memory floorPrice
    )external {
        LibDiamond.enforceIsContractOwner();
        require(floorPrice.length<=20,"20");
        for (uint256 i = 0; i < floorPrice.length; i++){
            LibFloorPrice._setFloorPrice(floorPrice[i]);
        }
    }
}