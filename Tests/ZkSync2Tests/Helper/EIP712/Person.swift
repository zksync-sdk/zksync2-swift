//
//  Person.swift
//  ZkSync2Tests
//
//  Created by Maxim Makhun on 8/31/22.
//

import Foundation
import web3swift
import Web3Core
@testable import ZkSync2

struct Person: Structurable {
    
    var name: String
    
    var wallet: EthereumAddress
    
    init(name: String, wallet: String) {
        self.name = name
        self.wallet = EthereumAddress(wallet)!
    }
    
    func getTypeName() -> String {
        "Person"
    }
    
    func eip712types() -> [ZkSync2.EIP712.`Type`] {
        [
            ("name", value: name),
            ("wallet", value: wallet)
        ]
    }
}
