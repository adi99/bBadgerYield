# Yield Generator for BBadger

Badger is a decentralized autonomous organization (DAO) with a single purpose: build the products and infrastructure necessary to accelerate Bitcoin as collateral across other blockchains.

C.R.E.A.M. Finance is a decentralized lending protocol for individuals and protocols to access financial services. The protocol is permissionless, transparent, and non-custodial. C.R.E.A.M. offers a wide range of tokens on our money markets, including: stablecoins (USDT, USDC, BUSD); interest-bearing stablecoins (yCRV, yyCRV); defi tokens (YFI, SUSHI, CREAM, CREAM); LP-tokens (USDC-ETH SLP, WBTC-ETH SLP); and other cryptocurrencies (ETH, LINK). 

## Concept

This yield generator uses 3 different Protocol((Cream.Finance,Yearn and Curve.fi) to gain highest yield. Badger is first deposited into the https://badger.finance/ and bBadger is received. This Strategy uses 
following steps to generate yield:-

1- bBadger is deposited into C.R.E.A.M. Finance and DAI is borrowed from same Protocol. The total DAI borrowed is 50% of deposited bBadger (in USD).

APY = lending (1.55) + borrowing DAI (8.71/2) => 1.55-4.355 => -2.805%

2- The borrowed DAI is deposited into first into Curve.fi to convert it into yCRV(yDAI+yUSDC+yUSDT+yTUSD) and then it is deposited into yearn to get yyCRV(yyDAI+yUSDC+yUSDT+yTUSD).

APY = 5.26 + 0.85(CRV)=> 6.11/2 => 3.055%

3- yyCRV is deposited into C.R.E.A.M. Finance again because it has the higest lending APY.

APY = 88.12/2 => 44.06%

Total APY = -2.805 + 3.055 + 44.06 = 44.31%

bBadger APY => 4.45

Overall APY on Badger = 44.31 + 4.45 = 48.76%



## Setup

To install dependencies,run  
`yarn`

You will needs to enviroment variables to run the tests.
Create a `.env` file in the root directory of your project.

```
ETHERSCAN_API_KEY=
ALCHEMY_API_KEY=
```

You will get the first one from [Etherscan](https://etherscan.io/).
You will get the second one from [Alchemy](https://dashboard.alchemyapi.io/).

## Compile

To compile, run  
`yarn hardhat compile`

## Test

`yarn test`

