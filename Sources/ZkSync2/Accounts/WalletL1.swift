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
    public let ethClient: EthereumClient
    public let web: web3
    
    public let signer: ETHSigner
    
    public init(_ zkSync: ZkSyncClient, ethClient: EthereumClient, web3: web3, ethSigner: ETHSigner) {
        self.zkSync = zkSync
        self.ethClient = ethClient
        self.web = web3
        self.signer = ethSigner
    }
}

extension WalletL1 {
    public func mainContract(callback: @escaping ((web3.web3contract) -> Void)) {
        zkSync.mainContract { result in
            switch result {
            case .success(let address):
                let zkSyncContract = self.web.contract(
                    Web3.Utils.IZkSync,
                    at: EthereumAddress(address)
                )!
                
                callback(zkSyncContract)
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    public func balanceL1(token: Token) -> Promise<BigUInt> {
        if token.symbol == Token.ETH.symbol {
            return web.eth.getBalancePromise(address: EthereumAddress(signer.address)!)
        } else {
            fatalError("Not supported")
        }
    }
    
    public func allowanceL1() {
        
    }
    
    public func l2TokenAddress() {
        
    }
    
    public func approveERC20() {
        
    }
    
    public func baseCost() {
        
    }
    
    public func estimateGasDeposit() {
        
    }
    
    public func fullRequiredDepositFee() {
        
    }
    
    public func finalizeWithdraw() {
        
    }
    
    public func isWithdrawFinalized() {
        
    }
    
    public func claimFailedDeposit() {
        
    }
    
    public func requestExecute() {
        
    }
    
    public func estimateGasRequestExecute() {
        
    }
    
    public func L1BridgeContracts(callback: @escaping ((Result<BridgeAddresses>) -> Void)) {
        zkSync.bridgeContracts { result in
            callback(result)
        }
    }
    
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
            zkSyncContract: zkSyncContract
        )
        
        return try! defaultEthereumProvider.deposit(
            with: token ?? Token.ETH,
            amount: amount,
            address: to,
            operatorTips: BigUInt(0)
        )
    }
}
