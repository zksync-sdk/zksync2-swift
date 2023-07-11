//
//  ContractGasProvider.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/1/22.
//

import Foundation
import BigInt

public protocol ContractGasProvider {
    
    func getGasPrice() async -> BigUInt
    
    var gasLimit: BigUInt { get }
}

public struct DefaultGasProvider: ContractGasProvider {
    
    public var gasPrice: BigUInt
    
    public var gasLimit: BigUInt
    
    public init(gasPrice: BigUInt = BigUInt(4_100_000_000), gasLimit: BigUInt = BigUInt(9_000_000)) {
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
    }
    
    public func getGasPrice() async -> BigUInt {
        return gasPrice
    }
}

struct StaticGasProvider: ContractGasProvider {
    
    var gasPrice: BigUInt
    
    var gasLimit: BigUInt
    
    func getGasPrice() async -> BigUInt {
        return gasPrice
    }
}
