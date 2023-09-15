//
//  ZkSyncClientImpl.swift
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

public class ZkSyncClientImpl: ZkSyncClient {
    
    public var web3: Web3
    
    let transport: Transport
    
    public init(_ providerURL: URL) {
        self.web3 = Web3(provider: Web3HttpProvider(url: providerURL, network: .Mainnet))
        self.transport = HTTPTransport(self.web3.provider.url)
    }
    
    public func estimateFee(_ transaction: CodableTransaction) async throws -> Fee {
        await withCheckedContinuation { continuation in
            estimateFee(transaction) { result in
                switch result {
                case .success(let fee):
                    continuation.resume(with: .success(fee))
                case .failure(let error):
                    continuation.resume(with: .failure(error as! Never))//444
                }
            }
        }
    }
    
    public func estimateFee(_ transaction: CodableTransaction, completion: @escaping (Result<Fee>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encode(for: .transaction))
        ]

        transport.send(
            method: "zks_estimateFee",
            parameters: parameters,
            completion: completion
        )
    }
    
    public func estimateGasL1(_ transaction: CodableTransaction,
                            completion: @escaping (Result<Fee>) -> Void) {
//444        let parameters = [
//            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.parameters.from))
//        ]
//
//        transport.send(
//            method: "zks_estimateGasL1ToL2",
//            parameters: parameters,
//            completion: completion
//        )
    }
    
    public func estimateGasL1(_ transaction: CodableTransaction) -> Promise<Fee> {
        Promise { seal in
            estimateGasL1(transaction) { fee in
                seal.resolve(fee)
            }
        }
    }
    
    public func estimateGasTransfer(_ transaction: CodableTransaction) -> Promise<BigUInt> {
        //444return web3.eth.estimateGasPromise(transaction, transactionOptions: TransactionOptions.defaultOptions)
        Promise<BigUInt> { result in
            result.fulfill(.zero)
        }//444
    }
    
    public func estimateGasWithdraw(_ transaction: CodableTransaction) -> Promise<BigUInt> {
        //444return web3.eth.estimateGasPromise(transaction, transactionOptions: TransactionOptions.defaultOptions)
        Promise<BigUInt> { result in
            result.fulfill(.zero)
        }//444
    }
    
    public func estimateL1ToL2Execute(_ transaction: CodableTransaction) -> Promise<BigUInt> {
        //444return web3.eth.estimateGasPromise(transaction, transactionOptions: TransactionOptions.defaultOptions)
        Promise<BigUInt> { result in
            result.fulfill(.zero)
        }//444
    }
    
    public func mainContract(_ completion: @escaping (Result<String>) -> Void) {
        transport.send(
            method: "zks_getMainContract",
            parameters: [],
            completion: completion
        )
    }
    
    public func tokenPrice(_ tokenAddress: String,
                          completion: @escaping (Result<Decimal>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .string, value: tokenAddress),
        ]
        
        transport.send(
            method: "zks_getTokenPrice",
            parameters: parameters,
            completion: { result in
                completion(result.map({ Decimal(string: $0)! }))
            }
        )
    }
    
    public func L1ChainId(_ completion: @escaping (Result<BigUInt>) -> Void) {
        transport.send(
            method: "zks_L1ChainId",
            parameters: [],
            completion: { (result: Result<String>) in
                completion(result.map({ BigUInt($0.stripHexPrefix(), radix: 16)! }))
            }
        )
    }
    
    public func allAccountBalances(_ address: String, completion: @escaping (Result<Dictionary<String, String>>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .string, value: address)
        ]
        
        transport.send(
            method: "zks_getAllAccountBalances",
            parameters: parameters,
            completion: completion
        )
    }
    
    // TODO: implement l1 for l2 and l2 for l1
    
    public func bridgeContracts(_ completion: @escaping (Result<BridgeAddresses>) -> Void) {
        transport.send(
            method: "zks_getBridgeContracts",
            parameters: [],
            completion: completion
        )
    }
    
    // FIXME: Should l2LogPosition be used?
    public func getL2ToL1MsgProof(_ block: Int, sender: String, message: String, l2LogPosition: Int64?, completion: @escaping (Result<L2ToL1MessageProof>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .int, value: block),
            JRPC.Parameter(type: .string, value: sender),
            JRPC.Parameter(type: .string, value: message)
        ]
        
        transport.send(
            method: "zks_getL2ToL1MsgProof",
            parameters: parameters,
            completion: completion
        )
    }
    
    public func getL2ToL1LogProof(_ txHash: String,
                              logIndex: Int,
                              completion: @escaping (Result<L2ToL1MessageProof>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .string, value: txHash),
            JRPC.Parameter(type: .int, value: logIndex),
        ]
        
        transport.send(
            method: "zks_getL2ToL1LogProof",
            parameters: parameters,
            completion: completion
        )
    }
    
    public func getTestnetPaymaster(_ completion: @escaping (Result<String>) -> Void) {
        transport.send(
            method: "zks_getTestnetPaymaster",
            parameters: [],
            completion: completion
        )
    }
    
    public func transactionDetails(_ transactionHash: String, completion: @escaping (Result<TransactionDetails>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .string, value: transactionHash),
        ]
        
        transport.send(
            method: "zks_getTransactionDetails",
            parameters: parameters,
            completion: completion
        )
    }
    
    public func blockDetails(_ block: Int, completion: @escaping (Result<BlockDetails>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .int, value: block),
        ]
        
        transport.send(
            method: "zks_getBlockDetails",
            parameters: parameters,
            completion: completion
        )
    }
    
    public func blockDetails(_ blockNumber: BigUInt, returnFullTransactionObjects: Bool, completion: @escaping (Result<BlockDetails>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .string, value: blockNumber.toHexString().addHexPrefix()),
        ]
        
        transport.send(
            method: "zks_getBlockDetails",
            parameters: parameters,
            completion: completion
        )
    }
    
    public func contractAccountInfo() {
        //111
    }
    
    public func l1BatchNumber(_ completion: @escaping (Result<String>) -> Void) {
        transport.send(
            method: "zks_L1BatchNumber",
            parameters: [],
            completion: completion
        )
    }
    
    public func l1BatchBlockRange(l1BatchNumber: BigUInt, _ completion: @escaping (Result<String>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .int, value: l1BatchNumber)
        ]
        
        transport.send(
            method: "zks_getL1BatchBlockRange",
            parameters: parameters,
            completion: completion
        )
    }
    
    public func l1BatchDetails(l1BatchNumber: BigUInt, _ completion: @escaping (Result<String>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .int, value: l1BatchNumber)
        ]
        
        transport.send(
            method: "zks_getL1BatchDetails",
            parameters: parameters,
            completion: completion
        )
    }
    
    public func logProof(txHash: Data, logIndex: BigUInt, _ completion: @escaping (Result<String>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .string, value: txHash),
            JRPC.Parameter(type: .int, value: logIndex)
        ]
        
        transport.send(
            method: "zks_getL2ToL1LogProof",
            parameters: parameters,
            completion: completion
        )
    }
    
    public func msgProof(block: BigUInt, sender: String, _ completion: @escaping (Result<String>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .int, value: block),
            JRPC.Parameter(type: .string, value: sender)
        ]
        
        transport.send(
            method: "zks_getL2ToL1MsgProof",
            parameters: parameters,
            completion: completion
        )
    }
    
    public func confirmedTokens(_ from: Int, limit: Int, completion: @escaping (Result<[Token]>) -> Void) {
        let parameters = [
            JRPC.Parameter(type: .int, value: from),
            JRPC.Parameter(type: .int, value: limit)
        ]
        
        transport.send(
            method: "zks_getConfirmedTokens",
            parameters: parameters,
            completion: completion
        )
    }
    
    public func l2TokenAddress() {
        //111
    }
    
    public func l1TokenAddress() {
        //111
    }
}
