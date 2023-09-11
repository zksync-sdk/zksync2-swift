//
//  ZkSyncClient.swift
//  zkSync-Demo
//
//  Created by Bojan on 12.9.23..
//

import Foundation
import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

public protocol ZkSyncClient {
    var web3: web3 { get set }
    
    func estimateFee(_ transaction: EthereumTransaction) -> Promise<Fee>
    
    func mainContract(_ completion: @escaping (Result<String>) -> Void)
    
    func getConfirmedTokens(_ from: Int, limit: Int, completion: @escaping (Result<[Token]>) -> Void)
    
    func getTokenPrice(_ tokenAddress: String, completion: @escaping (Result<Decimal>) -> Void)
    
    func L1ChainId(_ completion: @escaping (Result<BigUInt>) -> Void)
    
    func getAllAccountBalances(_ address: String, completion: @escaping (Result<Dictionary<String, String>>) -> Void)
    
    func getBridgeContracts(_ completion: @escaping (Result<BridgeAddresses>) -> Void)
    
    func getTestnetPaymaster(_ completion: @escaping (Result<String>) -> Void)
    
    func getTransactionDetails(_ transactionHash: String, completion: @escaping (Result<TransactionDetails>) -> Void)
    
    
    
    func getBlockDetails(_ blockNumber: BigUInt, returnFullTransactionObjects: Bool, completion: @escaping (Result<BlockDetails>) -> Void)
    
    func getL2ToL1LogProof(_ txHash: String, logIndex: Int, completion: @escaping (Result<L2ToL1MessageProof>) -> Void)
}
