//
//  ZkBlockParameterName.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 8/29/22.
//

import Foundation

enum DefaultBlockParameterName: String {
    
    case earliest = "earliest"
    case latest = "latest"
    case pending = "pending"
}

enum ZkBlockParameterName: String {
    
    case committed = "commited"
    case finalized = "finalized"
}
