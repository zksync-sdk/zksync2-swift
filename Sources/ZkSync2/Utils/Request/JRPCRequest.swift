//
//  JRPCRequest.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

extension JRPC {
    
    struct Request: Encodable {
        
        /// JSON-RPC identifier.
        let identifier: UInt64 = Counter.increment()
        
        /// JSON-RPC version. Typically `2.0`.
        let version: String = "2.0"
        
        /// JSON-RPC method.
        let method: String
        
        /// JSON-RPC parameters.
        let parameters: [Parameter]?
        
        enum CodingKeys: String, CodingKey {
            
            case identifier = "id"
            case version = "jsonrpc"
            case method
            case parameters = "params"
        }
    }
    
    struct Parameter: Encodable {
        
        enum `Type` {
            
            case bool
            case int
            case uint
            case string
            case transactionParameters
        }
        
        let type: `Type`
        
        let value: Encodable
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            switch type {
            case .bool:
                try container.encode(value as! Bool)
            case .int:
                try container.encode(value as! Int)
            case .uint:
                try container.encode(value as! UInt)
            case .string:
                try container.encode(value as! String)
            case .transactionParameters:
                try container.encode(value as! TransactionParameters)
            }
        }
    }
}
