# ALFA PROD ORTAMI BU OLACAK
npx hardhat compile
npx hardhat run scripts/deploy.js --network sepolia 
npx hardhat run scripts/updateadmin.js --network sepolia 

Compilation finished successfully


DiamondCutFacet deployed: 0xcCC0a53B8625D45D9720C2F158cB2492A52572B3
Diamond deployed: 0x1dCE33Ba8a5188234ef6f797Fc8FF118B62DFD16
DiamondInit deployed: 0x5Bf8EBEED15AD440076aed575B9Dd04eaf34c4Cf

Deploying facets
DiamondLoupeFacet deployed: 0x6e50e9923a2c1ACCCA2124C9C68c5B669F62E6CB
OwnershipFacet deployed: 0xd3eF233498bF9e6752a2cBc9654371FD43927B2a
CollateralFacet deployed: 0x9A12abf9ac5683aC0992a5b76E6D0aa7A782637E
PaymentFacet deployed: 0x4eDEd7f2867C11979F57c544EC292d0B230FBc6e
AdminFacet deployed: 0x9726417b77878825239709950247aD35f821e7e9
BidFacet deployed: 0x269c042bFEa685Bac5591F056E48AC7Bff088F1A
BidUpdateFacet deployed: 0xD3478906d787271D2B99F2c237B39a713d628212
FloorPriceFacet deployed: 0x36caA9b3B5e9c60F65be8068547b27ED8FF40600
LiquidationFacet deployed: 0x436E94CE5beb9F64390F45FAF7da82793De6190f
PladFacet deployed: 0x1bb9a4f40687F690583a7F1A9F999Ba2D48f6f99

Diamond Cut: [
  {
    facetAddress: '0x6e50e9923a2c1ACCCA2124C9C68c5B669F62E6CB',
    action: 0,
    functionSelectors: [
      '0xcdffacc6',
      '0x52ef6b2c',
      '0xadfca15e',
      '0x7a0ed627',
      '0x01ffc9a7',
      contract: [Contract],
      remove: [Function: remove],
      get: [Function: get]
    ]
  },
  {
    facetAddress: '0xd3eF233498bF9e6752a2cBc9654371FD43927B2a',
    action: 0,
    functionSelectors: [
      '0x8da5cb5b',
      '0xf2fde38b',
      contract: [Contract],
      remove: [Function: remove],
      get: [Function: get]
    ]
  },
  {
    facetAddress: '0x9A12abf9ac5683aC0992a5b76E6D0aa7A782637E',
    action: 0,
    functionSelectors: [
      '0xf5b66044',
      '0x5a680367',
      '0x00fef8c4',
      '0x6bde62a5',
      '0x9cc7406a',
      contract: [Contract],
      remove: [Function: remove],
      get: [Function: get]
    ]
  },
  {
    facetAddress: '0x4eDEd7f2867C11979F57c544EC292d0B230FBc6e',
    action: 0,
    functionSelectors: [
      '0x2a731ec1',
      '0x4751de1c',
      '0x7ccc5d35',
      '0x2b079b2e',
      '0xb7f4746e',
      contract: [Contract],
      remove: [Function: remove],
      get: [Function: get]
    ]
  },
  {
    facetAddress: '0x9726417b77878825239709950247aD35f821e7e9',
    action: 0,
    functionSelectors: [
      '0x574be132',
      '0xe6fdd856',
      '0x9aae597c',
      '0x2a62a490',
      '0xa8dd9b22',
      '0x6013c44c',
      '0x9bddd05f',
      '0x9fcb322c',
      '0xc3e214fc',
      '0xb4d7a3f5',
      '0x04bc8d47',
      '0x5e4ea00f',
      '0x504006ca',
      '0x6a9bc430',
      '0x5de8043a',
      '0x038558ca',
      '0x5e28fb64',
      '0x26ab16a5',
      '0x751a7bfe',
      '0xc8b2bdea',
      '0xac086e37',
      '0xfeabb887',
      '0x2d1a4850',
      '0x9beb487d',
      '0x26eb8b06',
      '0x4cccc5bf',
      '0x9147cc55',
      '0x27ab25ce',
      '0x451a07f8',
      '0x0d2bad5e',
      '0x990d070a',
      '0xcbf9c05c',
      '0xf17637c5',
      '0x7c374f99',
      '0xe49a12dc',
      '0x0087b346',
      contract: [Contract],
      remove: [Function: remove],
      get: [Function: get]
    ]
  },
  {
    facetAddress: '0x269c042bFEa685Bac5591F056E48AC7Bff088F1A',
    action: 0,
    functionSelectors: [
      '0x79ef44a1',
      '0x7fc626e2',
      '0xd18fb274',
      '0xe427b2ee',
      contract: [Contract],
      remove: [Function: remove],
      get: [Function: get]
    ]
  },
  {
    facetAddress: '0xD3478906d787271D2B99F2c237B39a713d628212',
    action: 0,
    functionSelectors: [
      '0xacbf99a2',
      '0xe72b9088',
      '0xd23db0fb',
      '0x270715fc',
      contract: [Contract],
      remove: [Function: remove],
      get: [Function: get]
    ]
  },
  {
    facetAddress: '0x36caA9b3B5e9c60F65be8068547b27ED8FF40600',
    action: 0,
    functionSelectors: [
      '0x78aa1dba',
      '0xae255af1',
      contract: [Contract],
      remove: [Function: remove],
      get: [Function: get]
    ]
  },
  {
    facetAddress: '0x436E94CE5beb9F64390F45FAF7da82793De6190f',
    action: 0,
    functionSelectors: [
      '0x7e1a0a74',
      '0x34c9d1ec',
      '0xad53bba7',
      contract: [Contract],
      remove: [Function: remove],
      get: [Function: get]
    ]
  },
  {
    facetAddress: '0x1bb9a4f40687F690583a7F1A9F999Ba2D48f6f99',
    action: 0,
    functionSelectors: [
      '0x61f4dd40',
      '0x32a2c5d0',
      '0xa5985e8c',
      '0xc16586d8',
      '0xd8c9df4a',
      '0xf0eef99b',
      '0x477bddaa',
      '0x4702e918',
      '0x97b9fca9',
      '0x95676a9d',
      contract: [Contract],
      remove: [Function: remove],
      get: [Function: get]
    ]
  }
]
Diamond cut tx:  0x1f31aef362b8b203399416092bed66e1fa0556171342cc4b1e1b04591f75ba0d
Completed diamond cut
