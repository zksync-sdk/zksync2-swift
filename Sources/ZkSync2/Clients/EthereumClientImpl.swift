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
import Web3Core
#else
import web3swift_zksync2
#endif

public class EthereumClientImpl: EthereumClient {
    public var web3: Web3
    
    let transport: Transport
    
    public init(_ providerURL: URL) {
        self.web3 = Web3(provider: Web3HttpProvider(url: providerURL, network: .Mainnet))
        self.transport = HTTPTransport(self.web3.provider.url)
    }
    
    public func suggestGasPrice() async throws -> BigUInt {
        return try await web3.eth.gasPrice()
    }
    
    public func suggestGasTipCap(completion: @escaping (Result<BigUInt>) -> Void) {
        completion(.success(BigUInt(1_000_000_000)))
    }
    
    public func estimateGas(_ transaction: CodableTransaction,
                            completion: @escaping (Result<BigUInt>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encode(for: .transaction))
        ]

        transport.send(method: "eth_estimateGas",
                       parameters: parameters,
                       completion: { (result: Result<String>) in
            completion(result.map({ BigUInt($0.stripHexPrefix(), radix: 16)! }))
        })
    }
    
    public func estimateGasL2(_ transaction: CodableTransaction, completion: @escaping (Result<BigUInt>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encode(for: .transaction))
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
    
    public func blockNumber() async throws -> BigUInt {
        return try await web3.eth.blockNumber()
    }
    
    public func callContract(_ transaction: CodableTransaction, blockNumber: BigUInt? = nil, completion: @escaping (Result<Data>) -> Void) async {
        var transaction = transaction
        if let blockNumber = blockNumber {
            transaction.callOnBlock = .exact(blockNumber)
        }

        do {
            let data = try await web3.eth.callTransaction(transaction)

            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func callContractL2(_ transaction: CodableTransaction, blockNumber: BigUInt?, completion: @escaping (Result<Data>) -> Void) {
        var transaction = transaction
        if let blockNumber = blockNumber {
            transaction.callOnBlock = .exact(blockNumber)
        }

        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encode(for: .transaction))
        ]
        
        transport.send(method: "eth_call",
                       parameters: parameters,
                       completion: { (result: Result<Data>) in
            completion(result)
        })
    }
    
    public func callContractAtHash(_ transaction: CodableTransaction, hash: String, completion: @escaping (Result<Data>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encode(for: .transaction)),
            JRPC.Parameter(type: .string, value: hash)
        ]
        
        transport.send(method: "eth_call",
                       parameters: parameters,
                       completion: { (result: Result<Data>) in
            completion(result)
        })
    }
    
    public func callContractAtHashL2(_ transaction: CodableTransaction, hash: String, completion: @escaping (Result<Data>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encode(for: .transaction)),
            JRPC.Parameter(type: .string, value: hash)
        ]
        
        transport.send(method: "eth_call",
                       parameters: parameters,
                       completion: { (result: Result<Data>) in
            completion(result)
        })
    }
    
    public func pendingCallContract(_ transaction: CodableTransaction, completion: @escaping (Result<Data>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encode(for: .transaction)),
            JRPC.Parameter(type: .string, value: "pending")
        ]
        
        transport.send(method: "eth_call",
                       parameters: parameters,
                       completion: { (result: Result<Data>) in
            completion(result)
        })
    }
    
    public func pendingCallContractL2(_ transaction: CodableTransaction, completion: @escaping (Result<Data>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encode(for: .transaction)),
            JRPC.Parameter(type: .string, value: "pending")
        ]
        
        transport.send(method: "eth_call",
                       parameters: parameters,
                       completion: { (result: Result<Data>) in
            completion(result)
        })
    }
    
    public func transactionReceipt(_ txHash: String, completion: @escaping (Result<TransactionReceipt>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .string, value: txHash)
        ]
        
        transport.send(method: "eth_getTransactionReceipt",
                       parameters: parameters,
                       completion: { (result: Result<TransactionReceipt>) in
            completion(result)
        })
    }
    
    public func sendTransaction(_ transaction: CodableTransaction, completion: @escaping (Result<TransactionSendingResult>) -> Void) {
        Task {
            do {
                let transactionSendingResult = try await web3.eth.send(transaction)
                
                completion(.success(transactionSendingResult))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func sendRawTransaction(transaction: Data, completion: @escaping (Result<TransactionSendingResult>) -> Void) {
        Task {
            do {
                let transactionSendingResult = try await web3.eth.send(raw: transaction)
                
                completion(.success(transactionSendingResult))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func chainID(completion: @escaping (Result<BigUInt>) -> Void) {
        transport.send(method: "eth_chainId",
                       parameters: [],
                       completion: { (result: Result<BigUInt>) in
            completion(result)
        })
    }
    
    public func transactionSender(_ blockHash: String,
                            index: Int,
                            completion: @escaping (Result<Block>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .string, value: blockHash),
            JRPC.Parameter(type: .int, value: index)
        ]
        
        transport.send(method: "eth_getTransactionByBlockHashAndIndex",
                       parameters: parameters,
                       completion: completion)
    }
    
    public func transactionCount(address: String, blockNumber: BlockNumber) async throws -> BigUInt {
        try await web3.eth.getTransactionCount(for: EthereumAddress(address)!, onBlock: blockNumber)
    }
    
    public func transactionInBlock(_ blockHash: String,
                                  index: Int,
                                  completion: @escaping (Result<Block>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .string, value: blockHash),
            JRPC.Parameter(type: .int, value: index)
        ]
        
        transport.send(method: "eth_getTransactionByBlockHashAndIndex",
                       parameters: parameters,
                       completion: completion)
    }
    
    public func balanceAt(address: String, blockNumber: BlockNumber) async throws -> BigUInt {
        try await web3.eth.getBalance(for: EthereumAddress(address)!, onBlock: blockNumber)
    }
    
    public func codeAt(address: String, blockNumber: BlockNumber) async throws -> String {
        try await web3.eth.code(for: EthereumAddress(address)!, onBlock: blockNumber)
    }
}
