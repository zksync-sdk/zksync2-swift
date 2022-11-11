//
//  ZkSync.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
import web3swift

public typealias Result<T> = Swift.Result<T, Error>

public protocol ZkSync {
    
    var web3: web3 { get set }
    
//    func zksEstimateFee(_ transaction: EthereumTransaction,
//                        completion: @escaping (Result<Fee>) -> Void)
    
    func zksMainContract(completion: @escaping (Result<String>) -> Void)
    
    func zksGetConfirmedTokens(_ from: Int,
                               limit: Int,
                               completion: @escaping (Result<[Token]>) -> Void)
    
    func zksGetTokenPrice(_ tokenAddress: String,
                          completion: @escaping (Result<Decimal>) -> Void)
    
    func zksL1ChainId(completion: @escaping (Result<BigUInt>) -> Void)
    
//    func zksGetContractDebugInfo(_ contractAddress: String,
//                                 completion: @escaping (Result<ContractDebugInfo>) -> Void)
//
//    func zksGetTransactionTrace(_ transactionHash: String,
//                                completion: @escaping (Result<TransactionTrace>) -> Void)
    
    func zksGetAllAccountBalances(_ address: String,
                                  completion: @escaping (Result<Dictionary<String, String>>) -> Void)
    
    func zksGetBridgeContracts(_ completion: @escaping (Result<BridgeAddresses>) -> Void)
    
    //    func zksGetL2ToL1MsgProof(_ block: Int,
    //                              sender: String,
    //                              message: String,
    //                              l2LogPosition: Int64?,
    //                              completion: @escaping (Result<MessageProof>) -> Void)
    
    // TODO: Consider removing.
    //    func ethEstimateGas(_ transaction: EthereumTransaction,
    //                        completion: @escaping (Result<EthEstimateGas>) -> Void)
    
    func zksGetTestnetPaymaster(_ completion: @escaping (Result<String>) -> Void)
    
    func chainId(_ completion: @escaping (Result<BigUInt>) -> Void)
}
