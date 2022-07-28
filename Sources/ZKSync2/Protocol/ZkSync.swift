//
//  ZKSync.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation

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
    func getConfirmedTokens(_ from: Int, /* Integer in Java */
                            limit: Int, /* Short in Java */
                            completion: @escaping (Result<Tokens>) -> Void)
    
//    Request<?, ZksIsTokenLiquid> zksIsTokenLiquid(String tokenAddress);
    func isTokenLiquid(_ tokenAddress: String,
                       completion: @escaping (Result<IsTokenLiquid>) -> Void)
    
//    Request<?, ZksTokenPrice> zksGetTokenPrice(String tokenAddress);
    func getTokenPrice(_ tokenAddress: String,
                       completion: @escaping (Result<TokenPrice>) -> Void)
    
//    Request<?, ZksL1ChainId> zksL1ChainId();
    func L1ChainId(completion: @escaping (Result<L1ChainId>) -> Void)
    
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
