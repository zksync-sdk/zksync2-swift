//
//  JRPCError.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation

extension JRPC {
    
    struct Error: Codable {
        
        /// Code of the error.
        let code: Int
        
        /// Error message.
        let message: String
    }
}
