//
//  TransactionResponse.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 20.03.2023.
//

import Foundation
import BigInt

public struct TransactionResponse: Decodable {
    
    let blockHash: Data
    
    let chainId: BigUInt
    
    let maxFeePerGas: BigUInt
    
    let v: BigUInt
    
    let r: BigUInt
    
    let s: BigUInt
    
    let l1BatchNumber: BigUInt
    
    let l1BatchTxIndex: BigUInt
    
    let input: Data
    
    let gasPrice: BigUInt
    
    let type: UInt
    
    let nonce: UInt
    
    let blockNumber: BigUInt
    
    let to: String
    
    let maxPriorityFeePerGas: BigUInt
    
    let from: String
    
    let gas: BigUInt
    
    let hash: String
    
    let value: BigUInt
    
    let transactionIndex: BigUInt
    
    enum CodingKeys: String, CodingKey {
        
        case blockHash
        case chainId
        case maxFeePerGas
        case v
        case r
        case s
        case l1BatchNumber
        case l1BatchTxIndex
        case input
        case gasPrice
        case type
        case nonce
        case blockNumber
        case to
        case maxPriorityFeePerGas
        case from
        case gas
        case hash
        case value
        case transactionIndex
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        blockHash = try container.decodeHex(Data.self, forKey: .blockHash)
        chainId = try container.decodeHex(BigUInt.self, forKey: .chainId)
        maxFeePerGas = try container.decodeHex(BigUInt.self, forKey: .maxFeePerGas)
        v = try container.decodeHex(BigUInt.self, forKey: .v)
        r = try container.decodeHex(BigUInt.self, forKey: .r)
        s = try container.decodeHex(BigUInt.self, forKey: .s)
        l1BatchNumber = try container.decodeHex(BigUInt.self, forKey: .l1BatchNumber)
        l1BatchTxIndex = try container.decodeHex(BigUInt.self, forKey: .l1BatchTxIndex)
        input = try container.decodeHex(Data.self, forKey: .input)
        gasPrice = try container.decodeHex(BigUInt.self, forKey: .gasPrice)
        type = try container.decodeHex(UInt.self, forKey: .type)
        nonce = try container.decodeHex(UInt.self, forKey: .nonce)
        blockNumber = try container.decodeHex(BigUInt.self, forKey: .blockNumber)
        to = try container.decode(String.self, forKey: .to)
        maxPriorityFeePerGas = try container.decodeHex(BigUInt.self, forKey: .maxPriorityFeePerGas)
        from = try container.decode(String.self, forKey: .from)
        gas = try container.decodeHex(BigUInt.self, forKey: .gas)
        hash = try container.decode(String.self, forKey: .hash)
        value = try container.decodeHex(BigUInt.self, forKey: .value)
        transactionIndex = try container.decodeHex(BigUInt.self, forKey: .transactionIndex)
    }
}
