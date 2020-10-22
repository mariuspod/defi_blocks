# defi_blocks

## Description
This is a very basic PoC for a graphical no-code builder that generates solidity smart contract code from a given blockly block.

![alt text][block]

[block]: https://github.com/mariuspod/defi_blocks/raw/main/images/yearn_blockly.png "Yearn DAI Strategy blockly block"

Currently it's re-implementing the [DAICompoundBasic strategy from yearn](https://github.com/iearn-finance/yearn-starter-pack/blob/master/contracts/strategies/StrategyDAICompoundBasic.sol). It comes with a custom [blockly](https://developers.google.com/blockly) block that can be used to parametrize the strategy and switch between a depositor, a rewardor, the exchange and the token that is wanted and optimized by the strategy without writing any single line of solidity code.

The tool generates the smart contract code by applying the configured block to a given template file which is provided.
The logic is currently very limited, the idea was just if it's doable and how no-code programming of smart contracts could be used.

I have created this as a fun project for the [ETHonline 2020 hackathon](https://ethglobal.online/#hackathon).

**Note:** Most of the code is currently hard-wired so basically it always ouputs the DAICompoundBasic yearn strategy atm :joy:


## Usage
As this is a very quick & dirty implementation the only thing you can do right now is to generate the solidity code from a preconfigured block for the DAICompoundBasic strategy from yearn:

`npm install && node index.js`

The generated smart contract code can then be found in `generated/defi_blocks.sol`

## Future
As an example, this PoC generates solidity code based on a template version of a smart contract from yearn. However, it's not tied to yearn at all. You could generate any smart contract that respects a certain design pattern and can logically be mapped to blockly. Creating a blockly parser or language generator for solidity or maybe even vyper could be the next thing to implement.

It might also be integrated into a web app where users could just click together some new strategies and generate the solidity code on the fly. Maybe this could be even compiled and run against remix or similar tools, there are many options.

It's time to buidl! :rocket:


