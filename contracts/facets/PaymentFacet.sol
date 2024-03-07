// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Loan} from "../libraries/LibAppStorage.sol";
import {LibPayment} from "../libraries/LibPayment.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract PaymentFacet{

    function giveLoan(
        Loan memory lendersLoan
    ) external {
        LibPayment._giveLoan(lendersLoan,block.timestamp);

    }

    function giveLoanBundle(
        Loan[] memory lendersLoan
    )external{
        require(lendersLoan.length <= 10,"10");
        for (uint256 i = 0; i < lendersLoan.length; i++) {
            LibPayment._giveLoan(lendersLoan[i],block.timestamp);
        }
    }

    function payBack(
        uint256 _collateralId
    ) external  {
        LibPayment._payback(_collateralId, block.timestamp, msg.sender);
    }


    function transferToLender(
        uint256 _collateralId
    ) external  {
        LibPayment._transferToLender(_collateralId, block.timestamp, msg.sender);
    }

    // function decodeLoan(bytes memory data) external pure returns (Loan memory lendersLoan) {
    //     (lendersLoan) = abi.decode(data, (Loan));
    // }

    function recovery(
        uint256 _collateralId
    )external  {
        LibDiamond.enforceIsContractOwner();
        LibPayment._recoveryColleteralForTest(_collateralId, msg.sender);
    }

}