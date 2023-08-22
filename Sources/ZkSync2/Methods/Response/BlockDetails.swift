//
//  BlockDetails.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 13.03.2023.
//

import Foundation

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
