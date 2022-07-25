//
//  JsonRpc2_0ZkSync.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/19/22.
//

import Foundation
import web3swift

class JsonRpc2_0ZkSync: ZKSync {
    
    let web3: web3
    
    init(_ web3: web3) {
        self.web3 = web3
    }
}
