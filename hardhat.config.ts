import {HardhatUserConfig, task} from 'hardhat/config';
import * as config from './config';
import '@nomiclabs/hardhat-waffle';
import '@nomiclabs/hardhat-etherscan';
import 'hardhat-abi-exporter';
import 'hardhat-contract-sizer';
import '@typechain/hardhat';
import 'solidity-coverage';
import 'hardhat-gas-reporter';
import '@matterlabs/hardhat-zksync-deploy';
import '@matterlabs/hardhat-zksync-solc';


module.exports = {
    zksolc: {
      version: "0.1.0",
      compilerSource: "docker",
      settings: {
        optimizer: {
          enabled: true,
        },
        experimental: {
          dockerImage: "matterlabs/zksolc",
        },
      },
    },
    zkSyncDeploy: {
      zkSyncNetwork: "https://zksync2-testnet.zksync.dev",
      ethNetwork: "goerli",
    },
    solidity: {
      version: "0.8.11",
    },
  };