//
//  EthereumClient.swift
//  zkSync-Demo
//
//  Created by Bojan on 1.9.23..
//

import Foundation
import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

public typealias Result<T> = Swift.Result<T, Error>

public protocol EthereumClient {
    var web3: web3 { get set }
    
    func estimateGas(_ transaction: EthereumTransaction, completion: @escaping (Result<BigUInt>) -> Void)
    
    func getTransactionByHash(_ transactionHash: String, completion: @escaping (Result<TransactionResponse>) -> Void)
    
    func getLogs(_ completion: @escaping (Result<Log>) -> Void)
    
    func getBlockByHash(_ blockHash: String, returnFullTransactionObjects: Bool, completion: @escaping (Result<Block>) -> Void)
    
    func getBlockByNumber(_ block: DefaultBlockParameterName, returnFullTransactionObjects: Bool, completion: @escaping (Result<Block>) -> Void)
}
