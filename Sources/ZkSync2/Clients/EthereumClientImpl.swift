//
//  EthereumClientImpl.swift
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

public class EthereumClientImpl: EthereumClient {
    public var web3: web3
    
    let transport: Transport
    
    public init(_ providerURL: URL) {
        self.web3 = try! Web3.new(providerURL)
        self.transport = HTTPTransport(self.web3.provider.url)
    }
    
    public func estimateGas(_ transaction: EthereumTransaction,
                            completion: @escaping (Result<BigUInt>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.parameters.from))
        ]
        
        transport.send(method: "eth_estimateGas",
                       parameters: parameters,
                       completion: { (result: Result<String>) in
            completion(result.map({ BigUInt($0.stripHexPrefix(), radix: 16)! }))
        })
    }
    
    public func transactionByHash(_ transactionHash: String,
                                     completion: @escaping (Result<TransactionResponse>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .string, value: transactionHash),
        ]
        
        transport.send(method: "eth_getTransactionByHash",
                       parameters: parameters,
                       completion: completion)
    }
    
    public func getLogs(_ completion: @escaping (Result<Log>) -> Void) {
        transport.send(method: "eth_getLogs",
                       parameters: [],
                       completion: completion)
    }
    
    public func blockByHash(_ blockHash: String,
                               returnFullTransactionObjects: Bool,
                               completion: @escaping (Result<Block>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .string, value: blockHash),
            JRPC.Parameter(type: .bool, value: returnFullTransactionObjects)
        ]
        
        transport.send(method: "eth_getBlockByHash",
                       parameters: parameters,
                       completion: completion)
    }
    
    public func blockByNumber(_ block: DefaultBlockParameterName,
                                 returnFullTransactionObjects: Bool,
                                 completion: @escaping (Result<Block>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .string, value: block.rawValue),
            JRPC.Parameter(type: .bool, value: true)
        ]
        
        transport.send(method: "eth_getBlockByNumber",
                       parameters: parameters,
                       completion: completion)
    }
    
    public func blockNumber(completion: @escaping (Result<BigUInt>) -> Void) {
        do {
            let blockNumber = try web3.eth.getBlockNumber()
            
            completion(.success(blockNumber))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func peerCount(completion: @escaping (Result<BigUInt>) -> Void) {
        do {
            let blockNumber = try web3.eth.getPeerCount()
            
            completion(.success(blockNumber))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func callContract(_ transaction: EthereumTransaction, blockNumber: BigUInt? = nil, completion: @escaping (Result<Data>) -> Void) {
        var transactionOptions = TransactionOptions.defaultOptions
        if let blockNumber = blockNumber {
            transactionOptions.callOnBlock = .exactBlockNumber(blockNumber)
        }
        
        do {
            let data = try web3.eth.callPromise(transaction, transactionOptions: transactionOptions).wait()
            
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func callContractL2(_ transaction: EthereumTransaction, blockNumber: BigUInt?, completion: @escaping (Result<Data>) -> Void) {
        var transactionOptions = TransactionOptions.defaultOptions
        if let blockNumber = blockNumber {
            transactionOptions.callOnBlock = .exactBlockNumber(blockNumber)
        }
        
        do {
            let data = try web3.eth.callPromise(transaction, transactionOptions: transactionOptions).wait()
            
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
}
