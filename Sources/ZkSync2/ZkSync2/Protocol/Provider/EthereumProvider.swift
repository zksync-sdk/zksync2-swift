//
//  EthereumProvider.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync
#endif

protocol EthereumProvider {
    
    /// Send approve transaction to token contract.
    /// - Parameters:
    ///   - token: Token object supported by ZkSync.
    ///   - limit: Maximum amount to approve for ZkSync contract.
    func approveDeposits(with token: Token,
                         limit: BigUInt?) throws -> Promise<TransactionSendingResult>
    
    /// Send transfer transaction. This is the regular transfer of ERC20 token.
    /// - Parameters:
    ///   - token: Token object supported by ZkSync.
    ///   - amount: Amount of tokens to transfer.
    ///   - address: Tokens receiver address.
    func transfer(with token: Token,
                  amount: BigUInt,
                  to address: String) throws -> Promise<TransactionSendingResult>
    
    /// Get base cost for L2 transaction.
    /// - Parameters:
    ///   - gasLimit: Gas limit for L2 transaction.
    ///   - gasPerPubdataByte: Gas per pubdata byte.
    ///   - gasPrice: Gas price for L2 transaction.
    func getBaseCost(_ gasLimit: BigUInt,
                     gasPerPubdataByte: BigUInt,
                     gasPrice: BigUInt?) throws -> Promise<[String: Any]>
    
    /// Send request execute transaction to ZkSync contract.
    /// - Parameters:
    ///   - contractAddress: Address of contract to call.
    ///   - l2Value: Value to send to contract.
    ///   - calldata: Calldata to send to contract.
    ///   - gasLimit: Gas limit for L2 transaction.
    ///   - factoryDeps: Factory dependencies.
    ///   - operatorTips: Tips for operator on L2 that executes deposit.
    ///   - gasPrice: Gas price for L2 transaction.
    ///   - refundRecipient: Address of L2 receiver refund in ZkSync.
    func requestExecute(_ contractAddress: String,
                        l2Value: BigUInt,
                        calldata: Data,
                        gasLimit: BigUInt,
                        factoryDeps: [Data]?,
                        operatorTips: BigUInt?,
                        gasPrice: BigUInt?,
                        refundRecipient: String) throws -> Promise<TransactionSendingResult>
    
    /// Send deposit transaction to ZkSync contract. For ERC20 token must be approved beforehand
    /// using `EthereumProvider.approveDeposits()`.
    /// - Parameters:
    ///   - token: Token object supported by ZkSync.
    ///   - amount: Amount of tokens to transfer.
    ///   - operatorTips: Tips for operator on L2 that executes deposit.
    ///   - userAddress: Address of L2 deposit receiver in ZkSync.
    func deposit(with token: Token,
                 amount: BigUInt,
                 operatorTips: BigUInt,
                 to userAddress: String) throws -> Promise<TransactionSendingResult>
    
    /// Send withdraw transaction to ZkSync contract.
    /// - Parameters:
    ///   - token: Token object supported by ZkSync.
    ///   - amount: Address of the account who can deposit tokens from yours.
    ///   - userAddress: Address of L1 withdrawal receiver in ZkSync.
    func withdraw(with token: Token,
                  amount: BigUInt,
                  from userAddress: String) throws -> Promise<TransactionSendingResult>
    
    /// Check if deposit is approved.
    /// - Parameters:
    ///   - token: Token object supported by ZkSync.
    ///   - address: Address of the account who can deposit tokens from yours.
    ///   - threshold: Minimum threshold of approved tokens.
    ///   - returns: Boolean value that denotes whether deposit was approved or not.
    func isDepositApproved(with token: Token,
                           address: String,
                           threshold: BigUInt?) throws -> Bool
    
    /// ZkSync Bridge for ERC20 smart-contract address in Ethereum blockchain.
    var l1ERC20BridgeAddress: String { get }
    
    var mainContractAddress: String { get }
}
