//
//  ZkTransactionFeeProvider.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/1/22.
//

import Foundation
import web3swift
import BigInt
import PromiseKit

protocol ZkTransactionFeeProvider: ContractGasProvider {
    
    func getFee(for transaction: EthereumTransaction) -> Promise<Fee>
    
    func getGasLimit(for transaction: EthereumTransaction) -> Promise<BigUInt>
    
    func getFeeToken() -> Token
}
