//
//  ZkBlockParameterName.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 8/29/22.
//

import Foundation

public enum DefaultBlockParameterName: String {
    
    case earliest = "earliest"
    case latest = "latest"
    case pending = "pending"
    case finalized = "finalized"
    case safe = "safe"
    case accepted = "accepted"
}

public enum ZkBlockParameterName: String {
    
    case committed = "committed"
    case finalized = "finalized"
}
