//
//  EthereumTransaction.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
import web3swift

extension EthereumTransaction {
    
    static func createEtherTransaction(from: EthereumAddress,
                                       nonce: BigUInt,
                                       gasPrice: BigUInt,
                                       gasLimit: BigUInt,
                                       to: EthereumAddress,
                                       value: BigUInt,
                                       chainID: BigUInt) -> EthereumTransaction {
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip1559
        transactionOptions.from = from
        transactionOptions.to = to
        transactionOptions.nonce = .manual(nonce)
        transactionOptions.gasLimit = .manual(gasLimit)
        transactionOptions.gasPrice = .manual(gasPrice)
        transactionOptions.value = value
        transactionOptions.chainID = chainID
        
        let ethereumParameters = EthereumParameters(from: transactionOptions)
        
        return EthereumTransaction(type: .eip1559,
                                   to: to,
                                   nonce: nonce,
                                   chainID: chainID,
                                   value: value,
                                   data: Data(),
                                   parameters: ethereumParameters)
    }
}
