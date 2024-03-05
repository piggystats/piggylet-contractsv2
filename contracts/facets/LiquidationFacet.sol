// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Liquidation} from "../libraries/LibAppStorage.sol";
import {LibLiquidation} from "../libraries/LibLiquidation.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract LiquidationFacet  {

    function setLiquidation(
        Liquidation memory liquidationData
    )external {
        LibDiamond.enforceIsContractOwner();
        LibLiquidation._setLiqColleteral(liquidationData);
    }

    function bundleLiquidation(
        Liquidation[] memory liquidationData
    )external {
        LibDiamond.enforceIsContractOwner();
        require(liquidationData.length<=20,"L001");
        for (uint256 i = 0; i < liquidationData.length; i++){
            LibLiquidation._setLiqColleteral(liquidationData[i]);
        }
    }


    function transferToLiquidator(
        uint256 _collateralId
    ) external {
        LibLiquidation._transferToLiquidator(_collateralId, msg.sender);
    }


    // function changeLiquidationTime(
    //     uint256 _collateralId
    // )external  {
    //     LibDiamond.enforceIsContractOwner();
    //     LibLiquidation._testLiquidationTime(_collateralId,block.timestamp);
    // }
}