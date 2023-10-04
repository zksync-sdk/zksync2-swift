//
//  BaseClient.swift
//  zkSync-Demo
//
//  Created by Bojan on 12.9.23..
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

public class BaseClient: ZkSyncClient {
    
    public var web3: Web3
    
    let transport: Transport
    
    public init(_ providerURL: URL) {
        self.web3 = Web3(provider: Web3HttpProvider(url: providerURL, network: .Mainnet))
        self.transport = HTTPTransport(self.web3.provider.url)
    }
    
    public func estimateFee(_ transaction: CodableTransaction) async throws -> Fee {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encode(for: .transaction))
        ]

        return try await transport.send(method: "zks_estimateFee", parameters: parameters)
    }
    
    public func estimateGasL1(_ transaction: CodableTransaction) async throws -> Fee {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encode(for: .transaction))
        ]

        return try await transport.send(method: "zks_estimateGasL1ToL2", parameters: parameters)
    }
    
    public func estimateGasTransfer(_ transaction: CodableTransaction) async throws -> BigUInt {
        try await web3.eth.estimateGas(for: transaction)
    }
    
    public func estimateGasWithdraw(_ transaction: CodableTransaction) async throws -> BigUInt {
        try await web3.eth.estimateGas(for: transaction)
    }
    
    public func mainContract() async throws -> String {
        try await transport.send(method: "zks_getMainContract", parameters: [])
    }
    
    public func tokenPrice(_ tokenAddress: String) async throws -> Decimal {
        let parameters = [
            JRPC.Parameter(type: .string, value: tokenAddress),
        ]
        
        let result: String = try await transport.send(method: "zks_getTokenPrice", parameters: parameters)
        
        return Decimal(string: result)!
    }
    
    public func L1ChainId() async throws -> BigUInt {
        let result: String = try await transport.send(method: "zks_L1ChainId", parameters: [])
        
        return BigUInt(result.stripHexPrefix(), radix: 16)!
    }
    
    public func allAccountBalances(_ address: String) async throws -> Dictionary<String, String> {
        let parameters = [
            JRPC.Parameter(type: .string, value: address)
        ]
        
        return try await transport.send(method: "zks_getAllAccountBalances", parameters: parameters)
    }
    
    public func bridgeContracts() async throws -> BridgeAddresses {
        try await transport.send(method: "zks_getBridgeContracts", parameters: [])
    }
    
    // FIXME: Should l2LogPosition be used?
    public func getL2ToL1MsgProof(_ block: Int, sender: String, message: String, l2LogPosition: Int64?) async throws -> L2ToL1MessageProof {
        let parameters = [
            JRPC.Parameter(type: .int, value: block),
            JRPC.Parameter(type: .string, value: sender),
            JRPC.Parameter(type: .string, value: message)
        ]
        
        return try await transport.send(method: "zks_getL2ToL1MsgProof", parameters: parameters)
    }
    
    public func getL2ToL1LogProof(_ txHash: String, logIndex: Int) async throws -> L2ToL1MessageProof {
        let parameters = [
            JRPC.Parameter(type: .string, value: txHash),
            JRPC.Parameter(type: .int, value: logIndex),
        ]
        
        return try await transport.send(method: "zks_getL2ToL1LogProof", parameters: parameters)
    }
    
    public func getTestnetPaymaster() async throws -> String {
        try await transport.send(method: "zks_getTestnetPaymaster", parameters: [])
    }
    
    public func transactionDetails(_ txHash: String) async throws -> TransactionDetails {
        try await web3.eth.transactionDetails(Data(hex: txHash))
    }
    
    public func blockDetails(_ block: Int) async throws -> BlockDetails {
        let parameters = [
            JRPC.Parameter(type: .int, value: block),
        ]
        
        return try await transport.send(method: "zks_getBlockDetails", parameters: parameters)
    }
    
    public func blockDetails(_ blockNumber: BigUInt, returnFullTransactionObjects: Bool) async throws -> BlockDetails {
        let parameters = [
            JRPC.Parameter(type: .string, value: blockNumber.toHexString().addHexPrefix()),
        ]
        
        return try await transport.send(method: "zks_getBlockDetails", parameters: parameters)
    }
    
    public func l1BatchNumber() async throws -> String {
        try await transport.send(method: "zks_L1BatchNumber", parameters: [])
    }
    
    public func l1BatchBlockRange(l1BatchNumber: BigUInt) async throws -> String {
        let parameters = [
            JRPC.Parameter(type: .int, value: l1BatchNumber)
        ]
        
        return try await transport.send(method: "zks_getL1BatchBlockRange", parameters: parameters)
    }
    
    public func l1BatchDetails(l1BatchNumber: BigUInt) async throws -> String {
        let parameters = [
            JRPC.Parameter(type: .int, value: l1BatchNumber)
        ]
        
        return try await transport.send(method: "zks_getL1BatchDetails", parameters: parameters)
    }
    
    public func logProof(txHash: Data, logIndex: BigUInt) async throws -> String {
        let parameters = [
            JRPC.Parameter(type: .string, value: txHash),
            JRPC.Parameter(type: .int, value: logIndex)
        ]
        
        return try await transport.send(method: "zks_getL2ToL1LogProof", parameters: parameters)
    }
    
    public func msgProof(block: BigUInt, sender: String) async throws -> String {
        let parameters = [
            JRPC.Parameter(type: .int, value: block),
            JRPC.Parameter(type: .string, value: sender)
        ]
        
        return try await transport.send(method: "zks_getL2ToL1MsgProof", parameters: parameters)
    }
    
    public func confirmedTokens(_ from: Int, limit: Int) async throws -> [Token] {
        let parameters = [
            JRPC.Parameter(type: .int, value: from),
            JRPC.Parameter(type: .int, value: limit)
        ]
        
        return try await transport.send(method: "zks_getConfirmedTokens", parameters: parameters)
    }
}
