//
//  ZkBlock.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 27.03.2023.
//

import Foundation
import web3swift
import BigInt

public struct Block: Decodable {
    
    let number: BigUInt
    
    let hash: Data
    
    let parentHash: Data
    
    let nonce: Data?
    
    let sha3Uncles: Data
    
    var logsBloom: EthereumBloomFilter? = nil
    
    let transactionsRoot: Data
    
    let stateRoot: Data
    
    let receiptsRoot: Data
    
    var miner: EthereumAddress? = nil
    
    let difficulty: BigUInt
    
    let totalDifficulty: BigUInt
    
    let extraData: Data
    
    let size: BigUInt
    
    let gasLimit: BigUInt
    
    let gasUsed: BigUInt
    
    let baseFeePerGas: BigUInt?
    
    let timestamp: Date
    
    let transactions: [TransactionInBlock]
    
    let uncles: [Data]
    
    let l1BatchNumber: BigUInt
    
    let l1BatchTimestamp: BigUInt
    
    enum CodingKeys: String, CodingKey {
        
        case number
        case hash
        case parentHash
        case nonce
        case sha3Uncles
        case logsBloom
        case transactionsRoot
        case stateRoot
        case receiptsRoot
        case miner
        case difficulty
        case totalDifficulty
        case extraData
        case size
        case gasLimit
        case gasUsed
        case baseFeePerGas
        case timestamp
        case transactions
        case uncles
        case l1BatchNumber
        case l1BatchTimestamp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        number = try container.decodeHex(BigUInt.self, forKey: .number)
        hash = try container.decodeHex(Data.self, forKey: .hash)
        parentHash = try container.decodeHex(Data.self, forKey: .parentHash)
        nonce = try? container.decodeHex(Data.self, forKey: .nonce)
        sha3Uncles = try container.decodeHex(Data.self, forKey: .sha3Uncles)
        
        if let logsBloomData = try? container.decodeHex(Data.self, forKey: .logsBloom) {
            logsBloom = EthereumBloomFilter(logsBloomData)
        }
        
        transactionsRoot = try container.decodeHex(Data.self, forKey: .transactionsRoot)
        stateRoot = try container.decodeHex(Data.self, forKey: .stateRoot)
        receiptsRoot = try container.decodeHex(Data.self, forKey: .receiptsRoot)
        
        if let minerAddress = try? container.decode(String.self, forKey: .miner) {
            miner = EthereumAddress(minerAddress)
        }
        
        difficulty = try container.decodeHex(BigUInt.self, forKey: .difficulty)
        totalDifficulty = try container.decodeHex(BigUInt.self, forKey: .totalDifficulty)
        extraData = try container.decodeHex(Data.self, forKey: .extraData)
        size = try container.decodeHex(BigUInt.self, forKey: .size)
        gasLimit = try container.decodeHex(BigUInt.self, forKey: .gasLimit)
        gasUsed = try container.decodeHex(BigUInt.self, forKey: .gasUsed)
        baseFeePerGas = try? container.decodeHex(BigUInt.self, forKey: .baseFeePerGas)
        timestamp = try container.decodeHex(Date.self, forKey: .timestamp)
        transactions = try container.decode([TransactionInBlock].self, forKey: .transactions)
        
        uncles = try container.decode([String].self, forKey: .uncles).map {
            guard let data = Data.fromHex($0) else { throw Web3Error.dataError }
            return data
        }
        
        l1BatchNumber = try container.decodeHex(BigUInt.self, forKey: .l1BatchNumber)
        l1BatchTimestamp = try container.decodeHex(BigUInt.self, forKey: .l1BatchTimestamp)
    }
}
