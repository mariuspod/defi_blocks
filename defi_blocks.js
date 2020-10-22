var Blockly = require('blockly');

Blockly.defineBlocksWithJsonArray([{
  "type": "object",
  "message0": "{ %1 %2 }",
  "args0": [
    {
      "type": "input_dummy"
    },
    {
      "type": "input_statement",
      "name": "MEMBERS"
    }
  ],
  "output": null,
  "colour": 130,
},
{
  "type": "member",
  "message0": "%1 %2 %3",
  "args0": [
    {
      "type": "field_input",
      "name": "MEMBER_NAME",
      "text": ""
    },
    {
      "type": "field_label",
      "name": "COLON",
      "text": ":"
    },
    {
      "type": "input_value",
      "name": "MEMBER_VALUE"
    }
  ],
  "previousStatement": null,
  "nextStatement": null,
  "colour": 230,
},
{
  "type": "strategy",
  "message0": "Strategy name %1 Tokens %2 Performance fee %3 Performance max %4 Withdrawal fee %5 Withdrawal max %6 Depositor %7 Rewardor %8 Exchange %9",
  "args0": [
    {
      "type": "input_value",
      "name": "NAME",
      "check": "String"
    },
    {
      "type": "input_value",
      "name": "TOKENSET",
      "check": "tokenset"
    },
    {
      "type": "input_value",
      "name": "PERFORMANCE_FEE",
      "check": "Number"
    },
    {
      "type": "input_value",
      "name": "PERFORMANCE_MAX",
      "check": "Number"
    },
    {
      "type": "input_value",
      "name": "WITHDRAWAL_FEE",
      "check": "Number"
    },
    {
      "type": "input_value",
      "name": "WITHDRAWAL_MAX",
      "check": "Number"
    },
    {
      "type": "input_value",
      "name": "DEPOSITOR",
      "check": "depositor"
    },
    {
      "type": "input_value",
      "name": "REWARDOR",
      "check": "rewardor"
    },
    {
      "type": "input_value",
      "name": "EXCHANGE",
      "check": "exchange"
    }
  ],
  "output": null,
  "colour": 255,
  "tooltip": "Strategy",
  "helpUrl": ""
},
{
  "type": "depositor",
  "message0": "Depositor contract %1",
  "args0": [
    {
      "type": "field_dropdown",
      "name": "CONTRACT",
      "options": [
        [
          "compound",
          "DEPOSITOR_CONTRACT_COMPOUND"
        ],
        [
          "aave",
          "DEPOSITOR_CONTRACT_AAVE"
        ]
      ]
    }
  ],
  "output": "depositor",
  "colour": 165,
  "tooltip": "",
  "helpUrl": ""
},
{
  "type": "rewardor",
  "message0": "Rewardor contract %1",
  "args0": [
    {
      "type": "field_dropdown",
      "name": "CONTRACT",
      "options": [
        [
          "compound",
          "REWARDOR_CONTRACT_COMPOUND"
        ],
        [
          "aave",
          "REWARDOR_CONTRACT_AAVE"
        ]
      ]
    }
  ],
  "output": "rewardor",
  "colour": 270,
  "tooltip": "",
  "helpUrl": ""
},
{
  "type": "exchange",
  "message0": "Reward Exchange %1",
  "args0": [
    {
      "type": "field_dropdown",
      "name": "contract",
      "options": [
        [
          "Uniswap",
          "EXCHANGE_CONTRACT_UNISWAP"
        ]
      ]
    }
  ],
  "output": null,
  "colour": 90,
  "tooltip": "",
  "helpUrl": ""
},
{
  "type": "tokenset",
  "message0": "Want token %1 %2 Intermediary token %3",
  "args0": [
    {
      "type": "field_dropdown",
      "name": "WANT_TOKEN",
      "options": [
        [
          "DAI",
          "TOKEN_DAI"
        ],
        [
          "BTC",
          "TOKEN_BTC"
        ],
        [
          "ETH",
          "TOKEN_ETH"
        ]
      ]
    },
    {
      "type": "input_dummy"
    },
    {
      "type": "field_dropdown",
      "name": "INTERMEDIARY_TOKEN",
      "options": [
        [
          "wETH",
          "TOKEN_WETH"
        ]
      ]
    }
  ],
  "output": "tokenset",
  "colour": 60,
  "tooltip": "",
  "helpUrl": ""
}
]);

var xmlText = `<xml xmlns="https://developers.google.com/blockly/xml">
  <block type="strategy" id="x$}:I(X}uKY*^wV3HP$?" x="138" y="88">
    <value name="NAME">
      <block type="text" id="zkb+X,HTd*Sgr:r6**h!">
        <field name="TEXT">BlocklyDAIStrategy</field>
      </block>
    </value>
    <value name="TOKENSET">
      <block type="tokenset" id="7_=.p\`)@jm)Qr|Tl34b)">
        <field name="WANT_TOKEN">TOKEN_DAI</field>
        <field name="INTERMEDIARY_TOKEN">TOKEN_WETH</field>
      </block>
    </value>
    <value name="PERFORMANCE_FEE">
      <block type="math_number" id="o{fvy)2~.bTl}3WEF6);">
        <field name="NUM">50000</field>
      </block>
    </value>
    <value name="PERFORMANCE_MAX">
      <block type="math_number" id="zvw}Q{3}TU*@+e4Q~f6w">
        <field name="NUM">1000000</field>
      </block>
    </value>
    <value name="WITHDRAWAL_FEE">
      <block type="math_number" id="5BH8Dec^?ttY;\`wSB1MO">
        <field name="NUM">50</field>
      </block>
    </value>
    <value name="WITHDRAWAL_MAX">
      <block type="math_number" id="^teI.LvRE^ak+MQ,!#F@">
        <field name="NUM">10000</field>
      </block>
    </value>
    <value name="DEPOSITOR">
      <block type="depositor" id="+{rsN@qP}iy.{}0o!cwn">
        <field name="CONTRACT">DEPOSITOR_CONTRACT_COMPOUND</field>
      </block>
    </value>
    <value name="REWARDOR">
      <block type="rewardor" id="5Vaj|$#mDBtUN83jJ.uy">
        <field name="CONTRACT">REWARDOR_CONTRACT_COMPOUND</field>
      </block>
    </value>
    <value name="EXCHANGE">
      <block type="exchange" id="4O+RFU5IY~5fX2PxQx@P">
        <field name="contract">EXCHANGE_CONTRACT_UNISWAP</field>
      </block>
    </value>
  </block>
</xml>`;


function xml() {
  return Blockly.Xml.textToDom(xmlText);
}

module.exports = {
  xml
}
