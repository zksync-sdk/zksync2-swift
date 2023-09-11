//
//  WalletL1.swift
//  zkSync-Demo
//
//  Created by Bojan on 1.9.23..
//

import Foundation
import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

public class WalletL1: AdapterL1 {
    public let zkSync: ZkSyncClient
    public let web: web3
    
    public let signer: EthSigner
    
    // FIXME: Is fee provider still needed?
    let feeProvider: ZkTransactionFeeProvider
    
    public init(_ zkSync: ZkSyncClient, web3: web3, ethSigner: EthSigner, feeToken: Token) {
        self.zkSync = zkSync
        self.web = web3
        self.signer = ethSigner
        self.feeProvider = DefaultTransactionFeeProvider(zkSync: zkSync, feeToken: feeToken)
    }
    
    public init(_ zkSync: ZkSyncClient, web3: web3, ethSigner: EthSigner, feeProvider: ZkTransactionFeeProvider) {
        self.zkSync = zkSync
        self.web = web3
        self.signer = ethSigner
        self.feeProvider = DefaultTransactionFeeProvider(zkSync: zkSync, feeToken: Token.ETH)
    }
}

extension WalletL1 {
    public func deposit(_ to: String, amount: BigUInt) -> Promise<TransactionSendingResult> {
        deposit(to, amount: amount, token: nil, nonce: nil)
    }
    
    public func deposit(_ to: String, amount: BigUInt, token: Token) -> Promise<TransactionSendingResult> {
        deposit(to, amount: amount, token: token, nonce: nil)
    }
    
    public func deposit(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) -> Promise<TransactionSendingResult> {
        let semaphore = DispatchSemaphore(value: 0)
        
        var zkSyncAddress: String = ""
        
        zkSync.mainContract { result in
            switch result {
            case .success(let address):
                zkSyncAddress = address
            case .failure(let error):
                fatalError("Failed with error: \(error.localizedDescription)")
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        let zkSyncContract = web.contract(
            Web3.Utils.IZkSync,
            at: EthereumAddress(zkSyncAddress)
        )!
        
        let l1ERC20Bridge = zkSync.web3.contract(
            Web3.Utils.IL1Bridge,
            at: EthereumAddress(signer.address)
        )!
        
        let defaultEthereumProvider = DefaultEthereumProvider(
            web,
            l1ERC20Bridge: l1ERC20Bridge,
            zkSyncContract: zkSyncContract,
            gasProvider: DefaultGasProvider()
        )
        
        return try! defaultEthereumProvider.deposit(
            with: token ?? Token.ETH,
            amount: amount,
            operatorTips: BigUInt(0),
            to: to
        )
    }
}
