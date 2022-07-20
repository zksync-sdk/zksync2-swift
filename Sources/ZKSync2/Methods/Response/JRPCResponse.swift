//
//  JRPCResponse.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation

struct JRPC {
    
    struct Response<T: Decodable>: Decodable {
        
        /// JSON-RPC identifier.
        let id: Int
        
        /// JSON-RPC version. Typically `2.0`.
        let jsonrpc: String
        
        /// JSON-RPC result (if present).
        let result: T?
        
        /// Error (if present).
        let error: Error?
    }
}
