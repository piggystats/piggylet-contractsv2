// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {LibPladFacet} from "../libraries/LibPladFacet.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";


contract PladFacet{

    function setUserTierNft(uint256 _tokenId) external {
        LibPladFacet._setUserSelectedNft(msg.sender, _tokenId);
    }

    function getUserTierNft() external view returns(uint256) {
        return LibPladFacet._getUserSelectedNft(msg.sender);
    }

    function campain(uint256 _tokenId,uint256 _fee) external {
        LibDiamond.enforceIsContractOwner();
        LibPladFacet._campain(_tokenId, _fee);
    }

    function setContractAddress(address _newAddress) external {
        LibDiamond.enforceIsContractOwner();
        LibPladFacet.setContractAddress(_newAddress);
    }

    function getContractAddress() external view returns(address) {
        return LibPladFacet.getContractAddress();
    }

    function getLevel() external view returns(uint256) {
        return LibPladFacet._getLevel(msg.sender);
    }


    function setTierStatusPaybackFee(uint256 _tier,uint8 _status,uint256 _fee) external {
        LibDiamond.enforceIsContractOwner();
        LibPladFacet._setTierToStatusLenderFee(_tier,_status, _fee);
    }

    function getTierToPaybackFee(uint256 _tier,uint8 _status) external view returns(uint256) {
        return LibPladFacet._getTierToStatusLenderFee(_tier,_status);
    }


    function setTierStatusBorrowerFee(uint256 _tier,uint8 _status,uint256 _fee) external {
        LibDiamond.enforceIsContractOwner();
        LibPladFacet._setTierToStatusBorrowerFee(_tier, _status, _fee);
    }

    function getTierStatusBorrowerFee(uint256 _tier,uint8 _status) external view returns(uint256) {
        return LibPladFacet._getTierToStatusBorrowerFee(_tier, _status);
    }

}
