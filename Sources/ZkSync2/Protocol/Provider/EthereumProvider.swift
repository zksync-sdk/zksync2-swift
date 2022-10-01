//
//  EthereumProvider.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
import web3swift
import PromiseKit

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
    
    /// Send deposit transaction to ZkSync contract. For ERC20 token must be approved beforehand
    /// using `EthereumProvider.approveDeposits()`.
    /// - Parameters:
    ///   - token: Token object supported by ZkSync.
    ///   - amount: Amount of tokens to transfer.
    ///   - userAddress: Address of L2 deposit receiver in ZkSync.
    func deposit(with token: Token,
                 amount: BigUInt,
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
    
    /// ZkSync Bridge for Eth smart-contract address in Ethereum blockchain.
    var l1EthBridgeAddress: String { get }
}

extension EthereumProvider {
    
    static func load(_ zkSync: ZkSync,
                     web3: web3) -> Promise<DefaultEthereumProvider> {
        Promise { seal in
            zkSync.zksGetBridgeContracts { result in
                switch result {
                case .success(let bridgeAddresses):
                    let l1ERC20Bridge = web3.contract(Web3.Utils.IL1Bridge,
                                                      at: EthereumAddress(bridgeAddresses.l1Erc20DefaultBridge))!
                    
                    let l1EthBridge = web3.contract(Web3.Utils.IL1Bridge,
                                                    at: EthereumAddress(bridgeAddresses.l1EthDefaultBridge))!
                    
                    let defaultEthereumProvider = DefaultEthereumProvider(web3,
                                                                          l1ERC20Bridge: l1ERC20Bridge,
                                                                          l1EthBridge: l1EthBridge)
                    
                    return seal.resolve(.fulfilled(defaultEthereumProvider))
                case .failure(let error):
                    return seal.resolve(.rejected(error))
                }
            }
        }
    }
}
