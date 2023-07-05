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
#else
import web3swift_zksync
#endif

class DefaultTransactionFeeProvider: ZkTransactionFeeProvider {
    
    var zkSync: ZkSync
    
    var feeToken: Token
    
    init(zkSync: ZkSync, feeToken: Token) {
        self.zkSync = zkSync
        self.feeToken = feeToken
    }
    
    func getFee(for transaction: EthereumTransaction) -> Promise<Fee> {
        return zkSync.zksEstimateFee(transaction)
    }
    
    func getGasLimit(for transaction: EthereumTransaction) -> Promise<BigUInt> {
        Promise { seal in
            zkSync.ethEstimateGas(transaction) {
                seal.resolve($0)
            }
        }
    }
    
    func getFeeToken() -> Token {
        return feeToken
    }
    
    var gasPrice: BigUInt {
        return try! zkSync.web3.eth.getGasPricePromise().wait()
    }
    
    var gasLimit: BigUInt {
        fatalError("Not implemented")
    }
}
