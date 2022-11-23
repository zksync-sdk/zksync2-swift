//
//  JsonRpc2_0ZkSync.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/19/22.
//

import Foundation
import web3swift
import BigInt

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
    
    func zksMainContract(completion: @escaping (Result<String>) -> Void) {
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
    
    func zksL1ChainId(completion: @escaping (Result<BigUInt>) -> Void) {
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
                              completion: @escaping (Result<MessageProof>) -> Void) {
        transport.send(method: "zks_getL2ToL1MsgProof",
                       params: [String(block), sender, message],
                       completion: completion)
    }
    
    func ethEstimateGas(_ transaction: EthereumTransaction,
                        completion: @escaping (Result<EthEstimateGas>) -> Void) {
        transport.send(method: "eth_estimateGas",
                       params: [String](), // TODO: Add transaction support.
                       completion: completion)
    }
    
    func zksGetTestnetPaymaster(_ completion: @escaping (Result<String>) -> Void) {
        transport.send(method: "zks_getTestnetPaymaster",
                       params: [String](),
                       completion: completion)
    }
    
    func chainId(_ completion: @escaping (Result<BigUInt>) -> Void) {
        transport.send(method: "eth_chainId",
                       params: [String](),
                       completion: { (result: Result<String>) in
            completion(result.map({ BigUInt($0.stripHexPrefix(), radix: 16)! }))
        })
    }
}
