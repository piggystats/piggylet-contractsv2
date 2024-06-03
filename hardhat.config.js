
/* global ethers task */
require('@nomiclabs/hardhat-waffle')
require("dotenv").config();
require('@matterlabs/hardhat-zksync-deploy')
require('@matterlabs/hardhat-zksync-solc')
require('@matterlabs/hardhat-zksync-ethers')
//require("@nomicfoundation/hardhat-ethers");
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async () => {
  const accounts = await ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
 const MAINNET_API_KEY = process.env.INFURA_MAINNET_KEY;
 // Replace this private key with your Goerli account private key
 // To export your private key from Metamask, open Metamask and
 // go to Account Details > Export Private Key
 // Beware: NEVER put real Ether into testing accounts
 // You need to export an object to set up your config
 // Go to https://hardhat.org/config/ to learn more
 
 /**
  * @type import('hardhat/config').HardhatUserConfig
  */
 module.exports = {
   solidity: '0.8.15',
   zksolc: {
    version: "latest",
    settings: {},
  },  
   networks :{
    hardhat: {
      zksync: true,
      forking: {
        url: process.env.ALCHEMY_URL,
        accounts: [
          `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`,
        ],
        timeout: 100000
      }
    },
    sepolia: {
      zksync: false,
      allowUnlimitedContractSize: true,
      url: `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`,]
   },
   zkSyncTestnet: {
    url: "https://sepolia.era.zksync.dev",
    ethNetwork: "sepolia", // or a Sepolia RPC endpoint from Infura/Alchemy/Chainstack etc.
    accounts: [`0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`,],
    zksync: true,
  },
   

   },
   etherscan :{
     apiKey: process.env.ETHERSCAN_API_KEY
   },
   settings: {
     optimizer: {
       enabled: true,
       runs: 200
     },
     evmVersion: "london"
   }
 }
 