/* global ethers */
/* eslint prefer-const: "off" */

const { FacetCutAction, getSelectors } = require('./libraries/diamond.js')


//mevcut lib payment'a dokunmadan yeni bi fonksyonda liq treshold'u set etip kontrol edicem
//payment facette degisiklik yapmadan sadece libi degislik yapip denicem
//bi de yeni event ekledim
//yapti
//event calisti 
//simdi sadece eventin icindeki matematigi degistirdim facete hic dokunmadim sadece libte degisiklik yapti
//yapti ama calismadi neden bilmiyorum sonra yeni deger ekledim calisti
//simdi yenileri ucurup sadece give loan birakicam ve o sekilde denicem
//hem libten hem facetten

async function upgrade() {
  const diamondAddress = '0x1dCE33Ba8a5188234ef6f797Fc8FF118B62DFD16';
  const oldPaymentFacet = '0x97Ae64F5678D71EA29cbaf37587fb4919A20C92a';

  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];
  console.log('Contract owner address:', contractOwner.address);

  // Deploy SimpleStorage
  const PaymentFacet = await ethers.getContractFactory('PaymentFacet')
  //console.log('LiqudationFacet :', LiqudationFacet)

  const paymentFacet = await PaymentFacet.deploy()
  //console.log('await LiqudationFacet.deploy() :', simpleStorageFacet)

  await paymentFacet.deployed()
  console.log('new paymen Facet    deployed:', paymentFacet.address)

  // Add the new function selector (retrieveNumberNew and showSenderAddress)
  

  const FacetCutAction = { Add: 0, Replace: 1, Remove: 2 }
  const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)
  const oldSelectors = await diamondLoupeFacet.facetFunctionSelectors(oldPaymentFacet)

  //console.log("oldSelectors",oldSelectors);

  console.log('xx')


  const cut = [
    {
      facetAddress: ethers.constants.AddressZero,
      action: FacetCutAction.Remove,
      functionSelectors: oldSelectors
    },
    {
      facetAddress: paymentFacet.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(paymentFacet)
    }
  ]

  const diamondCut = await ethers.getContractAt('IDiamondCut', diamondAddress)
  let tx = await diamondCut.diamondCut(cut, ethers.constants.AddressZero, '0x', { 
    gasLimit: 8000000,
    gasPrice: ethers.utils.parseUnits('70', 'gwei') 
  })
  console.log('Diamond cut tx:', tx.hash)
  let receipt = await tx.wait()
  if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
  }
  console.log('Completed diamond cut: ', tx.hash)


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  upgrade()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}

exports.upgrade = upgrade;

