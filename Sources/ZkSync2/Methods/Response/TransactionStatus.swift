//
//  TransactionStatus.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 05.03.2023.
//

import Foundation

extension TransactionDetails {
    
    public enum Status: String, Decodable {
        
        case pending
        case included
        case verified
        case failed
    }
}
