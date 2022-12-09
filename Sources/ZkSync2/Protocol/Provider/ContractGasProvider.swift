//
//  ContractGasProvider.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/1/22.
//

import Foundation
import BigInt

protocol ContractGasProvider {
    
    var gasPrice: BigUInt { get }
    
    var gasLimit: BigUInt { get }
}

struct DefaultGasProvider: ContractGasProvider {
    
    var gasPrice = BigUInt(4_100_000_000)
    
    var gasLimit = BigUInt(9_000_000)
}

struct StaticGasProvider: ContractGasProvider {
    
    var gasPrice: BigUInt
    
    var gasLimit: BigUInt
}
