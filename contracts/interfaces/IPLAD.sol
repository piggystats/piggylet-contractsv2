// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPLAD{
    function setFee(uint256 _tokenId,uint256 _fee) external;
    function setLevel(uint256 _tokenId,uint256 _level) external;
    function getLevel(address _userAccnt) external view returns(uint256);
    function getFee(uint256 _tokenId) external view returns(uint256);
    function getTier(uint256 _tokenId) external view returns(uint256);
}