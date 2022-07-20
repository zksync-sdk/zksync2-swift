//
//  JRPCRequest.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation

extension JRPC {
    
    struct Request<T: Encodable>: Encodable {
        
        /// JSON-RPC identifier.
        let id: UInt64 = Counter.increment()
        
        /// JSON-RPC version. Typically `2.0`.
        let jsonrpc: String = "2.0"
        
        /// JSON-RPC method.
        let method: String
        
        /// JSON-RPC parameters.
        let params: T?
    }
}
