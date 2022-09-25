//
//  Person.swift
//  ZKSync2Tests
//
//  Created by Maxim Makhun on 8/31/22.
//

import Foundation
import web3swift
@testable import ZKSync2

struct Person: Structurable {
    
    var name: String
    
    var wallet: EthereumAddress
    
    init(name: String, wallet: String) {
        self.name = name
        self.wallet = EthereumAddress(wallet)!
    }
}
