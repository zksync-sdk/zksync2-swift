//
//  JsonRpc2_0ZkSync.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/19/22.
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync
#endif

class JsonRpc2_0ZkSync: ZkSync {
    
    var web3: web3
    
    let transport: Transport
    
    init(_ providerURL: URL) {
        self.web3 = try! Web3.new(providerURL)
        self.transport = HTTPTransport(self.web3.provider.url)
    }
    
    func zksEstimateFee(_ transaction: EthereumTransaction,
                        completion: @escaping (Result<Fee>) -> Void) {
        transport.send(method: "zks_estimateFee",
                       params: [transaction.encodeAsDictionary()],
                       completion: completion)
    }
    
    func zksMainContract(_ completion: @escaping (Result<String>) -> Void) {
        transport.send(method: "zks_getMainContract",
                       params: [String](),
                       completion: completion)
    }
    
    func zksGetConfirmedTokens(_ from: Int,
                               limit: Int,
                               completion: @escaping (Result<[Token]>) -> Void) {
        transport.send(method: "zks_getConfirmedTokens",
                       params: [from, limit],
                       completion: completion)
    }
    
    func zksGetTokenPrice(_ tokenAddress: String,
                          completion: @escaping (Result<Decimal>) -> Void) {
        transport.send(method: "zks_getTokenPrice",
                       params: [tokenAddress],
                       completion: { result in
            completion(result.map({ Decimal(string: $0)! }))
        })
    }
    
    func zksL1ChainId(_ completion: @escaping (Result<BigUInt>) -> Void) {
        transport.send(method: "zks_L1ChainId",
                       params: [String](),
                       completion: { (result: Result<String>) in
            completion(result.map({ BigUInt($0.stripHexPrefix(), radix: 16)! }))
        })
    }
    
    func zksGetAllAccountBalances(_ address: String,
                                  completion: @escaping (Result<Dictionary<String, String>>) -> Void) {
        transport.send(method: "zks_getAllAccountBalances",
                       params: [address],
                       completion: completion)
    }
    
    func zksGetBridgeContracts(_ completion: @escaping (Result<BridgeAddresses>) -> Void) {
        transport.send(method: "zks_getBridgeContracts",
                       params: [String](),
                       completion: completion)
    }
    
    func zksGetL2ToL1MsgProof(_ block: Int,
                              sender: String,
                              message: String,
                              l2LogPosition: Int64?, // FIXME: Should l2LogPosition be used?
                              completion: @escaping (Result<L2ToL1MessageProof>) -> Void) {
        transport.send(method: "zks_getL2ToL1MsgProof",
                       params: [String(block), sender, message],
                       completion: completion)
    }
    
    func zksGetL2ToL1LogProof(_ txHash: String,
                              logIndex: Int,
                              completion: @escaping (Result<L2ToL1MessageProof>) -> Void) {
        transport.send(method: "zks_getL2ToL1LogProof",
                       params: [txHash, String(logIndex)],
                       completion: completion)
    }
    
    func ethEstimateGas(_ transaction: EthereumTransaction,
                        completion: @escaping (Result<BigUInt>) -> Void) {
        transport.send(method: "eth_estimateGas",
                       params: [transaction.encodeAsDictionary()],
                       completion: { (result: Result<String>) in
            completion(result.map({ BigUInt($0.stripHexPrefix(), radix: 16)! }))
        })
    }
    
    func zksGetTestnetPaymaster(_ completion: @escaping (Result<String>) -> Void) {
        transport.send(method: "zks_getTestnetPaymaster",
                       params: [String](),
                       completion: completion)
    }
    
    func zksGetTransactionDetails(_ transactionHash: String,
                                  completion: @escaping (Result<TransactionDetails>) -> Void) {
        transport.send(method: "zks_getTransactionDetails",
                       params: [transactionHash],
                       completion: completion)
    }
    
    func zksGetBlockDetails(_ block: Int,
                            completion: @escaping (Result<BlockDetails>) -> Void) {
        transport.send(method: "zks_getBlockDetails",
                       params: [String(block)],
                       completion: completion)
    }
    
    func zksGetTransactionByHash(_ transactionHash: String,
                                 completion: @escaping (Result<TransactionResponse>) -> Void) {
        transport.send(method: "eth_getTransactionByHash",
                       params: [transactionHash],
                       completion: completion)
    }
    
    func zksGetBlockByHash(_ blockHash: String,
                           returnFullTransactionObjects: Bool,
                           completion: @escaping (Result<BlockDetails>) -> Void) {
        transport.send(method: "eth_getBlockByHash",
                       params: [blockHash],
                       completion: completion)
    }
    
    func zksGetBlockByNumber(_ blockNumber: UInt,
                             returnFullTransactionObjects: Bool,
                             completion: @escaping (Result<BlockDetails>) -> Void) {
        transport.send(method: "eth_getBlockByNumber",
                       params: [String(blockNumber)],
                       completion: completion)
    }
}
