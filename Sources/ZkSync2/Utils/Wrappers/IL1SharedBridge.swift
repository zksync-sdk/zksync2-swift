//
//  File.swift
//  
//
//  Created by Petar Kopestinskij on 8.6.24..
//

import Foundation
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

public extension Web3.Utils {
    static var IL1SharedBridge = """
[
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "chainId",
        "type": "uint256"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "from",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "l1Token",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "BridgehubDepositBaseTokenInitiated",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "chainId",
        "type": "uint256"
      },
      {
        "indexed": true,
        "internalType": "bytes32",
        "name": "txDataHash",
        "type": "bytes32"
      },
      {
        "indexed": true,
        "internalType": "bytes32",
        "name": "l2DepositTxHash",
        "type": "bytes32"
      }
    ],
    "name": "BridgehubDepositFinalized",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "chainId",
        "type": "uint256"
      },
      {
        "indexed": true,
        "internalType": "bytes32",
        "name": "txDataHash",
        "type": "bytes32"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "from",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "to",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "l1Token",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "BridgehubDepositInitiated",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "chainId",
        "type": "uint256"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "to",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "l1Token",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "ClaimedFailedDepositSharedBridge",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "chainId",
        "type": "uint256"
      },
      {
        "indexed": true,
        "internalType": "bytes32",
        "name": "l2DepositTxHash",
        "type": "bytes32"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "from",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "to",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "l1Token",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "LegacyDepositInitiated",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "chainId",
        "type": "uint256"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "to",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "l1Token",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "WithdrawalFinalizedSharedBridge",
    "type": "event"
  },
  {
    "inputs": [],
    "name": "BRIDGE_HUB",
    "outputs": [
      {
        "internalType": "contract IBridgehub",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "L1_WETH_TOKEN",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_chainId",
        "type": "uint256"
      },
      {
        "internalType": "bytes32",
        "name": "_txDataHash",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32",
        "name": "_txHash",
        "type": "bytes32"
      }
    ],
    "name": "bridgehubConfirmL2Transaction",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_chainId",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "_prevMsgSender",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "_l2Value",
        "type": "uint256"
      },
      {
        "internalType": "bytes",
        "name": "_data",
        "type": "bytes"
      }
    ],
    "name": "bridgehubDeposit",
    "outputs": [
      {
        "components": [
          {
            "internalType": "bytes32",
            "name": "magicValue",
            "type": "bytes32"
          },
          {
            "internalType": "address",
            "name": "l2Contract",
            "type": "address"
          },
          {
            "internalType": "bytes",
            "name": "l2Calldata",
            "type": "bytes"
          },
          {
            "internalType": "bytes[]",
            "name": "factoryDeps",
            "type": "bytes[]"
          },
          {
            "internalType": "bytes32",
            "name": "txDataHash",
            "type": "bytes32"
          }
        ],
        "internalType": "struct L2TransactionRequestTwoBridgesInner",
        "name": "request",
        "type": "tuple"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_chainId",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "_prevMsgSender",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "_l1Token",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "_amount",
        "type": "uint256"
      }
    ],
    "name": "bridgehubDepositBaseToken",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_chainId",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "_depositSender",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "_l1Token",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "_amount",
        "type": "uint256"
      },
      {
        "internalType": "bytes32",
        "name": "_l2TxHash",
        "type": "bytes32"
      },
      {
        "internalType": "uint256",
        "name": "_l2BatchNumber",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_l2MessageIndex",
        "type": "uint256"
      },
      {
        "internalType": "uint16",
        "name": "_l2TxNumberInBatch",
        "type": "uint16"
      },
      {
        "internalType": "bytes32[]",
        "name": "_merkleProof",
        "type": "bytes32[]"
      }
    ],
    "name": "claimFailedDeposit",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_depositSender",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "_l1Token",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "_amount",
        "type": "uint256"
      },
      {
        "internalType": "bytes32",
        "name": "_l2TxHash",
        "type": "bytes32"
      },
      {
        "internalType": "uint256",
        "name": "_l2BatchNumber",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_l2MessageIndex",
        "type": "uint256"
      },
      {
        "internalType": "uint16",
        "name": "_l2TxNumberInBatch",
        "type": "uint16"
      },
      {
        "internalType": "bytes32[]",
        "name": "_merkleProof",
        "type": "bytes32[]"
      }
    ],
    "name": "claimFailedDepositLegacyErc20Bridge",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_chainId",
        "type": "uint256"
      },
      {
        "internalType": "bytes32",
        "name": "_l2TxHash",
        "type": "bytes32"
      }
    ],
    "name": "depositHappened",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_msgSender",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "_l2Receiver",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "_l1Token",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "_amount",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_l2TxGasLimit",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_l2TxGasPerPubdataByte",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "_refundRecipient",
        "type": "address"
      }
    ],
    "name": "depositLegacyErc20Bridge",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "txHash",
        "type": "bytes32"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_chainId",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_l2BatchNumber",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_l2MessageIndex",
        "type": "uint256"
      },
      {
        "internalType": "uint16",
        "name": "_l2TxNumberInBatch",
        "type": "uint16"
      },
      {
        "internalType": "bytes",
        "name": "_message",
        "type": "bytes"
      },
      {
        "internalType": "bytes32[]",
        "name": "_merkleProof",
        "type": "bytes32[]"
      }
    ],
    "name": "finalizeWithdrawal",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_l2BatchNumber",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_l2MessageIndex",
        "type": "uint256"
      },
      {
        "internalType": "uint16",
        "name": "_l2TxNumberInBatch",
        "type": "uint16"
      },
      {
        "internalType": "bytes",
        "name": "_message",
        "type": "bytes"
      },
      {
        "internalType": "bytes32[]",
        "name": "_merkleProof",
        "type": "bytes32[]"
      }
    ],
    "name": "finalizeWithdrawalLegacyErc20Bridge",
    "outputs": [
      {
        "internalType": "address",
        "name": "l1Receiver",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "l1Token",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_chainId",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_l2BatchNumber",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_l2MessageIndex",
        "type": "uint256"
      }
    ],
    "name": "isWithdrawalFinalized",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_chainId",
        "type": "uint256"
      }
    ],
    "name": "l2BridgeAddress",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "legacyBridge",
    "outputs": [
      {
        "internalType": "contract IL1ERC20Bridge",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_chainId",
        "type": "uint256"
      }
    ],
    "name": "receiveEth",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_eraLegacyBridgeLastDepositBatch",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_eraLegacyBridgeLastDepositTxNumber",
        "type": "uint256"
      }
    ],
    "name": "setEraLegacyBridgeLastDepositTime",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_eraPostDiamondUpgradeFirstBatch",
        "type": "uint256"
      }
    ],
    "name": "setEraPostDiamondUpgradeFirstBatch",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_eraPostLegacyBridgeUpgradeFirstBatch",
        "type": "uint256"
      }
    ],
    "name": "setEraPostLegacyBridgeUpgradeFirstBatch",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]
"""
}
