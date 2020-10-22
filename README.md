# defi_blocks

This is a very basic PoC for a graphical no-code builder that generates solidity smart contract code from a given blockly block.

![alt text][block]

[block]: https://github.com/mariuspod/defi_blocks/raw/main/images/yearn_blockly.png "Yearn DAI Strategy blockly block"

Currently it's re-implementing the [DAICompoundBasic strategy from yearn](https://github.com/iearn-finance/yearn-starter-pack/blob/master/contracts/strategies/StrategyDAICompoundBasic.sol). It comes with a custom [blockly](https://developers.google.com/blockly) block that can be used to parametrize the strategy and switch between a depositor, a rewardor, the exchange and the token that is wanted and optimized by the strategy without writing any single line of solidity code.

**Note:** Most of the code is currently hard-wired so basically it always ouputs the DAICompoundBasic yearn strategy atm :joy:

The tool generates the smart contract code by applying the configured block to a given template file which can be defined.
The logic is currently very limited, the idea was just if it's doable and how no-code programming of smart contracts could be used to eliminate boilerplate code by taking the term 'money legos' literarily.

I have created this as a fun project for the [ETHonline 2020 hackathon](https://ethglobal.online/#hackathon).
