//
//  ZkSyncTransactionReceiptProcessor.swift
//  zkSync-Demo
//
//  Created by Bojan on 17.6.23..
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

public class ZkSyncTransactionReceiptProcessor {
    
    static let DEFAULT_BLOCK_COMMIT_TIME = 800
    static let DEFAULT_POLLING_FREQUENCY = DEFAULT_BLOCK_COMMIT_TIME
    static let DEFAULT_POLLING_ATTEMPTS_PER_TX_HASH = 40
    
    var sleepDuration = TimeInterval(Double(DEFAULT_POLLING_FREQUENCY) / 100.0)
    var attempts = DEFAULT_POLLING_ATTEMPTS_PER_TX_HASH
    
    let zkSync: ZkSyncClient
    
    public init(zkSync: ZkSyncClient) {
        self.zkSync = zkSync
    }
    
    public func waitForTransactionReceipt(hash: String) async -> TransactionReceipt? {
        var receipt: TransactionReceipt?
        
        for _ in 0..<attempts {
            try! await Task.sleep(nanoseconds: UInt64(sleepDuration * 1_000_000_000))
            
            receipt = try? await zkSync.web3.eth.transactionReceipt(Data(hex: hash))

            if receipt != nil {
                break
            }
        }
        
        return receipt
    }
}
