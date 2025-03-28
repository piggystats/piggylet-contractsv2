// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Collateral} from "../libraries/LibAppStorage.sol";
import {LibCollateral} from "../libraries/LibCollateral.sol";

contract CollateralFacet {

    function sendForSearchBids(
        Collateral memory collateral
    ) external {
        LibCollateral._sendCollateralSearchBids(collateral, block.timestamp,msg.sender);
    }

    function sendForLoan(
        Collateral memory collateral
    ) external {
        LibCollateral._sendForLoan(collateral, block.timestamp,msg.sender);
    }

    function bundleLoan(
        Collateral[] memory collateral
    ) external {
        require(collateral.length <=10,"10");
        for (uint256 i = 0; i < collateral.length; i++){
            LibCollateral._sendForLoan(collateral[i],block.timestamp,msg.sender);
        }
    }
    
    //update colleteral payment
    function updateCollateral(
        Collateral memory collateral
    ) external {
        LibCollateral._updateCollateral(
            collateral,
            block.timestamp,
            msg.sender
        );
    }

    

    function cancelLoanRequest(
        uint256 _collateralId
    ) external {
        LibCollateral._cancelLoanRequest(_collateralId,msg.sender);
    }

    function viewtype(uint256 _collateralId) external view returns(uint8){
        return LibCollateral._getTokenType(_collateralId);
        
    }

    function viewAmount(uint256 _collateralId) external view returns(uint256){
        return LibCollateral._getAmount(_collateralId);
    }

}
