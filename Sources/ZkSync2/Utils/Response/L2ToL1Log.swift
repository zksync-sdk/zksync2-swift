//
//  L2ToL1Log.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 13.03.2023.
//

import Foundation
import BigInt

struct L2ToL1Log: Decodable {
    
    let blockNumber: BigUInt
    
    let blockHash: Data
    
    let l1BatchNumber: BigUInt
    
    let transactionIndex: UInt
    
    let shardId: UInt
    
    let isService: Bool
    
    let sender: String
    
    let key: String
    
    let value: String
    
    let transactionHash: String
    
    let logIndex: UInt
}
