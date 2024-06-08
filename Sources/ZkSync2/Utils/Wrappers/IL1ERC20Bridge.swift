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
    static var IL1ERC20Bridge = """
[
  {
    "anonymous": false,
    "inputs": [
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
    "name": "ClaimedFailedDeposit",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
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
        "indexed": true,
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
    "name": "DepositInitiated",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
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
    "name": "WithdrawalFinalized",
    "type": "event"
  },
  {
    "inputs": [],
    "name": "SHARED_BRIDGE",
    "outputs": [
      {
        "internalType": "contract IL1SharedBridge",
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
      }
    ],
    "name": "deposit",
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
    "name": "deposit",
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
        "internalType": "address",
        "name": "_account",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "_l1Token",
        "type": "address"
      },
      {
        "internalType": "bytes32",
        "name": "_depositL2TxHash",
        "type": "bytes32"
      }
    ],
    "name": "depositAmount",
    "outputs": [
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
    "inputs": [],
    "name": "l2Bridge",
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
        "internalType": "address",
        "name": "_l1Token",
        "type": "address"
      }
    ],
    "name": "l2TokenAddress",
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
    "name": "l2TokenBeacon",
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
        "internalType": "address",
        "name": "_token",
        "type": "address"
      }
    ],
    "name": "transferTokenToSharedBridge",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]
"""
}
