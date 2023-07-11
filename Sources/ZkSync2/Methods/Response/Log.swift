//
//  Log.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 20.03.2023.
//

import Foundation
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif
import BigInt

public struct Log: Decodable {
    
    let address: EthereumAddress
    
    let blockHash: Data
    
    let blockNumber: BigUInt
    
    let data: Data
    
    let logIndex: BigUInt
    
    let removed: Bool
    
    let topics: [Data]
    
    let transactionHash: Data
    
    let transactionIndex: BigUInt
    
    let l1BatchNumber: BigUInt
    
    enum CodingKeys: String, CodingKey {
        
        case address
        case blockHash
        case blockNumber
        case data
        case logIndex
        case removed
        case topics
        case transactionHash
        case transactionIndex
        case l1BatchNumber
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        address = try container.decode(EthereumAddress.self, forKey: .address)
        blockNumber = try container.decodeHex(BigUInt.self, forKey: .blockNumber)
        blockHash = try container.decodeHex(Data.self, forKey: .blockHash)
        transactionIndex = try container.decodeHex(BigUInt.self, forKey: .transactionIndex)
        transactionHash = try container.decodeHex(Data.self, forKey: .transactionHash)
        data = try container.decodeHex(Data.self, forKey: .data)
        logIndex = try container.decodeHex(BigUInt.self, forKey: .logIndex)
        let removed = try? container.decodeHex(BigUInt.self, forKey: .removed)
        self.removed = removed == 1
        topics = try container.decode([String].self, forKey: .topics).map {
            guard let topic = Data.fromHex($0) else { throw Web3Error.dataError }
            return topic
        }
        
        l1BatchNumber = try container.decodeHex(BigUInt.self, forKey: .l1BatchNumber)
    }
}
