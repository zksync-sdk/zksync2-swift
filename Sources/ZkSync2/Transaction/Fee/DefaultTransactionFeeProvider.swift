//
//  DefaultTransactionFeeProvider.swift
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

class DefaultTransactionFeeProvider: ZkTransactionFeeProvider {
    
    var zkSync: ZkSync
    
    var feeToken: Token
    
    init(zkSync: ZkSync, feeToken: Token) {
        self.zkSync = zkSync
        self.feeToken = feeToken
    }
    
    func getFee(for transaction: CodableTransaction) -> Promise<Fee> {
        return zkSync.zksEstimateFee(transaction)
    }
    
    func getGasLimit(for transaction: CodableTransaction) -> Promise<BigUInt> {
        Promise { seal in
            zkSync.ethEstimateGas(transaction) {
                seal.resolve($0)
            }
        }
    }
    
    func getFeeToken() -> Token {
        return feeToken
    }
    
    func getGasPrice() async -> BigUInt {
        return try! await zkSync.web3.eth.gasPrice()
    }
    
    var gasLimit: BigUInt {
        fatalError("Not implemented")
    }
}
