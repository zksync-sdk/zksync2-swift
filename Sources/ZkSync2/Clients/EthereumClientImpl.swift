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
        try await web3.eth.gasPrice()
    }
    
    public func suggestGasTipCap() async throws -> BigUInt {
        BigUInt(1_000_000_000)
    }
    
    public func estimateGas(_ transaction: CodableTransaction) async throws -> BigUInt {
        try await web3.eth.estimateGas(for: transaction)
    }
    
    public func maxPriorityFeePerGas() async throws -> BigUInt {
        let result: String = try await transport.send(method: "eth_maxPriorityFeePerGas", parameters: [])

        return BigUInt(from: result.stripHexPrefix())!
    }
    
    public func estimateGasL2(_ transaction: CodableTransaction) async throws -> BigUInt {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.from))
        ]

        let result: String = try await transport.send(method: "eth_estimateGas", parameters: parameters)

        return BigUInt(from: result.stripHexPrefix())!
    }
    
    public func transactionByHash(_ transactionHash: String) async throws -> TransactionResponse {
        let parameters = [
            JRPC.Parameter(type: .string, value: transactionHash),
        ]
        
        return try await transport.send(method: "eth_getTransactionByHash", parameters: parameters)
    }
    
    public func getLogs() async throws -> Log {
        try await transport.send(method: "eth_getLogs", parameters: [])
    }
    
    public func blockByHash(_ blockHash: String, fullTransactions: Bool) async throws -> Block {
        try await web3.eth.block(by: blockHash, fullTransactions: fullTransactions)
    }
    
    public func blockByNumber(_ blockNumber: BlockNumber, fullTransactions: Bool) async throws -> Block {
        try await web3.eth.block(by: blockNumber, fullTransactions: fullTransactions)
    }
    
    public func blockNumber() async throws -> BigUInt {
        try await web3.eth.blockNumber()
    }
    
    public func callContract(_ transaction: CodableTransaction, blockNumber: BigUInt? = nil) async throws -> Data {
        var transaction = transaction
        if let blockNumber = blockNumber {
            transaction.callOnBlock = .exact(blockNumber)
        }

        return try await web3.eth.callTransaction(transaction)
    }
    
    public func callContractL2(_ transaction: CodableTransaction, blockNumber: BigUInt?) async throws -> Data {
        var transaction = transaction
        if let blockNumber = blockNumber {
            transaction.callOnBlock = .exact(blockNumber)
        }

        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.from))
        ]
        
        return try await transport.send(method: "eth_call", parameters: parameters)
    }
    
    public func callContractAtHash(_ transaction: CodableTransaction, hash: String) async throws -> Data {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.from)),
            JRPC.Parameter(type: .string, value: hash)
        ]
        
        return try await transport.send(method: "eth_call", parameters: parameters)
    }
    
    public func callContractAtHashL2(_ transaction: CodableTransaction, hash: String) async throws -> Data {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.from)),
            JRPC.Parameter(type: .string, value: hash)
        ]
        
        return try await transport.send(method: "eth_call", parameters: parameters)
    }
    
    public func pendingCallContract(_ transaction: CodableTransaction) async throws -> Data {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.from)),
            JRPC.Parameter(type: .string, value: "pending")
        ]
        
        return try await transport.send(method: "eth_call", parameters: parameters)
    }
    
    public func pendingCallContractL2(_ transaction: CodableTransaction) async throws -> Data {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.from)),
            JRPC.Parameter(type: .string, value: "pending")
        ]
        
        return try await transport.send(method: "eth_call", parameters: parameters)
    }
    
    public func transactionReceipt(_ txHash: String) async throws -> TransactionReceipt {
        try await web3.eth.transactionReceipt(Data(hex: txHash))
    }
    
    public func sendTransaction(_ transaction: CodableTransaction) async throws -> TransactionSendingResult {
        try await web3.eth.send(transaction)
    }
    
    public func sendRawTransaction(_ data: Data) async throws -> TransactionSendingResult {
        try await web3.eth.send(raw: data)
    }
    
    public func chainID() async throws -> BigUInt {
        let result: String = try await transport.send(method: "eth_chainId", parameters: [])
        return BigUInt(from: result.stripHexPrefix())!
    }
    
    public func transactionSender(_ blockHash: String, index: Int) async throws -> Block {
        let parameters = [
            JRPC.Parameter(type: .string, value: blockHash),
            JRPC.Parameter(type: .int, value: index)
        ]
        
        return try await transport.send(method: "eth_getTransactionByBlockHashAndIndex", parameters: parameters)
    }
    
    public func transactionCount(address: String, blockNumber: BlockNumber) async throws -> BigUInt {
        try await web3.eth.getTransactionCount(for: EthereumAddress(address)!, onBlock: blockNumber)
    }
    
    public func transactionInBlock(_ blockHash: String,
                                  index: Int) async throws -> Block {
        let parameters = [
            JRPC.Parameter(type: .string, value: blockHash),
            JRPC.Parameter(type: .int, value: index)
        ]
        
        return try await transport.send(method: "eth_getTransactionByBlockHashAndIndex", parameters: parameters)
    }
    
    public func balance(at address: String, blockNumber: BlockNumber) async throws -> BigUInt {
        try await web3.eth.getBalance(for: EthereumAddress(address)!, onBlock: blockNumber)
    }
    
    public func code(at address: String, blockNumber: BlockNumber) async throws -> String {
        try await web3.eth.code(for: EthereumAddress(address)!, onBlock: blockNumber)
    }
}
