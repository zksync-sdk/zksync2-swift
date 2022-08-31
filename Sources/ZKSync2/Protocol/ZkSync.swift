//
//  ZKSync.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt

typealias Result<T> = Swift.Result<T, Error>

//public interface ZkSync extends Web3j {
//    static ZkSync build(Web3jService web3jService) {
//        return new JsonRpc2_0ZkSync(web3jService);
//    }
//
//    /**
//     * Estimate fee for the given transaction at the moment of the latest committed
//     * block.
//     *
//     * @param transaction Transaction data for estimation
//     * @return Prepared estimate fee request
//     */
//    Request<?, ZksEstimateFee> zksEstimateFee(Transaction transaction);
//
//    /**
//     * Get address of main contract for current network chain.
//     *
//     * @return Prepared main contract request
//     */
//    Request<?, ZksMainContract> zksMainContract();
//
//    /**
//     * Get hash of the withdrawal transaction in the L1 Ethereum chain.
//     *
//     * @param transactionHash Hash of the withdrawal transaction in L2 in hex format
//     * @return Prepared get withdraw transaction hash request
//     */
//    Request<?, EthSendRawTransaction> zksGetL1WithdrawalTx(String transactionHash);
//
//    /**
//     * Get list of the tokens supported by ZkSync.
//     *
//     * @param from  Offset of tokens
//     * @param limit Limit of amount of tokens to return
//     * @return Prepared get confirmed tokens request
//     */
//    Request<?, ZksTokens> zksGetConfirmedTokens(Integer from, Short limit);
//
//    /**
//     * Check if token is liquid.
//     *
//     * @param tokenAddress Address of the token in hex format
//     * @return Prepared is token liquid request
//     */
//    Request<?, ZksIsTokenLiquid> zksIsTokenLiquid(String tokenAddress);
//
//    /**
//     * Get price of the token in USD.
//     *
//     * @param tokenAddress Address of the token in hex format
//     * @return Prepared get token price request
//     */
//    Request<?, ZksTokenPrice> zksGetTokenPrice(String tokenAddress);
//
//    /**
//     * Get chain identifier of the L1 chain.
//     *
//     * @return Prepared l1 chainid request
//     */
//    Request<?, ZksL1ChainId> zksL1ChainId();
//
//    Request<?, ZksContractDebugInfo> zksGetContractDebugInfo(String contractAddress);
//
//    Request<?, ZksTransactionTrace> zksGetTransactionTrace(String transactionHash);
//
//    Request<?, ZksAccountBalances> zksGetAllAccountBalances(String address);
//
//    Request<?, ZksBridgeAddresses> zksGetBridgeContracts();
//
//    Request<?, ZksMessageProof> zksGetL2ToL1MsgProof(Integer block, String sender, String message, @Nullable Long l2LogPosition);
//
//    Request<?, EthEstimateGas> ethEstimateGas(Transaction transaction);
//}

protocol ZKSync {
    
    func zksEstimateFee(_ transaction: Transaction,
                        completion: @escaping (Result<Fee>) -> Void)
    
    func zksMainContract(completion: @escaping (Result<MainContract>) -> Void)
    
    func zksGetL1WithdrawalTx(_ transactionHash: String,
                              completion: @escaping (Result<EthSendRawTransaction>) -> Void)
    
    func zksGetConfirmedTokens(_ from: Int, /* Integer in Java */
                               limit: Int, /* Short in Java */
                               completion: @escaping (Result<[Token]>) -> Void)
    
    func zksIsTokenLiquid(_ tokenAddress: String,
                          completion: @escaping (Result<Bool>) -> Void)
    
    func zksGetTokenPrice(_ tokenAddress: String,
                          completion: @escaping (Result<Decimal>) -> Void)
    
    func zksL1ChainId(completion: @escaping (Result<BigUInt>) -> Void)
    
    func zksGetContractDebugInfo(_ contractAddress: String,
                                 completion: @escaping (Result<ContractDebugInfo>) -> Void)
    
    func zksGetTransactionTrace(_ transactionHash: String,
                                completion: @escaping (Result<TransactionTrace>) -> Void)
    
    func zksGetAllAccountBalances(_ address: String,
                                  completion: @escaping (Result<Dictionary<String, String>>) -> Void)
    
    func zksGetBridgeContracts(_ completion: @escaping (Result<BridgeAddresses>) -> Void)
    
    func zksGetL2ToL1MsgProof(_ block: Int,
                              sender: String,
                              message: String,
                              l2LogPosition: Int64,
                              completion: @escaping (Result<MessageProof>) -> Void)
    
    func ethEstimateGas(_ transaction: Transaction,
                        completion: @escaping (Result<EthEstimateGas>) -> Void)
}
