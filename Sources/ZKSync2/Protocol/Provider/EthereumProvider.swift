//
//  EthereumProvider.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
import web3swift

public protocol EthereumProvider {
    
    /// Send approve transaction to token contract.
    /// - Parameters:
    ///   - token: Token object supported by ZkSync.
    ///   - limit: Maximum amount to approve for ZkSync contract.
    ///   - completion: The completion handler to execute after finishing transaction.
    func approveDeposits(with token: Token,
                         limit: BigUInt?,
                         completion: @escaping (Result<TransactionReceipt, Error>) -> Void)
    
    /// Send transfer transaction. This is the regular transfer of ERC20 token.
    /// - Parameters:
    ///   - token: Token object supported by ZkSync.
    ///   - amount: Amount of tokens to transfer.
    ///   - address: Tokens receiver address.
    ///   - completion: The completion handler to execute after finishing transaction.
    func transfer(with token: Token,
                  amount: BigUInt,
                  to address: String,
                  completion: @escaping (Result<TransactionReceipt, Error>) -> Void)
    
    /// Send deposit transaction to ZkSync contract. For ERC20 token must be approved beforehand
    /// using `EthereumProvider.approveDeposits()`.
    /// - Parameters:
    ///   - token: Token object supported by ZkSync.
    ///   - amount: Amount of tokens to transfer.
    ///   - userAddress: Address of L2 deposit receiver in ZkSync.
    ///   - completion: The completion handler to execute after finishing transaction.
    func deposit(with token: Token,
                 amount: BigUInt,
                 to userAddress: String,
                 completion: @escaping (Result<TransactionReceipt, Error>) -> Void)
    
    /// Send withdraw transaction to ZkSync contract.
    /// - Parameters:
    ///   - token: Token object supported by ZkSync.
    ///   - amount: Address of the account who can deposit tokens from yours.
    ///   - userAddress: Address of L1 withdrawal receiver in ZkSync.
    ///   - completion: The completion handler to execute after finishing transaction.
    func withdraw(with token: Token,
                  amount: BigUInt,
                  from userAddress: String,
                  completion: @escaping (Result<TransactionReceipt, Error>) -> Void)
    
    /// Check if deposit is approved.
    /// - Parameters:
    ///   - token: Token object supported by ZkSync.
    ///   - address: Address of the account who can deposit tokens from yours.
    ///   - threshold: Minimum threshold of approved tokens.
    ///   - completion: The completion handler to execute after finishing transaction.
    func isDepositApproved(with token: Token,
                           address: String,
                           threshold: BigUInt?,
                           completion: @escaping (Result<Bool, Error>) -> Void)
    
    /// ZkSync smart-contract address in Ethereum blockchain.
    var contractAddress: String { get }
}
