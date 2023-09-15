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
    
    public func suggestGasPrice(completion: @escaping (Result<BigUInt>) -> Void) {
//444        do {
//            let gasPrice = try web3.eth.getGasPrice()
//
//            completion(.success(gasPrice))
//        } catch {
//            completion(.failure(error))
//        }
    }
    
    public func suggestGasTipCap(completion: @escaping (Result<BigUInt>) -> Void) {
        completion(.success(BigUInt(1_000_000_000)))
    }
    
    public func estimateGas(_ transaction: CodableTransaction,
                            completion: @escaping (Result<BigUInt>) -> Void) {
//444        let parameters = [
//            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.parameters.from))
//        ]
//
//        transport.send(method: "eth_estimateGas",
//                       parameters: parameters,
//                       completion: { (result: Result<String>) in
//            completion(result.map({ BigUInt($0.stripHexPrefix(), radix: 16)! }))
//        })
    }
    
    public func estimateGasL2(_ transaction: CodableTransaction, completion: @escaping (Result<BigUInt>) -> Void) {
//444        let parameters = [
//            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.parameters.from))
//        ]
//
//        transport.send(method: "eth_estimateGas",
//                       parameters: parameters,
//                       completion: { (result: Result<String>) in
//            completion(result.map({ BigUInt($0.stripHexPrefix(), radix: 16)! }))
//        })
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
//444        do {
//            let blockNumber = try web3.eth.getBlockNumber()
//
//            completion(.success(blockNumber))
//        } catch {
//            completion(.failure(error))
//        }
    }
    
    public func peerCount(completion: @escaping (Result<BigUInt>) -> Void) {
//444        do {
//            let blockNumber = try web3.eth.getPeerCount()
//
//            completion(.success(blockNumber))
//        } catch {
//            completion(.failure(error))
//        }
    }
    
    public func callContract(_ transaction: CodableTransaction, blockNumber: BigUInt? = nil, completion: @escaping (Result<Data>) -> Void) {
//444        var transactionOptions = TransactionOptions.defaultOptions
//        if let blockNumber = blockNumber {
//            transactionOptions.callOnBlock = .exactBlockNumber(blockNumber)
//        }
//
//        do {
//            let data = try web3.eth.callPromise(transaction, transactionOptions: transactionOptions).wait()
//
//            completion(.success(data))
//        } catch {
//            completion(.failure(error))
//        }
    }
    
    public func callContractL2(_ transaction: CodableTransaction, blockNumber: BigUInt?, completion: @escaping (Result<Data>) -> Void) {
//444        var transactionOptions = TransactionOptions.defaultOptions
//        if let blockNumber = blockNumber {
//            transactionOptions.callOnBlock = .exactBlockNumber(blockNumber)
//        }
//
//        do {
//            let data = try web3.eth.callPromise(transaction, transactionOptions: transactionOptions).wait()
//
//            completion(.success(data))
//        } catch {
//            completion(.failure(error))
//        }
    }
    
    public func callContractAtHash(_ transaction: CodableTransaction, hash: String, completion: @escaping (Result<Data>) -> Void) {
//444        var transactionOptions = TransactionOptions.defaultOptions
//
//        do {
//            let data = try web3.eth.callPromise(transaction, transactionOptions: transactionOptions).wait()
//
//            completion(.success(data))
//        } catch {
//            completion(.failure(error))
//        }
    }
    
    public func callContractAtHashL2(_ transaction: CodableTransaction, hash: String, completion: @escaping (Result<Data>) -> Void) {
//444        var transactionOptions = TransactionOptions.defaultOptions
//
//        do {
//            let data = try web3.eth.callPromise(transaction, transactionOptions: transactionOptions).wait()
//
//            completion(.success(data))
//        } catch {
//            completion(.failure(error))
//        }
    }
    
    public func pendingCallContract(_ transaction: CodableTransaction, hash: String, completion: @escaping (Result<Data>) -> Void) {
//444        var transactionOptions = TransactionOptions.defaultOptions
//        transactionOptions.callOnBlock = .pending
//
//        do {
//            let data = try web3.eth.callPromise(transaction, transactionOptions: transactionOptions).wait()
//
//            completion(.success(data))
//        } catch {
//            completion(.failure(error))
//        }
    }
    
    public func pendingCallContractL2(_ transaction: CodableTransaction, hash: String, completion: @escaping (Result<Data>) -> Void) {
//444        var transactionOptions = TransactionOptions.defaultOptions
//        transactionOptions.callOnBlock = .pending
//
//        do {
//            let data = try web3.eth.callPromise(transaction, transactionOptions: transactionOptions).wait()
//
//            completion(.success(data))
//        } catch {
//            completion(.failure(error))
//        }
    }
    
    public func transactionReceipt(_ txHash: String, completion: @escaping (Result<TransactionReceipt>) -> Void) {
//444        do {
//            let transactionReceipt = try web3.eth.getTransactionReceipt(txHash)
//
//            completion(.success(transactionReceipt))
//        } catch {
//            completion(.failure(error))
//        }
    }
    
    public func sendTransaction(_ transaction: CodableTransaction, completion: @escaping (Result<TransactionSendingResult>) -> Void) {
//444        do {
//            let result = try web3.eth.sendTransaction(transaction, transactionOptions: transactionOptions)
//
//            completion(.success(result))
//        } catch {
//            completion(.failure(error))
//        }
    }
    
    public func sendRawTransaction(transaction: Data, completion: @escaping (Result<TransactionSendingResult>) -> Void) {
//444        do {
//            let result = try web3.eth.sendRawTransaction(transaction)
//
//            completion(.success(result))
//        } catch {
//            completion(.failure(error))
//        }
    }
    
    public func chainID() -> Promise<BigUInt> {
        //444web3.eth.getChainIdPromise()
        Promise<BigUInt> { result in
            result.fulfill(.zero)
        }//444
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
    
    public func transactionCount(address: String, blockHash: String) throws -> BigUInt {
        return .zero//444 try web3.eth.getTransactionCount(address: EthereumAddress(address)!, onBlock: blockHash)
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
    
    public func balanceAt(address: String, blockHash: String) throws -> BigUInt {
        return .zero//444 try web3.eth.getBalance(address: EthereumAddress(address)!, onBlock: blockHash)
    }
    
    public func codeAt(address: String, blockHash: String) throws -> String {
        return ""//444 try web3.eth.getCodePromise(address: EthereumAddress(address)!, onBlock: blockHash).wait()
    }
}
