//
//  DefaultEthereumProvider.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import web3swift

public class DefaultEthereumProvider: EthereumProvider {
    
    let web3: web3
    
    init(web3: web3) {
        self.web3 = web3
    }
}
