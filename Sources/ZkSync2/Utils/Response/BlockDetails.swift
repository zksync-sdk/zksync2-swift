//
//  BlockDetails.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 13.03.2023.
//

import Foundation
import BigInt
import Web3Core

public struct BlockDetails: Decodable {
    
    let commitTxHash: String?
    
    let committedAt: Date?
    
    let executeTxHash: String?
    
    let executedAt: Date?
    
    let l1TxCount: UInt
    
    let l2TxCount: UInt
    
    let number: UInt
    
    let proveTxHash: String?
    
    let provenAt: Date?
    
    let rootHash: String?
    
    let status: String
    
    let timestamp: UInt
}

struct L2TransactionRequestDirect {
    let chainId: BigUInt
    let mintValue: BigUInt
    let l2Contract: EthereumAddress
    let l2Value: BigUInt
    let l2Calldata: Data
    let l2GasLimit: BigUInt
    let l2GasPerPubdataByteLimit: BigUInt
    let factoryDeps: [Data]
    let refundRecipient: EthereumAddress
}
