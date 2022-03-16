
import {makeTreeFromTraits, makeTreeFromNames} from "../scripts/helpers/merkletree";
const wizardTraits = require("../data/traits.json");

import { utils, Wallet } from "zksync-web3";
import * as ethers from "ethers";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import { HardhatRuntimeEnvironment } from "hardhat/types";


export default async function (hre: HardhatRuntimeEnvironment) {
    
    console.log(" --- SETTING UP L2 ACCOUNT ---")

    // Initialize the wallet.
    const wallet = new Wallet(process.env.PRIVATE_KEY);

    // Create deployer object and load the artifact of the contract we want to deploy.
    const deployer = new Deployer(hre, wallet);

   
    const grimoireArtifact = await deployer.loadArtifact("Grimoire");

    let l2Balance = ((await deployer.zkWallet.getBalance()).toString() );
    let l2Address= ((await deployer.zkWallet.getAddress()).toString() );
    console.log("L2 Balance:", l2Balance)
    console.log("L2 Address:", l2Address)

    // if no funds on L2 fund it from L1
    if (l2Balance == "0"){
    
        console.log("Funding L2 Wallet")
    
        // Deposit some funds to L2 in order to be able to perform L2 transactions.
        const depositAmount = ethers.utils.parseEther("0.1");
        console.log("L1 Balance:", (await deployer.zkWallet.getBalanceL1()).toString())
        console.log("Address", (await deployer.zkWallet.getAddress()).toString())
        
        const depositHandle = await deployer.zkWallet.deposit({
            to: deployer.zkWallet.address,
            token: utils.ETH_ADDRESS,
            amount: depositAmount,
        });
        
        // Wait until the deposit is processed on zkSync
        await depositHandle.wait();

        console.log("Deposit Successful")
    }

    // comment out steps to skip
    
    console.log(`\n --- DEPLOY THE LOST GRIMOIRE ---`);

    let traitsTree = await makeTreeFromTraits(wizardTraits.traits);
    let traitsTreeRoot = traitsTree.getHexRoot();
    console.log(`Merkle Tree for Traits generated with root: ${traitsTreeRoot}`);


    let namesTree = await makeTreeFromNames(wizardTraits.names);
    let namesTreeRoot = namesTree.getHexRoot();
    console.log(`Merkle Tree for Names generated with root: ${namesTreeRoot}`);

    console.log("deploying")
    // code stalls here
    const grimoire = await deployer.deploy(grimoireArtifact, [traitsTreeRoot, namesTreeRoot]) //as Grimoire;
    console.log(`Grimoire deployed to: ${grimoire.address.toLowerCase()}`);
    
    console.log(`Grimoire deployed to: ${grimoire.address.toLowerCase()}`);
    


}
