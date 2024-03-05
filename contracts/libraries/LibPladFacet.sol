// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {LibCollateral} from "./LibCollateral.sol";
import {LibAdmin} from "./LibAdmin.sol";

interface IPLAD{
    function setFee(uint256 _tokenId,uint256 _fee) external;
    function setLevel(uint256 _tokenId,uint256 _level) external;
    function getLevel(address _userAccnt) external view returns(uint256);
    function getFee(uint256 _tokenId) external view returns(uint256);
    function getTier(uint256 _tokenId) external view returns(uint256);
}

interface IERC721{
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

library LibPladFacet {

    struct DiamondStorage {
        mapping(uint256 => mapping(uint8 => uint256)) tierStatusBorrowFee; //tier 1 borrower fee greenlight status 
        mapping(uint256 => mapping(uint8 => uint256)) tierStatusLenderFee; //tier 1 lender fee greenlight status 
        mapping(address => uint256) userSelectedNft;
        address nftContractAddress;
    }
    event UserTierNft(uint256 tokenid, address walletAddress);

    // return a struct storage pointer for accessing the state variables
    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = keccak256("diamond.standard.diamond.LibPladFacet");
        assembly {
            ds.slot := position
        }
    }
    function setContractAddress(
        address _newAddress
    ) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.nftContractAddress= _newAddress;
    }

    function getContractAddress() internal view returns(address) {
        DiamondStorage storage ds = diamondStorage();
        return ds.nftContractAddress;
    }


    function _setTierToStatusBorrowerFee(uint256 _tier,uint8 _status,uint256 _fee) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.tierStatusBorrowFee[_tier][_status] = _fee;
    }

    function _getTierToStatusBorrowerFee(uint256 _tier,uint8 _status)internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        return ds.tierStatusBorrowFee[_tier][_status];
    }  


    function _setTierToStatusLenderFee(uint256 _tier,uint8 _status,uint256 _fee) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.tierStatusLenderFee[_tier][_status] = _fee;
    }

    function _getTierToStatusLenderFee(uint256 _tier,uint8 _status)internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        return ds.tierStatusLenderFee[_tier][_status];
    }



    function _setUserSelectedNft(address _sender,uint256 _tokenId) internal {
        DiamondStorage storage ds = diamondStorage();
        require(_sender == IERC721(ds.nftContractAddress).ownerOf(_tokenId),"T003");
        ds.userSelectedNft[_sender] = _tokenId;

        emit UserTierNft(_tokenId,_sender);
    }

    function _getUserSelectedNft(address _sender)internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        return ds.userSelectedNft[_sender];
    }


    function _getLevel(address _user)internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        if(ds.nftContractAddress == address(0)){
            return 0;
        }
        else{
            return IPLAD(ds.nftContractAddress).getLevel(_user);
        }
    }

    function _calculateTierLoanFee(address _userAddress,uint256 _amount,uint8 _status) internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        //uint8 _status = LibAdmin._getColleteralStatus(_colleteralAddress);
        //tier 1 icin status'u su olan fee
        if(ds.nftContractAddress == address(0)){
            return 0;
        }
        return ((_amount*ds.tierStatusBorrowFee[_getLevel(_userAddress)][_status])/10000);
    }
    function _calculateTierPaybackFee(address _userAddress,uint256 _amount,uint8 _status) internal view returns(uint256){
        DiamondStorage storage ds = diamondStorage();
        //ColleteralStatus _status = ds.addressToColleteralStatus[_nftContract];
        if(ds.nftContractAddress == address(0)){
            return 0;
        }
        return ((_amount*ds.tierStatusLenderFee[_getLevel(_userAddress)][_status])/10000);
    }


    // function _calculateTierLiqudationFee(address _userAddress,uint256 _amount) internal view returns(uint256){
    //     DiamondStorage storage ds = diamondStorage();
    //     //ColleteralStatus _status = ds.addressToColleteralStatus[_nftContract];
    //     return ((_amount*ds.tierTolLiqudationFee[_getUserLevel(_userAddress)])/1000);
    // }

    function calculateTier(
        uint256 _tokenId
    ) internal {
        //ilgili nft'nin su an ki tier'i nedir ?
        DiamondStorage storage ds = diamondStorage();
        uint256 fee = IPLAD(ds.nftContractAddress).getFee(_tokenId);
        uint256 tier = IPLAD(ds.nftContractAddress).getTier(_tokenId);

        if(tier == 1 && fee >= uint256(1000000000000000)){//1 ether test icin 3 sifir sildim
            //ds.idToTier[_tokenId]=2;
            IPLAD(ds.nftContractAddress).setLevel(_tokenId,2);
        }else if(tier == 2 && fee >= uint256(2000000000000000)){//2 ether
            //ds.idToTier[_tokenId]=3;
            IPLAD(ds.nftContractAddress).setLevel(_tokenId,3);
        }
        else if(tier == 3 && fee >= uint256(6000000000000000)){//6 ether
            //ds.idToTier[_tokenId]=4;
            IPLAD(ds.nftContractAddress).setLevel(_tokenId,4);
        }
        else if(tier == 4 && fee >= uint256(16000000000000000)){//16 ether
            //ds.idToTier[_tokenId]=5;
            IPLAD(ds.nftContractAddress).setLevel(_tokenId,5);
        }
    }



    function _giveFeeToNft(
        address _sender,
        uint256 _fee
    ) internal {
        DiamondStorage storage ds = diamondStorage();
        uint256 selectedNftId = ds.userSelectedNft[_sender];
        if(selectedNftId != 0 ){
            if(_sender == IERC721(ds.nftContractAddress).ownerOf(selectedNftId)){
                IPLAD(ds.nftContractAddress).setFee(selectedNftId,_fee);
                //calculateTier(selectedNftId);
            }
        }
    }

    function _campain(
        uint256 _tokenId,
        uint256 _fee
    ) internal {
        DiamondStorage storage ds = diamondStorage();
        //uint256 selectedNftId = ds.userSelectedNft[_sender];
        IPLAD(ds.nftContractAddress).setFee(_tokenId,_fee);
        //calculateTier(selectedNftId);
    }
        
    // function _giveLenderFeeToNft(
    //     address _sender,
    //     uint256 _fee
    // ) internal {
    //     DiamondStorage storage ds = diamondStorage();
    //     uint256 selectedNftId = ds.userSelectedNft[_sender];
    //     if(selectedNftId != 0 ){
    //         if(_sender == IERC721(ds.nftContractAddress).ownerOf(selectedNftId)){
    //             IPLAD(ds.nftContractAddress).setFee(selectedNftId,_fee);
    //             calculateTier(selectedNftId);
    //         }
    //     }
    
    // }
    

    // function _giveLiqudationFeeToNft(
    //     uint256 _colleteralId,
    //     address _sender,
    //     uint256 _fee
    // ) internal {
    //     DiamondStorage storage ds = diamondStorage();
    //     require(_sender == IERC721(ds.contractAddress).ownerOf(ds.userSelectedNft[_sender]),"T003");
    //     require(ds.colleteralLiqudatorAddress[_colleteralId] == _sender,"T001");//sen liqudator musun

    //     IPLAD(ds.contractAddress).setFee(ds.userSelectedNft[_sender],_fee);

    //     calculateTier(ds.userSelectedNft[_sender]);
    // }  
}


