//
//  ZKSync.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt

typealias Result<T> = Swift.Result<T, Error>

protocol ZKSync {
    
//    Request<?, ZksEstimateFee> zksEstimateFee(Transaction transaction);
    func estimateFee(_ transaction: Transaction,
                     completion: @escaping (Result<Fee>) -> Void)
    
//    Request<?, ZksMainContract> zksMainContract();
    func mainContract(completion: @escaping (Result<MainContract>) -> Void)
    
//    Request<?, EthSendRawTransaction> zksGetL1WithdrawalTx(String transactionHash);
    func getL1WithdrawalTx(_ transactionHash: String,
                           completion: @escaping (Result<EthSendRawTransaction>) -> Void)

//    Request<?, ZksTransactions> zksGetAccountTransactions(String address, Integer before, Short limit);
    func getAccountTransactions(_ address: String,
                                before: Int, /* Integer in Java */
                                limit: Int, /* Short in Java */
                                completion: @escaping (Result<Transactions>) -> Void)
    
//    Request<?, ZksTokens> zksGetConfirmedTokens(Integer from, Short limit);
//    func tokens(completion: @escaping (ZKSyncResult<Tokens>) -> Void)
    func getConfirmedTokens(_ from: Int, /* Integer in Java */
                            limit: Int, /* Short in Java */
                            completion: @escaping (Result<[Token]>) -> Void)
    
//    Request<?, ZksIsTokenLiquid> zksIsTokenLiquid(String tokenAddress);
    func isTokenLiquid(_ tokenAddress: String,
                       completion: @escaping (Result<Bool>) -> Void)
    
//    Request<?, ZksTokenPrice> zksGetTokenPrice(String tokenAddress);
//    func tokenPrice(token: Token,
//                    completion: @escaping (ZKSyncResult<Decimal>) -> Void)
    func getTokenPrice(_ tokenAddress: String,
                       completion: @escaping (Result<Decimal>) -> Void)
    
//    Request<?, ZksL1ChainId> zksL1ChainId();
    func L1ChainId(completion: @escaping (Result<BigUInt>) -> Void)
    
//    Request<?, EthGetBalance> ethGetBalance(String address, DefaultBlockParameter defaultBlockParameter, String tokenAddress);
    func ethGetBalance(_ address: String,
                       // TODO: Add `DefaultBlockParameter`.
                       // defaultBlockParameter: DefaultBlockParameter,
                       tokenAddress: String,
                       completion: @escaping (Result<EthGetBalance>) -> Void)
    
//    Request<?, ZksSetContractDebugInfoResult> zksSetContractDebugInfo(String contractAddress, ContractSourceDebugInfo contractDebugInfo);
    func setContractDebugInfo(_ contractAddress: String,
                              // TODO: Add `ContractSourceDebugInfo`.
                              // contractDebugInfo: ContractSourceDebugInfo,
                              completion: @escaping (Result<SetContractDebugInfoResult>) -> Void)
    
//    Request<?, ZksContractDebugInfo> zksGetContractDebugInfo(String contractAddress);
    func contractDebugInfo(_ contractAddress: String,
                           completion: @escaping (Result<ContractDebugInfo>) -> Void)
    
//    Request<?, ZksTransactionTrace> zksGetTransactionTrace(String transactionHash);
    func transactionTrace(_ transactionHash: String,
                          completion: @escaping (Result<TransactionTrace>) -> Void)
    
//    Request<?, ZksAccountBalances> zksGetAllAccountBalances(String address);
    func allAccountBalances(_ address: String,
                            completion: @escaping (Result<AccountBalances>) -> Void)
}








// ??
//func contractAddress(queue: DispatchQueue,
//                     completion: @escaping (ZKSyncResult<ContractAddress>) -> Void)

//func submitTx(_ tx: ZkSyncTransaction,
//              ethereumSignature: EthSignature?,
//              fastProcessing: Bool,
//              completion: @escaping (ZKSyncResult<String>) -> Void)
//
//func submitTxBatch(txs: [TransactionSignaturePair],
//                   ethereumSignature: EthSignature?,
//                   completion: @escaping (ZKSyncResult<[String]>) -> Void)
//
//func transactionDetails(txHash: String,
//                        completion: @escaping (ZKSyncResult<TransactionDetails>) -> Void)
//
//func ethOpInfo(priority: Int,
//               completion: @escaping (ZKSyncResult<EthOpInfo>) -> Void)
//
//func confirmationsForEthOpAmount(completion: @escaping (ZKSyncResult<UInt64>) -> Void)
//
//func ethTxForWithdrawal(withdrawalHash: String,
//                        completion: @escaping (ZKSyncResult<String>) -> Void)
//
//func toggle2FA(toggle2FA: Toggle2FA,
//               completion: @escaping (ZKSyncResult<Toggle2FAInfo>) -> Void)
