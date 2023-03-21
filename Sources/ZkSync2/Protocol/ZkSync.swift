//
//  ZkSync.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync
#endif

public typealias Result<T> = Swift.Result<T, Error>

public protocol ZkSync {
    
    var web3: web3 { get set }
    
    /// Estimate fee for the given transaction at the moment of the latest committed block.
    ///
    /// - Parameters:
    ///   - transaction: Transaction data for estimation.
    ///   - completion: Completion handler with result that contains fee estimate.
    func zksEstimateFee(_ transaction: EthereumTransaction,
                        completion: @escaping (Result<Fee>) -> Void)
    
    /// Get address of main contract for current network chain.
    ///
    /// - Parameter completion: Completion handler with result that contains main contract.
    func zksMainContract(_ completion: @escaping (Result<String>) -> Void)
    
    /// Get list of the tokens supported by ZkSync.
    /// The tokens are returned in alphabetical order by their symbol, so basically, the token
    /// id is its position in an alphabetically sorted array of tokens.
    ///
    /// - Parameters:
    ///   - from: Offset of tokens.
    ///   - limit: Limit of amount of tokens to return.
    ///   - completion: Completion handler with result that contains list of tokens.
    func zksGetConfirmedTokens(_ from: Int,
                               limit: Int,
                               completion: @escaping (Result<[Token]>) -> Void)
    
    /// Get price of the token in USD.
    /// - Parameters:
    ///   - tokenAddress: Address of the token in hex format.
    ///   - completion: Completion handler with result that contains token price.
    func zksGetTokenPrice(_ tokenAddress: String,
                          completion: @escaping (Result<Decimal>) -> Void)
    
    /// Get chain identifier of the L1 chain.
    ///
    /// - Parameter completion: Completion handler with result that contains L1 chain identifier.
    func zksL1ChainId(_ completion: @escaping (Result<BigUInt>) -> Void)
    
    /// Get all known balances for the given account.
    ///
    /// - Parameters:
    ///   - address: Wallet address.
    ///   - completion: Completion handler with result that contains all balances where account has
    ///   non-zero value.
    func zksGetAllAccountBalances(_ address: String,
                                  completion: @escaping (Result<Dictionary<String, String>>) -> Void)
    
    /// Get default bridges addresses deployed on L1 and L2.
    ///
    /// - Parameter completion: Completion handler with result that contains bridge addresses.
    func zksGetBridgeContracts(_ completion: @escaping (Result<BridgeAddresses>) -> Void)
    
    //    func zksGetL2ToL1MsgProof(_ block: Int,
    //                              sender: String,
    //                              message: String,
    //                              l2LogPosition: Int64?,
    //                              completion: @escaping (Result<MessageProof>) -> Void)
    
    /// Generates and returns an estimate of how much gas is necessary to allow the transaction to
    /// complete. The transaction will not be added to the blockchain.
    ///
    /// - Parameters:
    ///   - transaction: Transaction data for estimation.
    ///   - completion: Completion handler with result that contains gas estimate.
    func ethEstimateGas(_ transaction: EthereumTransaction,
                        completion: @escaping (Result<BigUInt>) -> Void)
    
    /// Get the address of the testnet paymaster: the paymaster that is available on testnets and
    /// enables paying fees in ERC-20 compatible tokens.
    ///
    /// - Parameter completion: Completion handler with result that contains paymaster address.
    func zksGetTestnetPaymaster(_ completion: @escaping (Result<String>) -> Void)
    
    /// Get transaction details.
    ///
    /// - Parameters:
    ///   - transactionHash: Hash of the executed transaction hash with sent message.
    ///   - completion: Completion handler with result that contains transaction details.
    func zksGetTransactionDetails(_ transactionHash: String,
                                  completion: @escaping (Result<TransactionDetails>) -> Void)
    
    /// Get transaction by hash.
    ///
    /// - Parameters:
    ///   - transactionHash: Hash of the executed transaction.
    ///   - completion: Completion handler with result that contains transaction response.
    func zksGetTransactionByHash(_ transactionHash: String,
                                 completion: @escaping (Result<TransactionResponse>) -> Void)
    
    /// Get block by hash.
    ///
    /// - Parameters:
    ///   - blockHash: Hash of a block.
    ///   - returnFullTransactionObjects: If `true` returns the full transaction objects,
    ///   otherwise only the hashes of the transactions.
    ///   - completion: Completion handler with result that contains block details.
    func zksGetBlockByHash(_ blockHash: String,
                           returnFullTransactionObjects: Bool,
                           completion: @escaping (Result<BlockDetails>) -> Void)
    
    /// Get block by number.
    ///
    /// - Parameters:
    ///   - blockNumber: Name of the block.
    ///   - returnFullTransactionObjects: If `true` returns the full transaction objects,
    ///   otherwise only the hashes of the transactions.
    ///   - completion: Completion handler with result that contains block details.
    func zksGetBlockByNumber(_ blockNumber: UInt,
                             returnFullTransactionObjects: Bool,
                             completion: @escaping (Result<BlockDetails>) -> Void)
}
