//
//  BridgeAddresses.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 8/30/22.
//

import Foundation

// ZkSync2 (Java): ZksBridgeAddresses.java
struct BridgeAddresses: Decodable {
    
    var l1EthDefaultBridge: String
    var l2EthDefaultBridge: String
    var l1Erc20DefaultBridge: String
    var l2Erc20DefaultBridge: String
}
