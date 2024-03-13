////
////  ZkSyncImpl.swift
////  ZkSync2
////
////  Created by Maxim Makhun on 7/19/22.
////
//
//import Foundation
//import BigInt
//import PromiseKit
//#if canImport(web3swift)
//import web3swift
//import Web3Core
//#else
//import web3swift_zksync2
//#endif
//
//public class ZkSyncImpl: ZkSync {
//    
//    public var web3: Web3
//    
//    let transport: Transport
//    
//    public init(_ providerURL: URL) {
//        self.web3 = Web3(provider: Web3HttpProvider(url: providerURL, network: .Mainnet))
//        self.transport = HTTPTransport(self.web3.provider.url)
//    }
//    
//    public func zksEstimateFee(_ transaction: CodableTransaction,
//                        completion: @escaping (Result<Fee>) -> Void) {
//        let parameters: [JRPC.Parameter] = [
//            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.from))
//        ]
//        
//        transport.send(method: "zks_estimateFee",
//                       parameters: parameters,
//                       completion: completion)
//    }
//    
//    public func zksEstimateFeePromise(_ transaction: CodableTransaction) -> Promise<Fee> {
//        Promise { seal in
//            zksEstimateFee(transaction) { fee in
//                seal.resolve(fee)
//            }
//        }
//    }
//    
//    public func zksMainContract(_ completion: @escaping (Result<String>) -> Void) {
//        transport.send(method: "zks_getMainContract",
//                       parameters: [],
//                       completion: completion)
//    }
//    
//    public func zksGetConfirmedTokens(_ from: Int,
//                               limit: Int,
//                               completion: @escaping (Result<[Token]>) -> Void) {
//        let parameters = [
//            JRPC.Parameter(type: .int, value: from),
//            JRPC.Parameter(type: .int, value: limit)
//        ]
//        
//        transport.send(method: "zks_getConfirmedTokens",
//                       parameters: parameters,
//                       completion: completion)
//    }
//    
//    public func zksGetTokenPrice(_ tokenAddress: String,
//                          completion: @escaping (Result<Decimal>) -> Void) {
//        let parameters = [
//            JRPC.Parameter(type: .string, value: tokenAddress),
//        ]
//        
//        transport.send(method: "zks_getTokenPrice",
//                       parameters: parameters,
//                       completion: { result in
//            completion(result.map({ Decimal(string: $0)! }))
//        })
//    }
//    
//    public func zksL1ChainId(_ completion: @escaping (Result<BigUInt>) -> Void) {
//        transport.send(method: "zks_L1ChainId",
//                       parameters: [],
//                       completion: { (result: Result<String>) in
//            completion(result.map({ BigUInt($0.stripHexPrefix(), radix: 16)! }))
//        })
//    }
//    
//    public func zksGetAllAccountBalances(_ address: String,
//                                  completion: @escaping (Result<Dictionary<String, String>>) -> Void) {
//        let parameters = [
//            JRPC.Parameter(type: .string, value: address)
//        ]
//        
//        transport.send(method: "zks_getAllAccountBalances",
//                       parameters: parameters,
//                       completion: completion)
//    }
//    
//    // TODO: implement l1 for l2 and l2 for l1
//    
//    public func zksGetBridgeContracts(_ completion: @escaping (Result<BridgeAddresses>) -> Void) {
//        transport.send(method: "zks_getBridgeContracts",
//                       parameters: [],
//                       completion: completion)
//    }
//    
//    public func zksGetL2ToL1MsgProof(_ block: Int,
//                              sender: String,
//                              message: String,
//                              l2LogPosition: Int64?, // FIXME: Should l2LogPosition be used?
//                              completion: @escaping (Result<L2ToL1MessageProof>) -> Void) {
//        let parameters = [
//            JRPC.Parameter(type: .int, value: block),
//            JRPC.Parameter(type: .string, value: sender),
//            JRPC.Parameter(type: .string, value: message)
//        ]
//        
//        transport.send(method: "zks_getL2ToL1MsgProof",
//                       parameters: parameters,
//                       completion: completion)
//    }
//    
//    public func zksGetL2ToL1LogProof(_ txHash: String,
//                              logIndex: Int,
//                              completion: @escaping (Result<L2ToL1MessageProof>) -> Void) {
//        let parameters = [
//            JRPC.Parameter(type: .string, value: txHash),
//            JRPC.Parameter(type: .int, value: logIndex),
//        ]
//        
//        transport.send(method: "zks_getL2ToL1LogProof",
//                       parameters: parameters,
//                       completion: completion)
//    }
//    
//    public func ethEstimateGas(_ transaction: CodableTransaction,
//                        completion: @escaping (Result<BigUInt>) -> Void) {
//        let parameters = [
//            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.from))
//        ]
//
//        transport.send(method: "eth_estimateGas",
//                       parameters: parameters,
//                       completion: { (result: Result<String>) in
//            completion(result.map({ BigUInt($0.stripHexPrefix(), radix: 16)! }))
//        })
//    }
//    
//    public func zksGetTestnetPaymaster(_ completion: @escaping (Result<String>) -> Void) {
//        transport.send(method: "zks_getTestnetPaymaster",
//                       parameters: [],
//                       completion: completion)
//    }
//    
//    public func zksGetTransactionDetails(_ transactionHash: String,
//                                  completion: @escaping (Result<TransactionDetails>) -> Void) {
//        let parameters = [
//            JRPC.Parameter(type: .string, value: transactionHash),
//        ]
//        
//        transport.send(method: "zks_getTransactionDetails",
//                       parameters: parameters,
//                       completion: completion)
//    }
//    
//    func zksGetBlockDetails(_ block: Int,
//                            completion: @escaping (Result<BlockDetails>) -> Void) {
//        let parameters = [
//            JRPC.Parameter(type: .int, value: block),
//        ]
//        
//        transport.send(method: "zks_getBlockDetails",
//                       parameters: parameters,
//                       completion: completion)
//    }
//    
//    public func zksGetTransactionByHash(_ transactionHash: String,
//                                 completion: @escaping (Result<TransactionResponse>) -> Void) {
//        let parameters = [
//            JRPC.Parameter(type: .string, value: transactionHash),
//        ]
//        
//        transport.send(method: "eth_getTransactionByHash",
//                       parameters: parameters,
//                       completion: completion)
//    }
//    
//    public func zksGetLogs(_ completion: @escaping (Result<Log>) -> Void) {
//        transport.send(method: "eth_getLogs",
//                       parameters: [],
//                       completion: completion)
//    }
//    
//    public func zksGetBlockByHash(_ blockHash: String,
//                           returnFullTransactionObjects: Bool,
//                           completion: @escaping (Result<Block>) -> Void) {
//        let parameters = [
//            JRPC.Parameter(type: .string, value: blockHash),
//            JRPC.Parameter(type: .bool, value: returnFullTransactionObjects)
//        ]
//        
//        transport.send(method: "eth_getBlockByHash",
//                       parameters: parameters,
//                       completion: completion)
//    }
//    
//    public func zksGetBlockByNumber(_ block: DefaultBlockParameterName,
//                             returnFullTransactionObjects: Bool,
//                             completion: @escaping (Result<Block>) -> Void) {
//        let parameters = [
//            JRPC.Parameter(type: .string, value: block.rawValue),
//            JRPC.Parameter(type: .bool, value: true)
//        ]
//        
//        transport.send(method: "eth_getBlockByNumber",
//                       parameters: parameters,
//                       completion: completion)
//    }
//    
//    public func zksGetBlockDetails(_ blockNumber: BigUInt,
//                            returnFullTransactionObjects: Bool,
//                            completion: @escaping (Result<BlockDetails>) -> Void) {
//        let parameters = [
//            JRPC.Parameter(type: .string, value: blockNumber.toHexString().addHexPrefix()),
//        ]
//        
//        transport.send(method: "zks_getBlockDetails",
//                       parameters: parameters,
//                       completion: completion)
//    }
//}
