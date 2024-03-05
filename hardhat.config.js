
/* global ethers task */
require('@nomiclabs/hardhat-waffle')
require("dotenv").config();
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
   networks :{
    hardhat: {
      forking: {
        url: process.env.ALCHEMY_URL,
        accounts: [
          `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`,
        ],
        timeout: 100000
      }
    },
    ganache: {
      url: "http://127.0.0.1:9545",
      accounts: [process.env.GANACHE_PRIVATE_KEY],
      allowUnlimitedContractSize: true,
      timeout: 100000
    },
    sepolia: {
      allowUnlimitedContractSize: true,
      url: `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [process.env.GOERLI_PRIVATE_KEY]
   }

    
   },
   etherscan :{
     apiKey: process.env.ETHERSCAN_API_KEY
   },
   settings: {
     optimizer: {
       enabled: true,
       runs: 200
     }
     ,
     evmVersion: "london"
   }
 }
 