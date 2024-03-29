//
//  ZkSyncABI.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/24/22.
//

import Foundation
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

extension Web3.Utils {
    
    static var ZkSyncABI = """
[
    {
    "anonymous": false,
    "inputs": [
        {
            "indexed": true,
            "internalType": "uint32",
            "name": "blockNumber",
            "type": "uint32"
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
            "internalType": "uint32",
            "name": "blockNumber",
            "type": "uint32"
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
            "internalType": "uint32",
            "name": "totalBlocksVerified",
            "type": "uint32"
        },
        {
            "indexed": false,
            "internalType": "uint32",
            "name": "totalBlocksCommitted",
            "type": "uint32"
        }
    ],
    "name": "BlocksRevert",
    "type": "event"
},
    {
    "anonymous": false,
    "inputs": [
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
            "indexed": false,
            "internalType": "struct Diamond.FacetCut[]",
            "name": "_facetCuts",
            "type": "tuple[]"
        },
        {
            "indexed": false,
            "internalType": "address",
            "name": "_initAddress",
            "type": "address"
        }
    ],
    "name": "DiamondCutProposal",
    "type": "event"
},
    {
    "anonymous": false,
    "inputs": [],
    "name": "DiamondCutProposalCancelation",
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
            "name": "_diamondCut",
            "type": "tuple"
        }
    ],
    "name": "DiamondCutProposalExecution",
    "type": "event"
},
    {
    "anonymous": false,
    "inputs": [
        {
            "indexed": false,
            "internalType": "address",
            "name": "_address",
            "type": "address"
        }
    ],
    "name": "EmergencyDiamondCutApproved",
    "type": "event"
},
    {
    "anonymous": false,
    "inputs": [],
    "name": "EmergencyFreeze",
    "type": "event"
},
    {
    "anonymous": false,
    "inputs": [
        {
            "indexed": false,
            "internalType": "uint32",
            "name": "expirationBlock",
            "type": "uint32"
        },
        {
            "indexed": false,
            "internalType": "uint64[]",
            "name": "operationIDs",
            "type": "uint64[]"
        },
        {
            "indexed": false,
            "internalType": "enum Operations.OpTree",
            "name": "opTree",
            "type": "uint8"
        }
    ],
    "name": "MovePriorityOperationsFromBufferToHeap",
    "type": "event"
},
    {
    "anonymous": false,
    "inputs": [
        {
            "indexed": false,
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
            "indexed": false,
            "internalType": "enum Operations.OpTree",
            "name": "opTree",
            "type": "uint8"
        },
        {
            "indexed": false,
            "internalType": "address",
            "name": "sender",
            "type": "address"
        },
        {
            "indexed": false,
            "internalType": "uint96",
            "name": "bidAmount",
            "type": "uint96"
        },
        {
            "indexed": false,
            "internalType": "uint256",
            "name": "complexity",
            "type": "uint256"
        }
    ],
    "name": "NewPriorityModeAuctionBid",
    "type": "event"
},
    {
    "anonymous": false,
    "inputs": [
        {
            "indexed": false,
            "internalType": "enum PriorityModeLib.Epoch",
            "name": "subEpoch",
            "type": "uint8"
        },
        {
            "indexed": false,
            "internalType": "uint128",
            "name": "subEpochEndTimestamp",
            "type": "uint128"
        }
    ],
    "name": "NewPriorityModeSubEpoch",
    "type": "event"
},
    {
    "anonymous": false,
    "inputs": [
        {
            "indexed": false,
            "internalType": "uint64",
            "name": "serialId",
            "type": "uint64"
        },
        {
            "indexed": false,
            "internalType": "bytes",
            "name": "opMetadata",
            "type": "bytes"
        }
    ],
    "name": "NewPriorityRequest",
    "type": "event"
},
    {
    "anonymous": false,
    "inputs": [],
    "name": "PriorityModeActivated",
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
    "anonymous": false,
    "inputs": [
        {
            "indexed": true,
            "internalType": "address",
            "name": "zkSyncTokenAddress",
            "type": "address"
        },
        {
            "indexed": false,
            "internalType": "uint256",
            "name": "amount",
            "type": "uint256"
        }
    ],
    "name": "WithdrawPendingBalance",
    "type": "event"
},
    {
    "inputs": [
        {
            "internalType": "uint32",
            "name": "_ethExpirationBlock",
            "type": "uint32"
        }
    ],
    "name": "activatePriorityMode",
    "outputs": [
        {
            "internalType": "bool",
            "name": "",
            "type": "bool"
        }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
},
    {
    "inputs": [
        {
            "internalType": "address",
            "name": "_token",
            "type": "address"
        },
        {
            "internalType": "string",
            "name": "_name",
            "type": "string"
        },
        {
            "internalType": "string",
            "name": "_symbol",
            "type": "string"
        },
        {
            "internalType": "uint8",
            "name": "_decimals",
            "type": "uint8"
        },
        {
            "internalType": "enum Operations.QueueType",
            "name": "_queueType",
            "type": "uint8"
        },
        {
            "internalType": "enum Operations.OpTree",
            "name": "_opTree",
            "type": "uint8"
        }
    ],
    "name": "addCustomToken",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
},
    {
    "inputs": [
        {
            "internalType": "contract IERC20",
            "name": "_token",
            "type": "address"
        },
        {
            "internalType": "enum Operations.QueueType",
            "name": "_queueType",
            "type": "uint8"
        },
        {
            "internalType": "enum Operations.OpTree",
            "name": "_opTree",
            "type": "uint8"
        }
    ],
    "name": "addToken",
    "outputs": [],
    "stateMutability": "payable",
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
            "internalType": "enum Operations.QueueType",
            "name": "_queueType",
            "type": "uint8"
        },
        {
            "internalType": "enum Operations.OpTree",
            "name": "_opTree",
            "type": "uint8"
        }
    ],
    "name": "addTokenBaseCost",
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
    "inputs": [
        {
            "internalType": "bytes32",
            "name": "_diamondCutHash",
            "type": "bytes32"
        }
    ],
    "name": "approveEmergencyDiamondCutAsSecurityCouncilMember",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
},
    {
    "inputs": [],
    "name": "cancelDiamondCutProposal",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
},
    {
    "inputs": [
        {
            "internalType": "address",
            "name": "_newGovernor",
            "type": "address"
        }
    ],
    "name": "changeGovernor",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
},
    {
    "inputs": [
        {
            "components": [
                {
                    "internalType": "uint32",
                    "name": "blockNumber",
                    "type": "uint32"
                },
                {
                    "internalType": "uint16",
                    "name": "numberOfLayer1Txs",
                    "type": "uint16"
                },
                {
                    "internalType": "uint16",
                    "name": "numberOfLayer2Txs",
                    "type": "uint16"
                },
                {
                    "internalType": "uint224",
                    "name": "priorityOperationsComplexity",
                    "type": "uint224"
                },
                {
                    "internalType": "bytes32",
                    "name": "processableOnchainOperationsHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "priorityOperationsHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "uint256",
                    "name": "timestamp",
                    "type": "uint256"
                },
                {
                    "internalType": "bytes32",
                    "name": "stateRoot",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "zkPorterRoot",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "commitment",
                    "type": "bytes32"
                }
            ],
            "internalType": "struct IExecutor.StoredBlockInfo",
            "name": "_lastCommittedBlockData",
            "type": "tuple"
        },
        {
            "components": [
                {
                    "internalType": "bytes32",
                    "name": "newStateRoot",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "zkPorterRoot",
                    "type": "bytes32"
                },
                {
                    "internalType": "uint32",
                    "name": "blockNumber",
                    "type": "uint32"
                },
                {
                    "internalType": "address",
                    "name": "feeAccount",
                    "type": "address"
                },
                {
                    "internalType": "uint256",
                    "name": "timestamp",
                    "type": "uint256"
                },
                {
                    "internalType": "uint224",
                    "name": "priorityOperationsComplexity",
                    "type": "uint224"
                },
                {
                    "internalType": "uint16",
                    "name": "numberOfLayer1Txs",
                    "type": "uint16"
                },
                {
                    "internalType": "uint16",
                    "name": "numberOfLayer2Txs",
                    "type": "uint16"
                },
                {
                    "internalType": "bytes32",
                    "name": "processableOnchainOperationsHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "priorityOperationsHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes",
                    "name": "deployedContracts",
                    "type": "bytes"
                },
                {
                    "internalType": "bytes",
                    "name": "storageUpdateLogs",
                    "type": "bytes"
                },
                {
                    "components": [
                        {
                            "internalType": "uint32",
                            "name": "round",
                            "type": "uint32"
                        },
                        {
                            "components": [
                                {
                                    "internalType": "bytes",
                                    "name": "pubkey",
                                    "type": "bytes"
                                },
                                {
                                    "internalType": "bytes",
                                    "name": "signature",
                                    "type": "bytes"
                                }
                            ],
                            "internalType": "struct IExecutor.PublicWithSignature[]",
                            "name": "sigs",
                            "type": "tuple[]"
                        },
                        {
                            "internalType": "uint32",
                            "name": "stake",
                            "type": "uint32"
                        }
                    ],
                    "internalType": "struct IExecutor.QuorumSigs",
                    "name": "zkPorterData",
                    "type": "tuple"
                }
            ],
            "internalType": "struct IExecutor.CommitBlockInfo[]",
            "name": "_newBlocksData",
            "type": "tuple[]"
        }
    ],
    "name": "commitBlocks",
    "outputs": [],
    "stateMutability": "nonpayable",
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
            "name": "_gasLimit",
            "type": "uint256"
        },
        {
            "internalType": "uint32",
            "name": "_bytecodeLength",
            "type": "uint32"
        },
        {
            "internalType": "uint32",
            "name": "_calldataLength",
            "type": "uint32"
        },
        {
            "internalType": "enum Operations.QueueType",
            "name": "_queueType",
            "type": "uint8"
        },
        {
            "internalType": "enum Operations.OpTree",
            "name": "_opTree",
            "type": "uint8"
        }
    ],
    "name": "deployContractBaseCost",
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
    "inputs": [
        {
            "internalType": "uint256",
            "name": "_gasPrice",
            "type": "uint256"
        },
        {
            "internalType": "enum Operations.QueueType",
            "name": "_queueType",
            "type": "uint8"
        },
        {
            "internalType": "enum Operations.OpTree",
            "name": "_opTree",
            "type": "uint8"
        }
    ],
    "name": "depositBaseCost",
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
    "inputs": [
        {
            "internalType": "contract IERC20",
            "name": "_token",
            "type": "address"
        },
        {
            "internalType": "uint256",
            "name": "_amount",
            "type": "uint256"
        },
        {
            "internalType": "address",
            "name": "_zkSyncAddress",
            "type": "address"
        },
        {
            "internalType": "enum Operations.QueueType",
            "name": "_queueType",
            "type": "uint8"
        },
        {
            "internalType": "enum Operations.OpTree",
            "name": "_opTree",
            "type": "uint8"
        }
    ],
    "name": "depositERC20",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
},
    {
    "inputs": [
        {
            "internalType": "uint256",
            "name": "_amount",
            "type": "uint256"
        },
        {
            "internalType": "address",
            "name": "_zkSyncAddress",
            "type": "address"
        },
        {
            "internalType": "enum Operations.QueueType",
            "name": "_queueType",
            "type": "uint8"
        },
        {
            "internalType": "enum Operations.OpTree",
            "name": "_opTree",
            "type": "uint8"
        }
    ],
    "name": "depositETH",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
},
    {
    "inputs": [],
    "name": "emergencyFreezeDiamond",
    "outputs": [],
    "stateMutability": "nonpayable",
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
            "name": "_gasLimit",
            "type": "uint256"
        },
        {
            "internalType": "uint32",
            "name": "_calldataLength",
            "type": "uint32"
        },
        {
            "internalType": "enum Operations.QueueType",
            "name": "_queueType",
            "type": "uint8"
        },
        {
            "internalType": "enum Operations.OpTree",
            "name": "_opTree",
            "type": "uint8"
        }
    ],
    "name": "executeBaseCost",
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
    "inputs": [
        {
            "components": [
                {
                    "components": [
                        {
                            "internalType": "uint32",
                            "name": "blockNumber",
                            "type": "uint32"
                        },
                        {
                            "internalType": "uint16",
                            "name": "numberOfLayer1Txs",
                            "type": "uint16"
                        },
                        {
                            "internalType": "uint16",
                            "name": "numberOfLayer2Txs",
                            "type": "uint16"
                        },
                        {
                            "internalType": "uint224",
                            "name": "priorityOperationsComplexity",
                            "type": "uint224"
                        },
                        {
                            "internalType": "bytes32",
                            "name": "processableOnchainOperationsHash",
                            "type": "bytes32"
                        },
                        {
                            "internalType": "bytes32",
                            "name": "priorityOperationsHash",
                            "type": "bytes32"
                        },
                        {
                            "internalType": "uint256",
                            "name": "timestamp",
                            "type": "uint256"
                        },
                        {
                            "internalType": "bytes32",
                            "name": "stateRoot",
                            "type": "bytes32"
                        },
                        {
                            "internalType": "bytes32",
                            "name": "zkPorterRoot",
                            "type": "bytes32"
                        },
                        {
                            "internalType": "bytes32",
                            "name": "commitment",
                            "type": "bytes32"
                        }
                    ],
                    "internalType": "struct IExecutor.StoredBlockInfo",
                    "name": "storedBlock",
                    "type": "tuple"
                },
                {
                    "internalType": "bytes",
                    "name": "processableOnchainOperations",
                    "type": "bytes"
                }
            ],
            "internalType": "struct IExecutor.ExecuteBlockInfo[]",
            "name": "_blocksData",
            "type": "tuple[]"
        }
    ],
    "name": "executeBlocks",
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
    "name": "executeDiamondCutProposal",
    "outputs": [],
    "stateMutability": "nonpayable",
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
    "inputs": [
        {
            "internalType": "address",
            "name": "_address",
            "type": "address"
        },
        {
            "internalType": "address",
            "name": "_token",
            "type": "address"
        }
    ],
    "name": "getPendingBalance",
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
    "name": "getTotalBlocksCommitted",
    "outputs": [
        {
            "internalType": "uint32",
            "name": "",
            "type": "uint32"
        }
    ],
    "stateMutability": "view",
    "type": "function"
},
    {
    "inputs": [],
    "name": "getTotalBlocksExecuted",
    "outputs": [
        {
            "internalType": "uint32",
            "name": "",
            "type": "uint32"
        }
    ],
    "stateMutability": "view",
    "type": "function"
},
    {
    "inputs": [],
    "name": "getTotalBlocksVerified",
    "outputs": [
        {
            "internalType": "uint32",
            "name": "",
            "type": "uint32"
        }
    ],
    "stateMutability": "view",
    "type": "function"
},
    {
    "inputs": [],
    "name": "getTotalPriorityRequests",
    "outputs": [
        {
            "internalType": "uint64",
            "name": "",
            "type": "uint64"
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
            "name": "_nOpsToMove",
            "type": "uint256"
        },
        {
            "internalType": "enum Operations.OpTree",
            "name": "_opTree",
            "type": "uint8"
        }
    ],
    "name": "movePriorityOpsFromBufferToMainQueue",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
},
    {
    "inputs": [
        {
            "internalType": "uint112",
            "name": "_complexityRoot",
            "type": "uint112"
        },
        {
            "internalType": "enum Operations.OpTree",
            "name": "_opTree",
            "type": "uint8"
        }
    ],
    "name": "placeBidForBlocksProcessingAuction",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
},
    {
    "inputs": [
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
            "name": "_facetCuts",
            "type": "tuple[]"
        },
        {
            "internalType": "address",
            "name": "_initAddress",
            "type": "address"
        }
    ],
    "name": "proposeDiamondCut",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
},
    {
    "inputs": [
        {
            "components": [
                {
                    "internalType": "uint32",
                    "name": "blockNumber",
                    "type": "uint32"
                },
                {
                    "internalType": "uint16",
                    "name": "numberOfLayer1Txs",
                    "type": "uint16"
                },
                {
                    "internalType": "uint16",
                    "name": "numberOfLayer2Txs",
                    "type": "uint16"
                },
                {
                    "internalType": "uint224",
                    "name": "priorityOperationsComplexity",
                    "type": "uint224"
                },
                {
                    "internalType": "bytes32",
                    "name": "processableOnchainOperationsHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "priorityOperationsHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "uint256",
                    "name": "timestamp",
                    "type": "uint256"
                },
                {
                    "internalType": "bytes32",
                    "name": "stateRoot",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "zkPorterRoot",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "commitment",
                    "type": "bytes32"
                }
            ],
            "internalType": "struct IExecutor.StoredBlockInfo[]",
            "name": "_committedBlocks",
            "type": "tuple[]"
        },
        {
            "components": [
                {
                    "internalType": "uint256[]",
                    "name": "recursiveInput",
                    "type": "uint256[]"
                },
                {
                    "internalType": "uint256[]",
                    "name": "proof",
                    "type": "uint256[]"
                },
                {
                    "internalType": "uint256[]",
                    "name": "commitments",
                    "type": "uint256[]"
                },
                {
                    "internalType": "uint8[]",
                    "name": "vkIndexes",
                    "type": "uint8[]"
                },
                {
                    "internalType": "uint256[16]",
                    "name": "subproofsLimbs",
                    "type": "uint256[16]"
                }
            ],
            "internalType": "struct IExecutor.ProofInput",
            "name": "_proof",
            "type": "tuple"
        }
    ],
    "name": "proveBlocks",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
},
    {
    "inputs": [
        {
            "internalType": "bytes",
            "name": "_bytecode",
            "type": "bytes"
        },
        {
            "internalType": "bytes",
            "name": "_calldata",
            "type": "bytes"
        },
        {
            "internalType": "uint256",
            "name": "_gasLimit",
            "type": "uint256"
        },
        {
            "internalType": "enum Operations.QueueType",
            "name": "_queueType",
            "type": "uint8"
        },
        {
            "internalType": "enum Operations.OpTree",
            "name": "_opTree",
            "type": "uint8"
        }
    ],
    "name": "requestDeployContract",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
},
    {
    "inputs": [
        {
            "internalType": "address",
            "name": "_contractAddressL2",
            "type": "address"
        },
        {
            "internalType": "bytes",
            "name": "_calldata",
            "type": "bytes"
        },
        {
            "internalType": "uint256",
            "name": "_gasLimit",
            "type": "uint256"
        },
        {
            "internalType": "enum Operations.QueueType",
            "name": "_queueType",
            "type": "uint8"
        },
        {
            "internalType": "enum Operations.OpTree",
            "name": "_opTree",
            "type": "uint8"
        }
    ],
    "name": "requestExecute",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
},
    {
    "inputs": [
        {
            "internalType": "address",
            "name": "_token",
            "type": "address"
        },
        {
            "internalType": "uint256",
            "name": "_amount",
            "type": "uint256"
        },
        {
            "internalType": "address",
            "name": "_to",
            "type": "address"
        },
        {
            "internalType": "enum Operations.QueueType",
            "name": "_queueType",
            "type": "uint8"
        },
        {
            "internalType": "enum Operations.OpTree",
            "name": "_opTree",
            "type": "uint8"
        }
    ],
    "name": "requestWithdraw",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
},
    {
    "inputs": [
        {
            "internalType": "uint32",
            "name": "_blocksToRevert",
            "type": "uint32"
        }
    ],
    "name": "revertBlocks",
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
    "inputs": [],
    "name": "unfreezeDiamond",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
},
    {
    "inputs": [],
    "name": "updatePriorityModeSubEpoch",
    "outputs": [],
    "stateMutability": "nonpayable",
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
            "internalType": "enum Operations.QueueType",
            "name": "_queueType",
            "type": "uint8"
        },
        {
            "internalType": "enum Operations.OpTree",
            "name": "_opTree",
            "type": "uint8"
        }
    ],
    "name": "withdrawBaseCost",
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
    "inputs": [
        {
            "internalType": "address payable",
            "name": "_owner",
            "type": "address"
        },
        {
            "internalType": "address",
            "name": "_token",
            "type": "address"
        },
        {
            "internalType": "uint256",
            "name": "_amount",
            "type": "uint256"
        }
    ],
    "name": "withdrawPendingBalance",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
}
]
"""
}
