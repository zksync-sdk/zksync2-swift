//
//  ZkTransactionFeeProvider.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/1/22.
//

import Foundation
import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

public protocol ZkTransactionFeeProvider: ContractGasProvider {
    
    func getFee(for transaction: CodableTransaction) -> Promise<Fee>
    
    func getGasLimit(for transaction: CodableTransaction) -> Promise<BigUInt>
    
    func getFeeToken() -> Token
}