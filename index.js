const defiBlocks = require('./defi_blocks');
const xml = defiBlocks.xml();
const fs = require('fs');

let template = fs.readFileSync('templates/yearn_dai.sol', 'utf-8');

try {
  let values = xml.getElementsByTagName("value");
  for (let elem of values) {
    let k = elem.getAttribute("name");
    let v = elem.getElementsByTagName("field")[0].innerHTML;

    switch(k) {
      case "NAME":
        renderName(v);
        break;
      case "PERFORMANCE_FEE":
        renderPerformanceFee(v);
        break;
      case "PERFORMANCE_MAX":
        renderPerformanceMax(v);
        break;
      case "WITHDRAWAL_FEE":
        renderWithdrawalFee(v);
        break;
      case "WITHDRAWAL_MAX":
        renderWithdrawalMax(v);
        break;
      case "DEPOSITOR":
        renderDepositor(v);
        break;
      case "REWARDOR":
        renderRewardor(v);
        break;
      case "EXCHANGE":
        renderExchange(v);
        break;
      case "TOKENSET":
        let elems = elem.getElementsByTagName("field");
        let values = {};
        for (let e of elems) {
          let tsKey = e.getAttribute("name");
          let tsVal = e.innerHTML;

          values[tsKey] = tsVal;
        }
        renderTokenSet(values);
      default:
        break;
      }
    }
}
catch (e) {
  console.log(e);
}

const outputFile = 'generated/defi_blocks.sol';
fs.writeFileSync(outputFile, template, 'utf-8');
console.log(`Smart contract has been generated to ${outputFile}`);


/**
 * render functions
 */
function renderName(name) {
  replaceAll("CONTRACT_NAME", name);
}

function renderPerformanceFee(value) {
  replaceAll("PERFORMANCE_FEE", value);
}

function renderPerformanceMax(value) {
  replaceAll("PERFORMANCE_MAX", value);
}

function renderWithdrawalFee(value) {
  replaceAll("WITHDRAWAL_FEE", value);
}

function renderWithdrawalMax(value) {
  replaceAll("WITHDRAWAL_MAX", value);
}

function renderDepositor(depositor) {
  switch(depositor) {
    case "DEPOSITOR_CONTRACT_COMPOUND":
      renderCompoundDepositor();
      break;

      /** TODO: add more here */

    default:
      break;
  }
}

function renderRewardor(rewardor) {
  switch(rewardor) {
    case "REWARDOR_CONTRACT_COMPOUND":
      renderCompoundRewardor();
      break;

      /** TODO: add more here */

    default:
      break;
  }
}

function renderCompoundDepositor() {
  replaceAll("IMPORT_DEPOSITOR", "../../interfaces/compound/cToken.sol");
  replaceAll("DEPOSITOR_TOKEN_ADDRESS", "0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643");
  replaceAll("DEPOSITOR_CONTRACT", "cToken");
  replaceAll("DEPOSITOR_METHOD_MINT", "mint");
  replaceAll("DEPOSITOR_METHOD_WITHDRAW", "redeem");
  replaceAll("DEPOSITOR_METHOD_EXCHANGE_RATE", "exchangeRateStored");
  replaceAll("DEPOSITOR_METHOD_EXCHANGE_RATE_CONVERSION", "div(1e18)");
}

function renderCompoundRewardor() {
  replaceAll("IMPORT_REWARDOR", "../../interfaces/compound/Comptroller.sol");
  replaceAll("REWARDOR_TOKEN_ADDRESS", "0xc00e94Cb662C3520282E6f5717214004A7f26888");
  replaceAll("REWARDOR_FIELD_TYPE", "Comptroller");
  replaceAll("REWARDOR_FIELD_ADDRESS", "0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B");
  replaceAll("REWARDOR_METHOD_CLAIM", "claimComp");
}

function renderExchange(name) {
  // for now it's only uniswap
  replaceAll("IMPORT_EXCHANGE", "../../interfaces/uniswap/Uni.sol");
  replaceAll("EXCHANGE_ADDRESS", "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D");
  replaceAll("EXCHANGE_FIELD_TYPE", "Uni");
  replaceAll("EXCHANGE_METHOD", "swapExactTokensForTokens")
}

function renderTokenSet(tokenSet) {
  let wantToken = tokenSet['WANT_TOKEN'];
  switch (wantToken) {
    // TODO DAI is the only case right now
    case "TOKEN_DAI":
    default:
    replaceAll("WANT_TOKEN_ADDRESS", "0x6B175474E89094C44Da98b954EedeAC495271d0F")
    break;
  }

  let intermediaryToken = tokenSet['INTERMEDIARY_TOKEN'];
  switch (intermediaryToken) {
    // TODO wETH is the only case right now
    case "TOKEN_WETH":
    default:
    replaceAll("INTERMEDIARY_TOKEN_ADDRESS", "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2");
    break;
  }
}

function replaceAll(key, replacement) {
  const re = new RegExp(getSymbol(key), 'g');
  template = template.replace(re, replacement);
}

function getSymbol(key) {
  return `!!${key}!!`;
}
