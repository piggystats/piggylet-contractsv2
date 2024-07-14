// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {LibDiamond} from "../libraries/LibDiamond.sol";

// enum ItemStatus {
//     None, = 0
//     sendedForLoan, = 1
//     sendedForSearchBids,=2
//     sendedVaultDeal,=3
//     sendedForFraction,=4
//     findedLoan,=5
//     liqColleteral,=6
//     transferToLender,=7
//     transferToFragmmentMarket,=8
//     transferToLiqudator=9
//     transferToBorrowerAfterLoan,=10
//     canceledLoan,=11
//     unlistedColleteral,=12
// }

// enum PaymentStatus {
//     None,=0
//     stableCurrency,=1
//     wETHPayment=2
// }
// enum ColleteralType {
//     None,=0
//     ERC721,=1
//     ERC1155,=2
//     ERC20=3
// }
// enum LiqudationType {
//     None, = 0
//     openForLiqudation,=1
//     transfertolender=2
// }


// enum ColleteralStatus{
//     GreenLight, =0
//     SOLID, =1
//     GEM, =2
//     SpecialOne,
//     SpecialTwo,
//     SpecialThree,
//     SpecialFour,
//     SpecialFive
// }


struct Collateral {
    uint256 collateralId;
    uint256 tokenId;
    uint256 paybackDeadline;
    uint256 paybackDay;
    uint256 listDeadline;
    uint256 expectedPrice;
    uint256 apr;
    uint8 status;
    uint8 liquidationType;
    address paymentToken;
    address collateralAddress;
    address seller;
    //new ones
    uint8 collateralType;
    uint256 amount;
}
struct Liquidation {
    uint256 collateralId;
    uint256 liquidationTimestamp;
    uint256 listingPrice;
    uint8 liquidationType;
    address lenderAddress;
}
struct Bid {
    uint256 collateralId;
    uint256 maxPayedAmount;
    uint256 apr;
    uint256 paybackDeadline;
    uint256 bidListDeadline;
    uint8 liquidationType;
    address paymentTokenAddress;
    address lenderAddress;
}

struct Loan {
    uint256 collateralId;
    address lenderAddress;
    uint8 liquidationType;
}

struct FloorPrice{
    address collateralAddress;
    uint256 floorPrice;
}

// struct Pool{
//     uint256 poolId;
//     uint256 baseRate;
//     uint256 slope;
//     uint256 slopeCritical;
//     uint256 criticalRate;//%65 sonrasi critical
//     // uint256 fee;
//     // uint256 ltv;
//     // uint256 liqPenalty;
//     // address collateralAddress;//
//     //uint8 colleteralType;
// }

// struct PoolLoan {
//     uint256 collateralId;
//     uint256 time;
//     uint256 amount;
//     uint256 repayamount;
//     address lenderAddress;
// }

struct AppStorage {
    mapping (uint256 => Collateral)  idToCollateral;
    mapping (uint256 => Loan)  idToLoan;
    mapping (uint256 => mapping(address => Bid)) idToFirstBid;
    mapping (uint256 => mapping(address => Bid)) idToSecondBid;
    mapping (uint256 => Liquidation)  idToLiquidationData;
    mapping (address => FloorPrice) addressTofloorPrice;

    address diamondAddress;
    uint256 ethPrice;

    // mapping (uint256 => Pool)  idToPool;
    // mapping (uint256 => PoolLoan)  idToPoolLoan;
}


library LibAppStorage{
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }
}

