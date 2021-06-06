const { expect } = require("chai");
const { BigNumber, Wallet } = require("ethers");
const { formatEther, parseEther } =require('@ethersproject/units')
const BBadgerAbi = require('../abi/BBadgerAbi.json');
const crBBadgerAbi = require('../abi/crBBadgerAbi.json');
const { ethers } = require("hardhat");

// Mainnet Fork and test case for mainnet with hardhat network by impersonate account from mainnet
describe("deployed Contract on Mainnet fork", function() {
  it("hardhat_impersonateAccount and transfer balance to our account", async function() {
    const accounts = await ethers.getSigners();
    
    // Mainnet addresses
    const accountToImpersonate = '0x1759f4f92af1100105e405fca66abba49d5f924e'
    const BBadgerAddress = '0x19D97D8fA813EE2f51aD4B4e04EA08bAf4DFfC28'
    const creamBBadgerContractAddress = '0x8B950f43fCAc4931D408F1fcdA55C6CB6cbF3096'
    await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [accountToImpersonate]}
    )
    let signer = await ethers.provider.getSigner(accountToImpersonate)
    let BBadgerContract = new ethers.Contract(BBadgerAddress , BBadgerAbi, signer)
    await BBadgerContract.transfer(accounts[0].address, BBadgerContract.balanceOf(accountToImpersonate))
    signer = await ethers.provider.getSigner(accounts[0].address)
    BBadgerContract = new ethers.Contract(BBadgerAddress, BBadgerAbi, signer)
  });

  it("Initialize CreamBBadge startergy", async function() {
    const accounts = await ethers.getSigners();
    const accountToImpersonate = '0x1759f4f92af1100105e405fca66abba49d5f924e'
    const BBadgerAddress = '0x19D97D8fA813EE2f51aD4B4e04EA08bAf4DFfC28'
    const creamBBadgerContractAddress = '0x8B950f43fCAc4931D408F1fcdA55C6CB6cbF3096'
    await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [accountToImpersonate]}
    )
    let signer = await ethers.provider.getSigner(accountToImpersonate)
    let BBadgerContract = new ethers.Contract(BBadgerAddress , BBadgerAbi, signer)
    await BBadgerContract.transfer(accounts[0].address, BBadgerContract.balanceOf(accountToImpersonate))
    signer = await ethers.provider.getSigner(accounts[0].address)
    BBadgerContract = new ethers.Contract(BBadgerAddress , BBadgerAbi, signer)
    const BBadgerYield = await ethers.getContractFactory('BBadgerYield', signer);
    const BBadgerYield_Instance = await BBadgerYield.deploy();
    let creamBBadgerContract = new ethers.Contract(creamBBadgerContractAddress, crBBadgerAbi, signer)
    await BBadgerYield_Instance.initialize(
        creamBBadgerContract.address, 
        accounts[0].address
    )
  });

  it("Mint cryUSD and crBBadger from BBadgerYield strategy", async function() {
    const accounts = await ethers.getSigners();
    const accountToImpersonate = '0x1759f4f92af1100105e405fca66abba49d5f924e'
    const BBadgerAddress = '0x19D97D8fA813EE2f51aD4B4e04EA08bAf4DFfC28'
    const creamBBadgerContractAddress = '0x8B950f43fCAc4931D408F1fcdA55C6CB6cbF3096'

    await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [accountToImpersonate]}
    )

    let signer = await ethers.provider.getSigner(accountToImpersonate)
    let BBadgerContract = new ethers.Contract(BBadgerAddress , BBadgerAbi, signer)
    await BBadgerContract.transfer(accounts[0].address, BBadgerContract.balanceOf(accountToImpersonate))
    signer = await ethers.provider.getSigner(accounts[0].address)
    BBadgerContract = new ethers.Contract(BBadgerAddress , BBadgerAbi, signer)
    const BBadgerYield = await ethers.getContractFactory('BBadgerYield', signer);
    const BBadgerYield_Instance = await BBadgerYield.deploy();
    let creamBBadgerContract = new ethers.Contract(creamBBadgerContractAddress, crBBadgerAbi, signer)
    await BBadgerYield_Instance.initialize(
        creamBBadgerContract.address, 
        accounts[0].address
    )
    await BBadgerContract .approve(creamBBadgerContract.address, '1000000000000000000000000000000000')
    await BBadgerContract .transfer(BBadgerYield_Instance.address, '1000000000000000000')

    const bal0 = await creamBBadgerContract.balanceOf(accounts[0].address);
    console.log('balanceOf0 crBBadger before mint: ', bal0.toString());
    await BBadgerYield_Instance.mint() //// Mint Tokens or BuyTokens
    const bal1 = await creamBBadgerContract.balanceOf(accounts[0].address);
    console.log('balanceOf1 cryUSD and crBBadger  after mint: ', bal1.toString());
  });

  it("Mint and Redeem CreamBBadger and cryBBadger through BBadgerYield", async function() {
    const accounts = await ethers.getSigners();
    const accountToImpersonate = '0x1759f4f92af1100105e405fca66abba49d5f924e'
    const BBadgerAddress = '0x19D97D8fA813EE2f51aD4B4e04EA08bAf4DFfC28'
    const creamBBadgerContractAddress = '0x8B950f43fCAc4931D408F1fcdA55C6CB6cbF3096'

    await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [accountToImpersonate]}
    )
    let signer = await ethers.provider.getSigner(accountToImpersonate)
    let BBadgerContract = new ethers.Contract(BBadgerAddress , BBadgerAbi, signer)
    await BBadgerContract.transfer(accounts[0].address, BBadgerContract.balanceOf(accountToImpersonate))
    signer = await ethers.provider.getSigner(accounts[0].address)
    BBadgerContract = new ethers.Contract(BBadgerAddress , BBadgerAbi, signer)
    const BBadgerYield = await ethers.getContractFactory('BBadgerYield', signer);
    const BBadgerYield_Instance = await BBadgerYield.deploy();
    let creamBBadgerContract = new ethers.Contract(creamBBadgerContractAddress, crBBadgerAbi, signer)
    await BBadgerYield_Instance.initialize(
        creamBBadgerContract.address, 
        accounts[0].address
    )
    await BBadgerContract .approve(creamBBadgerContract.address, '1000000000000000000000000000000000')
    await BBadgerContract .transfer(BBadgerYield_Instance.address, '1000000000000000000')
    await BBadgerYield_Instance.mint() //// Mint Tokens or BuyTokens
    const balance = await creamBBadgerContract.balanceOf(accounts[0].address)
    await creamBBadgerContract.transfer(BBadgerYield_Instance.address, balance)
    await BBadgerYield_Instance.redeem(BBadgerYield_Instance.address) //// Idle Redeem or SellTokens from BarnBeidge 
  });

  
  it("Get NextSupplyRate", async function() {
   const accounts = await ethers.getSigners();
    const accountToImpersonate = '0x1759f4f92af1100105e405fca66abba49d5f924e'
    const BBadgerAddress = '0x19D97D8fA813EE2f51aD4B4e04EA08bAf4DFfC28'
    const creamBBadgerContractAddress = '0x8B950f43fCAc4931D408F1fcdA55C6CB6cbF3096'

    await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [accountToImpersonate]}
    )
    let signer = await ethers.provider.getSigner(accountToImpersonate)
    let BBadgerContract = new ethers.Contract(BBadgerAddress , BBadgerAbi, signer)
    await BBadgerContract.transfer(accounts[0].address, BBadgerContract.balanceOf(accountToImpersonate))
    signer = await ethers.provider.getSigner(accounts[0].address)
    BBadgerContract = new ethers.Contract(BBadgerAddress , BBadgerAbi, signer)
    const BBadgerYield = await ethers.getContractFactory('BBadgerYield', signer);
    const BBadgerYield_Instance = await BBadgerYield.deploy();
    let creamBBadgerContract = new ethers.Contract(creamBBadgerContractAddress, crBBadgerAbi, signer)
    await BBadgerYield_Instance.initialize(
        creamBBadgerContract.address, 
        accounts[0].address
    )

    const rate = await BBadgerYield_Instance.nextSupplyRate('0')  
    console.log('rate: ', rate.toString());
  });
})
