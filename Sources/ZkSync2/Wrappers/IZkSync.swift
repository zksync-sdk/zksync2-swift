//
//  IZkSync.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 02.04.2023.
//

import Foundation
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

public extension Web3.Utils {
    
    static var IZkSync = """
[
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "batchNumber",
        "type": "uint256"
      },
      {
        "indexed": true,
        "internalType": "bytes32",
        "name": "batchHash",
        "type": "bytes32"
      },
      {
        "indexed": true,
        "internalType": "bytes32",
        "name": "commitment",
        "type": "bytes32"
      }
    ],
    "name": "BlockCommit",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "batchNumber",
        "type": "uint256"
      },
      {
        "indexed": true,
        "internalType": "bytes32",
        "name": "batchHash",
        "type": "bytes32"
      },
      {
        "indexed": true,
        "internalType": "bytes32",
        "name": "commitment",
        "type": "bytes32"
      }
    ],
    "name": "BlockExecution",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "totalBatchesCommitted",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "totalBatchesVerified",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "totalBatchesExecuted",
        "type": "uint256"
      }
    ],
    "name": "BlocksRevert",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "previousLastVerifiedBatch",
        "type": "uint256"
      },
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "currentLastVerifiedBatch",
        "type": "uint256"
      }
    ],
    "name": "BlocksVerification",
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
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "EthWithdrawalFinalized",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "components": [
          {
            "components": [
              {
                "internalType": "address",
                "name": "facet",
                "type": "address"
              },
              {
                "internalType": "enum Diamond.Action",
                "name": "action",
                "type": "uint8"
              },
              {
                "internalType": "bool",
                "name": "isFreezable",
                "type": "bool"
              },
              {
                "internalType": "bytes4[]",
                "name": "selectors",
                "type": "bytes4[]"
              }
            ],
            "internalType": "struct Diamond.FacetCut[]",
            "name": "facetCuts",
            "type": "tuple[]"
          },
          {
            "internalType": "address",
            "name": "initAddress",
            "type": "address"
          },
          {
            "internalType": "bytes",
            "name": "initCalldata",
            "type": "bytes"
          }
        ],
        "indexed": false,
        "internalType": "struct Diamond.DiamondCutData",
        "name": "diamondCut",
        "type": "tuple"
      }
    ],
    "name": "ExecuteUpgrade",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [],
    "name": "Freeze",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "bool",
        "name": "isPorterAvailable",
        "type": "bool"
      }
    ],
    "name": "IsPorterAvailableStatusUpdate",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "oldAdmin",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "newAdmin",
        "type": "address"
      }
    ],
    "name": "NewAdmin",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "oldGovernor",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "newGovernor",
        "type": "address"
      }
    ],
    "name": "NewGovernor",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "oldPendingAdmin",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "newPendingAdmin",
        "type": "address"
      }
    ],
    "name": "NewPendingAdmin",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "oldPendingGovernor",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "newPendingGovernor",
        "type": "address"
      }
    ],
    "name": "NewPendingGovernor",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "txId",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "bytes32",
        "name": "txHash",
        "type": "bytes32"
      },
      {
        "indexed": false,
        "internalType": "uint64",
        "name": "expirationTimestamp",
        "type": "uint64"
      },
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "txType",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "from",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "to",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "gasLimit",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "gasPerPubdataByteLimit",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "maxFeePerGas",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "maxPriorityFeePerGas",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "paymaster",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "nonce",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "value",
            "type": "uint256"
          },
          {
            "internalType": "uint256[4]",
            "name": "reserved",
            "type": "uint256[4]"
          },
          {
            "internalType": "bytes",
            "name": "data",
            "type": "bytes"
          },
          {
            "internalType": "bytes",
            "name": "signature",
            "type": "bytes"
          },
          {
            "internalType": "uint256[]",
            "name": "factoryDeps",
            "type": "uint256[]"
          },
          {
            "internalType": "bytes",
            "name": "paymasterInput",
            "type": "bytes"
          },
          {
            "internalType": "bytes",
            "name": "reservedDynamic",
            "type": "bytes"
          }
        ],
        "indexed": false,
        "internalType": "struct IMailbox.L2CanonicalTransaction",
        "name": "transaction",
        "type": "tuple"
      },
      {
        "indexed": false,
        "internalType": "bytes[]",
        "name": "factoryDeps",
        "type": "bytes[]"
      }
    ],
    "name": "NewPriorityRequest",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "oldPriorityTxMaxGasLimit",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "newPriorityTxMaxGasLimit",
        "type": "uint256"
      }
    ],
    "name": "NewPriorityTxMaxGasLimit",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [],
    "name": "Unfreeze",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "validatorAddress",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "bool",
        "name": "isActive",
        "type": "bool"
      }
    ],
    "name": "ValidatorStatusUpdate",
    "type": "event"
  },
  {
    "inputs": [],
    "name": "acceptAdmin",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "acceptGovernor",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "components": [
          {
            "internalType": "uint64",
            "name": "batchNumber",
            "type": "uint64"
          },
          {
            "internalType": "bytes32",
            "name": "batchHash",
            "type": "bytes32"
          },
          {
            "internalType": "uint64",
            "name": "indexRepeatedStorageChanges",
            "type": "uint64"
          },
          {
            "internalType": "uint256",
            "name": "numberOfLayer1Txs",
            "type": "uint256"
          },
          {
            "internalType": "bytes32",
            "name": "priorityOperationsHash",
            "type": "bytes32"
          },
          {
            "internalType": "bytes32",
            "name": "l2LogsTreeRoot",
            "type": "bytes32"
          },
          {
            "internalType": "uint256",
            "name": "timestamp",
            "type": "uint256"
          },
          {
            "internalType": "bytes32",
            "name": "commitment",
            "type": "bytes32"
          }
        ],
        "internalType": "struct IExecutor.StoredBatchInfo",
        "name": "_lastCommittedBatchData",
        "type": "tuple"
      },
      {
        "components": [
          {
            "internalType": "uint64",
            "name": "batchNumber",
            "type": "uint64"
          },
          {
            "internalType": "uint64",
            "name": "timestamp",
            "type": "uint64"
          },
          {
            "internalType": "uint64",
            "name": "indexRepeatedStorageChanges",
            "type": "uint64"
          },
          {
            "internalType": "bytes32",
            "name": "newStateRoot",
            "type": "bytes32"
          },
          {
            "internalType": "uint256",
            "name": "numberOfLayer1Txs",
            "type": "uint256"
          },
          {
            "internalType": "bytes32",
            "name": "priorityOperationsHash",
            "type": "bytes32"
          },
          {
            "internalType": "bytes32",
            "name": "bootloaderHeapInitialContentsHash",
            "type": "bytes32"
          },
          {
            "internalType": "bytes32",
            "name": "eventsQueueStateHash",
            "type": "bytes32"
          },
          {
            "internalType": "bytes",
            "name": "systemLogs",
            "type": "bytes"
          },
          {
            "internalType": "bytes",
            "name": "totalL2ToL1Pubdata",
            "type": "bytes"
          }
        ],
        "internalType": "struct IExecutor.CommitBatchInfo[]",
        "name": "_newBatchesData",
        "type": "tuple[]"
      }
    ],
    "name": "commitBatches",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "components": [
          {
            "internalType": "uint64",
            "name": "batchNumber",
            "type": "uint64"
          },
          {
            "internalType": "bytes32",
            "name": "batchHash",
            "type": "bytes32"
          },
          {
            "internalType": "uint64",
            "name": "indexRepeatedStorageChanges",
            "type": "uint64"
          },
          {
            "internalType": "uint256",
            "name": "numberOfLayer1Txs",
            "type": "uint256"
          },
          {
            "internalType": "bytes32",
            "name": "priorityOperationsHash",
            "type": "bytes32"
          },
          {
            "internalType": "bytes32",
            "name": "l2LogsTreeRoot",
            "type": "bytes32"
          },
          {
            "internalType": "uint256",
            "name": "timestamp",
            "type": "uint256"
          },
          {
            "internalType": "bytes32",
            "name": "commitment",
            "type": "bytes32"
          }
        ],
        "internalType": "struct IExecutor.StoredBatchInfo[]",
        "name": "_batchesData",
        "type": "tuple[]"
      }
    ],
    "name": "executeBatches",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "components": [
          {
            "components": [
              {
                "internalType": "address",
                "name": "facet",
                "type": "address"
              },
              {
                "internalType": "enum Diamond.Action",
                "name": "action",
                "type": "uint8"
              },
              {
                "internalType": "bool",
                "name": "isFreezable",
                "type": "bool"
              },
              {
                "internalType": "bytes4[]",
                "name": "selectors",
                "type": "bytes4[]"
              }
            ],
            "internalType": "struct Diamond.FacetCut[]",
            "name": "facetCuts",
            "type": "tuple[]"
          },
          {
            "internalType": "address",
            "name": "initAddress",
            "type": "address"
          },
          {
            "internalType": "bytes",
            "name": "initCalldata",
            "type": "bytes"
          }
        ],
        "internalType": "struct Diamond.DiamondCutData",
        "name": "_diamondCut",
        "type": "tuple"
      }
    ],
    "name": "executeUpgrade",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes4",
        "name": "_selector",
        "type": "bytes4"
      }
    ],
    "name": "facetAddress",
    "outputs": [
      {
        "internalType": "address",
        "name": "facet",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "facetAddresses",
    "outputs": [
      {
        "internalType": "address[]",
        "name": "facets",
        "type": "address[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_facet",
        "type": "address"
      }
    ],
    "name": "facetFunctionSelectors",
    "outputs": [
      {
        "internalType": "bytes4[]",
        "name": "",
        "type": "bytes4[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "facets",
    "outputs": [
      {
        "components": [
          {
            "internalType": "address",
            "name": "addr",
            "type": "address"
          },
          {
            "internalType": "bytes4[]",
            "name": "selectors",
            "type": "bytes4[]"
          }
        ],
        "internalType": "struct IGetters.Facet[]",
        "name": "",
        "type": "tuple[]"
      }
    ],
    "stateMutability": "view",
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
    "name": "finalizeEthWithdrawal",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "freezeDiamond",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getFirstUnprocessedPriorityTx",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getGovernor",
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
    "name": "getL2BootloaderBytecodeHash",
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
    "inputs": [],
    "name": "getL2DefaultAccountBytecodeHash",
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
    "inputs": [],
    "name": "getL2SystemContractsUpgradeBatchNumber",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getL2SystemContractsUpgradeTxHash",
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
    "inputs": [],
    "name": "getName",
    "outputs": [
      {
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getPendingGovernor",
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
    "name": "getPriorityQueueSize",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getPriorityTxMaxGasLimit",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getProtocolVersion",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getTotalBatchesCommitted",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getTotalBatchesExecuted",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getTotalBatchesVerified",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getTotalPriorityTxs",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getVerifier",
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
    "name": "getVerifierParams",
    "outputs": [
      {
        "components": [
          {
            "internalType": "bytes32",
            "name": "recursionNodeLevelVkHash",
            "type": "bytes32"
          },
          {
            "internalType": "bytes32",
            "name": "recursionLeafLevelVkHash",
            "type": "bytes32"
          },
          {
            "internalType": "bytes32",
            "name": "recursionCircuitsSetVksHash",
            "type": "bytes32"
          }
        ],
        "internalType": "struct VerifierParams",
        "name": "",
        "type": "tuple"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "isDiamondStorageFrozen",
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
        "name": "_l2BatchNumber",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_l2MessageIndex",
        "type": "uint256"
      }
    ],
    "name": "isEthWithdrawalFinalized",
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
        "internalType": "address",
        "name": "_facet",
        "type": "address"
      }
    ],
    "name": "isFacetFreezable",
    "outputs": [
      {
        "internalType": "bool",
        "name": "isFreezable",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes4",
        "name": "_selector",
        "type": "bytes4"
      }
    ],
    "name": "isFunctionFreezable",
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
        "internalType": "address",
        "name": "_address",
        "type": "address"
      }
    ],
    "name": "isValidator",
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
        "name": "_batchNumber",
        "type": "uint256"
      }
    ],
    "name": "l2LogsRootHash",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "hash",
        "type": "bytes32"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_gasPrice",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_l2GasLimit",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_l2GasPerPubdataByteLimit",
        "type": "uint256"
      }
    ],
    "name": "l2TransactionBaseCost",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "priorityQueueFrontOperation",
    "outputs": [
      {
        "components": [
          {
            "internalType": "bytes32",
            "name": "canonicalTxHash",
            "type": "bytes32"
          },
          {
            "internalType": "uint64",
            "name": "expirationTimestamp",
            "type": "uint64"
          },
          {
            "internalType": "uint192",
            "name": "layer2Tip",
            "type": "uint192"
          }
        ],
        "internalType": "struct PriorityOperation",
        "name": "",
        "type": "tuple"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "components": [
          {
            "internalType": "uint64",
            "name": "batchNumber",
            "type": "uint64"
          },
          {
            "internalType": "bytes32",
            "name": "batchHash",
            "type": "bytes32"
          },
          {
            "internalType": "uint64",
            "name": "indexRepeatedStorageChanges",
            "type": "uint64"
          },
          {
            "internalType": "uint256",
            "name": "numberOfLayer1Txs",
            "type": "uint256"
          },
          {
            "internalType": "bytes32",
            "name": "priorityOperationsHash",
            "type": "bytes32"
          },
          {
            "internalType": "bytes32",
            "name": "l2LogsTreeRoot",
            "type": "bytes32"
          },
          {
            "internalType": "uint256",
            "name": "timestamp",
            "type": "uint256"
          },
          {
            "internalType": "bytes32",
            "name": "commitment",
            "type": "bytes32"
          }
        ],
        "internalType": "struct IExecutor.StoredBatchInfo",
        "name": "_prevBatch",
        "type": "tuple"
      },
      {
        "components": [
          {
            "internalType": "uint64",
            "name": "batchNumber",
            "type": "uint64"
          },
          {
            "internalType": "bytes32",
            "name": "batchHash",
            "type": "bytes32"
          },
          {
            "internalType": "uint64",
            "name": "indexRepeatedStorageChanges",
            "type": "uint64"
          },
          {
            "internalType": "uint256",
            "name": "numberOfLayer1Txs",
            "type": "uint256"
          },
          {
            "internalType": "bytes32",
            "name": "priorityOperationsHash",
            "type": "bytes32"
          },
          {
            "internalType": "bytes32",
            "name": "l2LogsTreeRoot",
            "type": "bytes32"
          },
          {
            "internalType": "uint256",
            "name": "timestamp",
            "type": "uint256"
          },
          {
            "internalType": "bytes32",
            "name": "commitment",
            "type": "bytes32"
          }
        ],
        "internalType": "struct IExecutor.StoredBatchInfo[]",
        "name": "_committedBatches",
        "type": "tuple[]"
      },
      {
        "components": [
          {
            "internalType": "uint256[]",
            "name": "recursiveAggregationInput",
            "type": "uint256[]"
          },
          {
            "internalType": "uint256[]",
            "name": "serializedProof",
            "type": "uint256[]"
          }
        ],
        "internalType": "struct IExecutor.ProofInput",
        "name": "_proof",
        "type": "tuple"
      }
    ],
    "name": "proveBatches",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
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
      },
      {
        "internalType": "enum TxStatus",
        "name": "_status",
        "type": "uint8"
      }
    ],
    "name": "proveL1ToL2TransactionStatus",
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
        "name": "_l2BatchNumber",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_index",
        "type": "uint256"
      },
      {
        "components": [
          {
            "internalType": "uint8",
            "name": "l2ShardId",
            "type": "uint8"
          },
          {
            "internalType": "bool",
            "name": "isService",
            "type": "bool"
          },
          {
            "internalType": "uint16",
            "name": "txNumberInBatch",
            "type": "uint16"
          },
          {
            "internalType": "address",
            "name": "sender",
            "type": "address"
          },
          {
            "internalType": "bytes32",
            "name": "key",
            "type": "bytes32"
          },
          {
            "internalType": "bytes32",
            "name": "value",
            "type": "bytes32"
          }
        ],
        "internalType": "struct L2Log",
        "name": "_log",
        "type": "tuple"
      },
      {
        "internalType": "bytes32[]",
        "name": "_proof",
        "type": "bytes32[]"
      }
    ],
    "name": "proveL2LogInclusion",
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
        "name": "_l2BatchNumber",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_index",
        "type": "uint256"
      },
      {
        "components": [
          {
            "internalType": "uint16",
            "name": "txNumberInBatch",
            "type": "uint16"
          },
          {
            "internalType": "address",
            "name": "sender",
            "type": "address"
          },
          {
            "internalType": "bytes",
            "name": "data",
            "type": "bytes"
          }
        ],
        "internalType": "struct L2Message",
        "name": "_message",
        "type": "tuple"
      },
      {
        "internalType": "bytes32[]",
        "name": "_proof",
        "type": "bytes32[]"
      }
    ],
    "name": "proveL2MessageInclusion",
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
        "internalType": "address",
        "name": "_contractL2",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "_l2Value",
        "type": "uint256"
      },
      {
        "internalType": "bytes",
        "name": "_calldata",
        "type": "bytes"
      },
      {
        "internalType": "uint256",
        "name": "_l2GasLimit",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_l2GasPerPubdataByteLimit",
        "type": "uint256"
      },
      {
        "internalType": "bytes[]",
        "name": "_factoryDeps",
        "type": "bytes[]"
      },
      {
        "internalType": "address",
        "name": "_refundRecipient",
        "type": "address"
      }
    ],
    "name": "requestL2Transaction",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "canonicalTxHash",
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
        "name": "_newLastBatch",
        "type": "uint256"
      }
    ],
    "name": "revertBatches",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_newPendingAdmin",
        "type": "address"
      }
    ],
    "name": "setPendingAdmin",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_newPendingGovernor",
        "type": "address"
      }
    ],
    "name": "setPendingGovernor",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bool",
        "name": "_zkPorterIsAvailable",
        "type": "bool"
      }
    ],
    "name": "setPorterAvailability",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_newPriorityTxMaxGasLimit",
        "type": "uint256"
      }
    ],
    "name": "setPriorityTxMaxGasLimit",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_validator",
        "type": "address"
      },
      {
        "internalType": "bool",
        "name": "_active",
        "type": "bool"
      }
    ],
    "name": "setValidator",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_batchNumber",
        "type": "uint256"
      }
    ],
    "name": "storedBatchHash",
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
    "inputs": [],
    "name": "unfreezeDiamond",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]
"""
}
