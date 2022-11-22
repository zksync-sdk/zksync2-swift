//
//  DefaultTransactionFeeProvider.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/1/22.
//

import Foundation
import web3swift
import BigInt
import PromiseKit

class DefaultTransactionFeeProvider: ZkTransactionFeeProvider {
    
    var zkSync: ZkSync
    
    var feeToken: Token
    
    init(zkSync: ZkSync, feeToken: Token) {
        self.zkSync = zkSync
        self.feeToken = feeToken
    }
    
    func getFee(for transaction: EthereumTransaction) -> Promise<Fee> {
        fatalError("Implement")
    }
    
    func getGasLimit(for transaction: EthereumTransaction) -> Promise<BigUInt> {
        return zkSync.web3.eth.estimateGasPromise(transaction,
                                                  transactionOptions: nil)
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
