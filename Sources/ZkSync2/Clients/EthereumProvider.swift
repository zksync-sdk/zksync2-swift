//
//  EthereumProvider.swift
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

protocol EthereumProvider {
    var l1ERC20BridgeAddress: String { get }
    var mainContractAddress: String { get }
    
    func approveDeposit(with token: Token, limit: BigUInt?) throws -> Promise<TransactionSendingResult>
    func isDepositApproved(with token: Token, to address: String, threshold: BigUInt?) throws -> Bool
    func deposit(with token: Token, amount: BigUInt, address: String, operatorTips: BigUInt) throws -> Promise<TransactionSendingResult>
    func requestExecute(_ contractAddress: String, l2Value: BigUInt, calldata: Data, gasLimit: BigUInt, factoryDeps: [Data]?, operatorTips: BigUInt?, gasPrice: BigUInt?, refundRecipient: String) throws -> Promise<TransactionSendingResult>
    func finalizeEthWithdrawal(_ l2BlockNumber: BigUInt, l2MessageIndex: BigUInt, l2TxNumberInBlock: UInt, message: Data, proof: [Data], nonce: BigUInt) -> Promise<TransactionSendingResult>
    func finalizeWithdrawal(_ l1BridgeAddress: String,
                            l2BlockNumber: BigUInt,
                            l2MessageIndex: BigUInt,
                            l2TxNumberInBlock: UInt,
                            message: Data,
                            proof: [Data]) -> Promise<TransactionSendingResult>
    func isEthWithdrawalFinalized(_ l2BlockNumber: BigUInt, l2MessageIndex: BigUInt) -> Promise<[String: Any]>
    func isWithdrawalFinalized(_ l1BridgeAddress: String,
                               l2BlockNumber: BigUInt,
                               l2MessageIndex: BigInt) -> Promise<[String: Any]>
    func claimFailedDeposit(_ l1BridgeAddress: String,
                            depositSender: String,
                            l1Token: String,
                            l2TxHash: Data,
                            l2BlockNumber: BigUInt,
                            l2MessageIndex: BigUInt,
                            l2TxNumberInBlock: UInt,
                            proof: [Data]) -> Promise<TransactionSendingResult>
    func baseCost(_ gasLimit: BigUInt, gasPerPubdataByte: BigUInt, gasPrice: BigUInt?) throws -> Promise<[String: Any]>
}
