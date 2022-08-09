//
//  EthereumProvider.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
import web3swift
import PromiseKit

public protocol EthereumProvider {
    
//    /// Send approve transaction to token contract.
//    /// - Parameters:
//    ///   - token: Token object supported by ZkSync.
//    ///   - limit: Maximum amount to approve for ZkSync contract.
//    func approveDeposits(with token: Token,
//                         limit: BigUInt?) throws -> Promise<TransactionSendingResult>
//    
//    /// Send transfer transaction. This is the regular transfer of ERC20 token.
//    /// - Parameters:
//    ///   - token: Token object supported by ZkSync.
//    ///   - amount: Amount of tokens to transfer.
//    ///   - address: Tokens receiver address.
//    func transfer(with token: Token,
//                  amount: BigUInt,
//                  to address: String) throws -> Promise<TransactionSendingResult>
//    
//    /// Send deposit transaction to ZkSync contract. For ERC20 token must be approved beforehand
//    /// using `EthereumProvider.approveDeposits()`.
//    /// - Parameters:
//    ///   - token: Token object supported by ZkSync.
//    ///   - amount: Amount of tokens to transfer.
//    ///   - userAddress: Address of L2 deposit receiver in ZkSync.
//    func deposit(with token: Token,
//                 amount: BigUInt,
//                 to userAddress: String) throws -> Promise<TransactionSendingResult>
//    
//    /// Send withdraw transaction to ZkSync contract.
//    /// - Parameters:
//    ///   - token: Token object supported by ZkSync.
//    ///   - amount: Address of the account who can deposit tokens from yours.
//    ///   - userAddress: Address of L1 withdrawal receiver in ZkSync.
//    func withdraw(with token: Token,
//                  amount: BigUInt,
//                  from userAddress: String) throws -> Promise<TransactionSendingResult>
//    
//    /// Check if deposit is approved.
//    /// - Parameters:
//    ///   - token: Token object supported by ZkSync.
//    ///   - address: Address of the account who can deposit tokens from yours.
//    ///   - threshold: Minimum threshold of approved tokens.
//    ///   - returns: Boolean value that denotes whether deposit was approved or not.
//    func isDepositApproved(with token: Token,
//                           address: String,
//                           threshold: BigUInt?) throws -> Bool
//    
//    /// ZkSync smart-contract address in Ethereum blockchain.
//    var contractAddress: EthereumAddress? { get }
}
