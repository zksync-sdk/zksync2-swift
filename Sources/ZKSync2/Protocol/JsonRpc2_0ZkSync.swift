//
//  JsonRpc2_0ZkSync.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/19/22.
//

import Foundation
import web3swift
import BigInt

class JsonRpc2_0ZkSync: ZKSync {
    
    let transport: Transport
    
    init(transport: Transport) {
        self.transport = transport
    }
    
    func estimateFee(_ transaction: Transaction,
                     completion: @escaping (Result<Fee>) -> Void) {
//        transport.send(method: "zks_estimateFee",
//                       params: [transaction],
//                       completion: completion)
    }
    
    func mainContract(completion: @escaping (Result<MainContract>) -> Void) {
        transport.send(method: "zks_getMainContract",
                       params: [String](),
                       completion: completion)
    }
    
    func getL1WithdrawalTx(_ transactionHash: String,
                           completion: @escaping (Result<EthSendRawTransaction>) -> Void) {
        transport.send(method: "zks_getL1WithdrawalTx",
                       params: [transactionHash],
                       completion: completion)
    }
    
    func getAccountTransactions(_ address: String,
                                before: Int,
                                limit: Int,
                                completion: @escaping (Result<Transactions>) -> Void) {
        transport.send(method: "zks_getAccountTransactions",
                       params: [before, limit],
                       completion: completion)
    }
    
    func getConfirmedTokens(_ from: Int,
                            limit: Int,
                            completion: @escaping (Result<[Token]>) -> Void) {
        transport.send(method: "zks_getConfirmedTokens",
                       params: [from, limit],
                       completion: completion)
    }
    
    func isTokenLiquid(_ tokenAddress: String,
                       completion: @escaping (Result<Bool>) -> Void) {
        transport.send(method: "zks_isTokenLiquid",
                       params: [tokenAddress],
                       completion: completion)
    }
    
    func getTokenPrice(_ tokenAddress: String,
                       completion: @escaping (Result<Decimal>) -> Void) {
        transport.send(method: "zks_getTokenPrice",
                       params: [tokenAddress],
                       completion: { result in
            completion(result.map({ Decimal(string: $0)! }))
        })
    }
    
    func L1ChainId(completion: @escaping (Result<BigUInt>) -> Void) {
        transport.send(method: "zks_L1ChainId",
                       params: [String](),
                       completion: { (result: Result<String>) in
            completion(result.map({ BigUInt($0.stripHexPrefix(), radix: 16)! }))
        })
    }
    
    func ethGetBalance(_ address: String,
                       tokenAddress: String,
                       completion: @escaping (Result<EthGetBalance>) -> Void) {
        transport.send(method: "eth_getBalance",
                       // TODO: Add `DefaultBlockParameter`.
                       params: [address, tokenAddress],
                       completion: completion)
    }
    
    func setContractDebugInfo(_ contractAddress: String,
                              completion: @escaping (Result<SetContractDebugInfoResult>) -> Void) {
        transport.send(method: "zks_setContractDebugInfo",
                       params: [contractAddress],
                       completion: completion)
    }
    
    func contractDebugInfo(_ contractAddress: String,
                           completion: @escaping (Result<ContractDebugInfo>) -> Void) {
        transport.send(method: "zks_getContractDebugInfo",
                       // TODO: Add `ContractSourceDebugInfo`.
                       params: [contractAddress],
                       completion: completion)
    }
    
    func transactionTrace(_ transactionHash: String,
                          completion: @escaping (Result<TransactionTrace>) -> Void) {
        transport.send(method: "zks_getTransactionTrace",
                       params: [transactionHash],
                       completion: completion)
    }
    
    func allAccountBalances(_ address: String,
                            completion: @escaping (Result<AccountBalances>) -> Void) {
        transport.send(method: "zks_getAllAccountBalances",
                       params: [address],
                       completion: completion)
    }
}
