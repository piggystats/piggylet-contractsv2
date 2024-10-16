# ALFA PROD ORTAMI BU OLACAK
<pre>
npx hardhat compile
npx hardhat run scripts/deploy.js --network holesky 
npx hardhat run scripts/updateadmin.js --network holesky 

Compilation finished successfully


Contract owner address: 0x2Ee1CB29722ba8fB8F58F802e63c62c105F0b154
DiamondCutFacet deployed: 0xef98d81D5Cae384C5848BcE92Ef94076Ea2219C2
Diamond deployed: 0x4A9eD026fFCD87c7b0D75B6b71b035dd8dfB6AB4
DiamondInit deployed: 0x33A557efc25Faa801E25A2Dc7b8785DA81D9D804

Deploying facets
DiamondLoupeFacet deployed: 0xbc8b50370594B91E0bb1D544b2696dEAFBEBe9C0
OwnershipFacet deployed: 0x828F6aEDd151882b99cEa041ff5Fc6D0068d7F5b
CollateralFacet deployed: 0xF9872214D5B770e42817Ec203c80525777ee0B8b
PaymentFacet deployed: 0xA5A7222332E8373c8bab8E94AA1D1d9036D1E9D7
AdminFacet deployed: 0xD55C1748161F90af6Bbc00380F8838d93799A0ef
BidFacet deployed: 0xfc436202b8eeC9Eec0D4F11E790772Ad11a9B578
BidUpdateFacet deployed: 0xe02F8984C9302f64c31004C841A9e481Ed0cD25C
LiquidationFacet deployed: 0x24178BB3ce1355aa2379a219a7684BFdAD4F543F
PladFacet deployed: 0xfDb56762a2F5bC712105a10fA8efaadB9ccd7Bab

Diamond Cut: [
  {
    facetAddress: '0xbc8b50370594B91E0bb1D544b2696dEAFBEBe9C0',
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
    facetAddress: '0x828F6aEDd151882b99cEa041ff5Fc6D0068d7F5b',
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
    facetAddress: '0xF9872214D5B770e42817Ec203c80525777ee0B8b',
    action: 0,
    functionSelectors: [
      '0x47eedb1f',
      '0x5a680367',
      '0xb4fad53c',
      '0xb661b50d',
      '0x34f56792',
      '0x1b6487c3',
      '0x58b34a59',
      contract: [Contract],
      remove: [Function: remove],
      get: [Function: get]
    ]
  },
  {
    facetAddress: '0xA5A7222332E8373c8bab8E94AA1D1d9036D1E9D7',
    action: 0,
    functionSelectors: [
      '0x2a731ec1',
      '0x4751de1c',
      '0x7ccc5d35',
      '0xb7f4746e',
      contract: [Contract],
      remove: [Function: remove],
      get: [Function: get]
    ]
  },
  {
    facetAddress: '0xD55C1748161F90af6Bbc00380F8838d93799A0ef',
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
      '0x9ff46728',
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
      '0x0ed02904',
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
    facetAddress: '0xfc436202b8eeC9Eec0D4F11E790772Ad11a9B578',
    action: 0,
    functionSelectors: [
      '0x9e410cce',
      '0xd18fb274',
      '0xe427b2ee',
      contract: [Contract],
      remove: [Function: remove],
      get: [Function: get]
    ]
  },
  {
    facetAddress: '0xe02F8984C9302f64c31004C841A9e481Ed0cD25C',
    action: 0,
    functionSelectors: [
      '0x4b393605',
      '0x37c75f1b',
      contract: [Contract],
      remove: [Function: remove],
      get: [Function: get]
    ]
  },
  {
    facetAddress: '0x24178BB3ce1355aa2379a219a7684BFdAD4F543F',
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
    facetAddress: '0xfDb56762a2F5bC712105a10fA8efaadB9ccd7Bab',
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
Diamond cut tx:  0x349234bd133d81753053105136a62f6daae50ce0a2620f61dac1373b9aa0c1f6
Completed diamond cut

</pre>