/*


    function setMaxMintCount(
        uint256 _count
    ) internal  {
        DiamondStorage storage ds = diamondStorage();
        ds.mintCount=_count; 
    }

    function getMaxMintCount() internal view returns(uint256) {
        DiamondStorage storage ds = diamondStorage();
        return ds.mintCount;
    }

    function getTokenIdCounter() internal view returns(uint256) {
        DiamondStorage storage ds = diamondStorage();
        return ds.tokenIdCounter;
    }
    function setRoundMintCount(
        uint256 _round,
        uint256 _count
    ) internal  {
        DiamondStorage storage ds = diamondStorage();
        ds.roundsToMaxCount[_round] = _count;
    }
    
    function getRoundMintCount(
        uint256 _round
    ) internal view returns(uint256) {
        DiamondStorage storage ds = diamondStorage();
        return ds.roundsToMaxCount[_round];
    }

    function setIdToTokenUri(
        uint256 _id,
        string memory _uri
    ) internal  {
        DiamondStorage storage ds = diamondStorage();
        ds.idToTokenUri[_id] = _uri;
    }

    function getIdToTokenUri(
        uint256 _id
    ) internal view returns(string memory) {
        DiamondStorage storage ds = diamondStorage();
        return ds.idToTokenUri[_id];
    }

    function setTier1Count(
        uint256 _count
    ) internal  {
        DiamondStorage storage ds = diamondStorage();
        ds.tier1Count=_count;
    }
    function setTier2Count(
        uint256 _count
    ) internal  {
        DiamondStorage storage ds = diamondStorage();
        ds.tier2Count=_count;
    }
    function setTier3Count(
        uint256 _count
    ) internal  {
        DiamondStorage storage ds = diamondStorage();
        ds.tier3Count=_count;
    }
    function setTier4Count(
        uint256 _count
    ) internal  {
        DiamondStorage storage ds = diamondStorage();
        ds.tier4Count=_count;
    }
    function setTier5Count(
        uint256 _count
    ) internal  {
        DiamondStorage storage ds = diamondStorage();
        ds.tier5Count=_count;
    }
    

    

    
    //uint256 private randNonce = 0;

    
    function safeMintPlad(
        address _sender,
        uint256 _timestamp
    ) internal {
        DiamondStorage storage ds = diamondStorage();
        require(ds.addressToMint[_sender] < ds.mintCount, "M1");
        uint256  _modulus = 5; 
        ds.randNonce++;
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(_timestamp,_sender,ds.randNonce))) % _modulus;
        uint256 tierToMint;

        if (randomNumber == 0 && ds.tier1Count > 0) {
            tierToMint = 1;
            ds.tier1Count--;
        } else if (randomNumber == 1 && ds.tier2Count > 0) {
            tierToMint = 2;
            ds.tier2Count--;
        } else if (randomNumber == 2 && ds.tier3Count > 0) {
            tierToMint = 3;
            ds.tier3Count--;
        } else if (randomNumber == 3 && ds.tier4Count > 0) {
            tierToMint = 4;
            ds.tier4Count--;
        } else if (randomNumber == 4 && ds.tier5Count > 0) {
            tierToMint = 5;
            ds.tier5Count--;
        } else {
            tierToMint = 1; // Assign tier 1 if no available tokens in the selected tier
            ds.tier1Count--;
        }

        //TODO bunu cozelim
        
        //_setTokenURI(tokenIdCounter, "1.json"); // bunu cozmemiz lazim
        ds._ownerOfTokenByIndex[_sender].push(ds.tokenIdCounter);

        ds.idToTier[ds.tokenIdCounter] = tierToMint;
        ds.tokenIdCounter++;
        ds.addressToMint[_sender] += 1;
    }


    function setContractAddress(
        address _newAddress
    ) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.contractAddress= _newAddress;
    }

    function getContractAddress() internal view returns(address) {
        DiamondStorage storage ds = diamondStorage();
        return ds.contractAddress;
    }

    // function openPacked(
    // ) internal {
    //     DiamondStorage storage ds = diamondStorage();
    //     ds.isPackNFT= false;
    // }

    // function isPackTrue(
    // ) internal {
    //     DiamondStorage storage ds = diamondStorage();
    //     ds.isPackNFT= true;
    // }

    // function gettokenURI(uint256 tokenId)
    //     internal
    //     view
    //     returns (string memory)
    // {
    //     DiamondStorage storage ds = diamondStorage();
    //     if(ds.isPackNFT == true){
    //         return "ipfs://QmSLVi8dDDbdKJEAAABQyCNtPU2uEprTBnS4vBfjx7ToFD/1.json";
    //     }
    //     else{
    //         //uint256 tier = ds.idToTier[tokenId];
    //         if(ds.idToTier[tokenId] == 1){
    //             return "ipfs://QmYitJ4U1o7fSnyNCmpEjbJdis96UPQhJicAyfBRUTnqLJ/1.json";
    //         }
    //         else if (ds.idToTier[tokenId] == 2){
    //             return "ipfs://QmNMjkxXjxWPLuN5MWnWDxMnbbBuT6qvL7qvCNTMxZBn4e/1.json";
    //         }
    //         else if (ds.idToTier[tokenId] == 3){
    //             return "ipfs://QmXWVsF2DuVMw6vttmC21fC5BKNMrD54KmmJ6LKx9S88g1/1.json";
    //         }
    //         else if (ds.idToTier[tokenId] == 4){
    //             return "ipfs://QmQ7t9JruwzDmREvURLuKckFuP53BSboNK5LTbR9XLLRP3/1.json";
    //         }
    //         else if (ds.idToTier[tokenId] == 5){
    //             return "ipfs://QmdJekrbyBfsaiVsu5pkyDgL5rCyNwXSLVMU1wtZhEyquX/1.json";
    //         }
    //     }
    // }

    // The following functions are overrides required by Solidity.

    function walletOfNftOwners(address _userAccnt)
        internal
        view
        returns
        (uint256[]memory){ 
            DiamondStorage storage ds = diamondStorage();
            return ds._ownerOfTokenByIndex[_userAccnt];
    }
    

    // TODO bunu cozelim

    // function handleTransferNotContract(
    //     address from, 
    //     address to, 
    //     uint256 tokenId
    // ) internal {
    //     DiamondStorage storage ds = diamondStorage();
    //     uint256 fee = ds.idToFee[tokenId];
    //     fee = 0;
    //     // Remove the tokenId from the sender's ownership list.
    //     uint256[] storage senderTokens = ds._ownerOfTokenByIndex[from];
    //     for (uint256 i = 0; i < senderTokens.length; i++) {
    //         if (senderTokens[i] == tokenId) {
    //             if (i < senderTokens.length - 1) {
    //                 senderTokens[i] = senderTokens[senderTokens.length - 1];
    //             }
    //             senderTokens.pop();
    //             break;
    //         }
    //     }
    //     // Add the tokenId to the recipient's ownership list.
    //     ds._ownerOfTokenByIndex[to].push(tokenId);
    // }
    


    // function getLevel(address _userAccnt) internal view returns(uint256){
    //     if (geHighest(_userAccnt) >= getCount3(_userAccnt)){
    //         return geHighest(_userAccnt); 
    //     }
    //     else{
    //         return getCount3(_userAccnt);
    //     }
    // }

    // function geHighest(address _userAccnt) internal view returns (uint256) {
    //     DiamondStorage storage ds = diamondStorage();
    //     uint256[] memory userTokens = ds._ownerOfTokenByIndex[_userAccnt];
    //     uint256 level = 0;

    //     for (uint256 i = 0; i < userTokens.length; i++) {
    //         uint256 tokenId = userTokens[i];
    //         uint256 tier = ds.idToTier[tokenId];
    //         //level
    //         if (tier > level) {
    //             level = tier;
    //         }
    //     }
    //     return level;
    // }

    

    // function getCount3(address _userAccnt) internal view returns (uint256) {
    //     DiamondStorage storage ds = diamondStorage();
    //     uint256[] memory userTokens = ds._ownerOfTokenByIndex[_userAccnt];
    //     uint256[] memory levelCounts = new uint256[](5); // Initialize an array to count levels 1 to 5

    //     // Count the number of each level NFT
    //     for (uint256 i = 0; i < userTokens.length; i++) {
    //         uint256 tokenId = userTokens[i];
    //         uint256 level =  ds.idToTier[tokenId];

    //         if (level >= 1 && level <= 5) {
    //             levelCounts[level - 1]++;
    //         }
    //     }

    //     // Determine the highest level based on counts
    //     for (uint256 level = 5; level >= 1; level--) {
    //         if (levelCounts[level - 1] >= 3) {
    //             // If the user has three or more NFTs of this level, return the current level
    //             if (level == 5) {
    //                 // If the level is 5, and there are three or more Level 5 NFTs, return Level 5
    //                 return level;
    //             } else {
    //                 // Otherwise, return the next level
    //                 return level + 1;
    //             }
    //         }
    //     }
    //     // If the user doesn't have any NFTs or doesn't meet the threshold, return 0
    //     return 0;
    // }

function calculateTier(
        uint256 _colleteralId,
        uint256 _tokenId
    ) internal {
        //ilgili nft'nin su an ki tier'i nedir ?

        DiamondStorage storage ds = diamondStorage();
        uint256 zz = IPLAD(LibColleteral._getColleteralAddress(_colleteralId)).getFee(_tokenId);
        uint256 tier = IPLAD(LibColleteral._getColleteralAddress(_colleteralId)).getLevel(_tokenId);

        if(tier== 1 && ds.idToFee[_tokenId] >= 1 ether ){
            ds.idToTier[_tokenId]=2;
        }else if(ds.idToTier[_tokenId] == 2 && ds.idToFee[_tokenId] >= 2 ether ){
            ds.idToTier[_tokenId]=3;
        }
        else if(ds.idToTier[_tokenId] == 3 && ds.idToFee[_tokenId] >= 6 ether ){
            ds.idToTier[_tokenId]=4;
        }
        else if(ds.idToTier[_tokenId] == 4 && ds.idToFee[_tokenId] >= 16 ether ){
            ds.idToTier[_tokenId]=5;
        }
    }

// function tokenAmount18(address tokenAddress,uint256 tokenAmount) internal view returns(uint256){
    //     IERC20 token = IERC20(tokenAddress);
    //     uint256 tokenDecimal= token.decimals();
    //     return tokenAmount*(10**(18-tokenDecimal))/uint256(1000);
    // }

    // //transfer 2000000000 to 2000000000000000000
    // function ethPrice18(uint256 price) internal pure returns(uint256){
    //     return price*(10**(18-6))/uint256(1000);
        
    // }


    // function convertUsdtToEthPrice(
    //     address tokenAddress, 
    //     uint256 tokenAmount
    // ) internal view returns (uint256) {
    //     return (tokenAmount18(tokenAddress,tokenAmount)/ethPrice18(LibAdmin._getETHPrice()))*(10**(18));
    // }

    // function convertDaiToEthPrice(
    //     uint256 tokenAmount
    // ) internal view returns (uint256) {
    //     return (tokenAmount/ethPrice18(LibAdmin._getETHPrice()))*(10**(18));
    // }

    function calculateTier(
        uint256 _tokenId
    ) internal {
        //ilgili nft'nin su an ki tier'i nedir ?

        DiamondStorage storage ds = diamondStorage();
        if(ds.idToTier[_tokenId] == 1 && ds.idToFee[_tokenId] >= 1 ether ){
            ds.idToTier[_tokenId]=2;
        }else if(ds.idToTier[_tokenId] == 2 && ds.idToFee[_tokenId] >= 2 ether ){
            ds.idToTier[_tokenId]=3;
        }
        else if(ds.idToTier[_tokenId] == 3 && ds.idToFee[_tokenId] >= 6 ether ){
            ds.idToTier[_tokenId]=4;
        }
        else if(ds.idToTier[_tokenId] == 4 && ds.idToFee[_tokenId] >= 16 ether ){
            ds.idToTier[_tokenId]=5;
        }
    }

    function giveBorrowerFeeToNft(
        uint256 _colleteralId,
        address _sender,
        uint256 _tokenId
    ) internal {
        //sen borrower misin 
        //ne kadar borrower fee'si verdin  
        //bu fee'yi aktardin mi
        //require(LibColleteral._getSeller(_colleteralId) == _sender,"T001");
        require(_getBorrowerFeeClose(_colleteralId)==false,"T002");
        uint256 fee = _getCollateralBorrowerFee(_colleteralId);//ilgili colleteral id'de ki fee atiyorum 0.3 eth
        DiamondStorage storage ds = diamondStorage();
        //fee'yi colleteral'e aktardik
        
        ds.idToFee[_tokenId]=fee;//bu fee'yi bu token'a ver diyoruz

        //deal kapandi
        _setBorrowerFeeClose(_colleteralId);

        calculateTier(_tokenId);

    }
    
    function giveLenderFeeToNft(
        uint256 _colleteralId,
        address _sender,
        uint256 _tokenId
    ) public {
        //require(LibColleteral._getSeller(_colleteralId) == _sender,"T001");
        require(_getLenderFeeClose(_colleteralId)==false,"T002");
        uint256 fee = _getCollateralLenderFee(_colleteralId);
        DiamondStorage storage ds = diamondStorage();

        //fee'yi colleteral'e aktardik
        ds.idToFee[_tokenId]=fee;

        //deal kapandi
        _setBorrowerFeeClose(_colleteralId);

        //tier hesaplamasi varsa guncellesin
        calculateTier(_tokenId);
    }

    function giveLiqudationFeeToNft(
        uint256 _colleteralId,
        address _sender,
        uint256 _tokenId
    ) public {
        //require(LibColleteral._getSeller(_colleteralId) == _sender,"T001");
        require(_getlLiqudatorFeeClose(_colleteralId)==false,"T002");
        uint256 fee = _getCollateralLiqudatorFee(_colleteralId);
        DiamondStorage storage ds = diamondStorage();
        //fee'yi colleteral'e aktardik
        
        ds.idToFee[_tokenId]=fee;

        //deal kapandi
        _setBorrowerFeeClose(_colleteralId);

        //tier hesaplamasi
        calculateTier(_tokenId);
    } 




*/