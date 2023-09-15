//
//  EthereumClient.swift
//  zkSync-Demo
//
//  Created by Bojan on 1.9.23..
//

import Foundation
import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

public typealias Result<T> = Swift.Result<T, Error>

public protocol EthereumClient {
    var web3: web3 { get set }
    
    // ChainID retrieves the current chain ID for transaction replay protection.
    func chainID() -> Promise<BigUInt>
    // BlockByHash returns the given full block.
    //
    // Note that loading full blocks requires two requests. Use HeaderByHash
    // if you don't need all transactions or uncle headers.
    func blockByHash(_ blockHash: String, returnFullTransactionObjects: Bool, completion: @escaping (Result<Block>) -> Void)
    // BlockByNumber returns a block from the current canonical chain. If number is nil, the
    // latest known block is returned.
    //
    // Note that loading full blocks requires two requests. Use HeaderByNumber
    // if you don't need all transactions or uncle headers.
    func blockByNumber(_ block: DefaultBlockParameterName, returnFullTransactionObjects: Bool, completion: @escaping (Result<Block>) -> Void)
    // BlockNumber returns the most recent block number
    func blockNumber(completion: @escaping (Result<BigUInt>) -> Void)
    // PeerCount returns the number of p2p peers as reported by the net_peerCount method
    func peerCount(completion: @escaping (Result<BigUInt>) -> Void)
    // TransactionByHash returns the transaction with the given hash.
    func transactionByHash(_ transactionHash: String, completion: @escaping (Result<TransactionResponse>) -> Void)
    // TransactionSender returns the sender address of the given transaction. The transaction
    // must be known to the remote node and included in the blockchain at the given block and
    // index. The sender is the one derived by the protocol at the time of inclusion.
    func transactionSender(_ blockHash: String,
                           index: Int,
                           completion: @escaping (Result<Block>) -> Void)
    // TransactionCount returns the total number of transactions in the given block.
    func transactionCount(address: String, blockHash: String) throws -> BigUInt
    // TransactionInBlock returns a single transaction at index in the given block.
    func transactionInBlock(_ blockHash: String,
                            index: Int,
                            completion: @escaping (Result<Block>) -> Void)
    // TransactionReceipt returns the receipt of a transaction by transaction hash.
    // Note that the receipt is not available for pending transactions.
    func transactionReceipt(_ txHash: String, completion: @escaping (Result<TransactionReceipt>) -> Void)
    
    // BalanceAt returns the wei balance of the given account.
    // The block number can be nil, in which case the balance is taken from the latest known block.
    func balanceAt(address: String, blockHash: String) throws -> BigUInt
    // CodeAt returns the contract code of the given account.
    // The block number can be nil, in which case the code is taken from the latest known block.
    func codeAt(address: String, blockHash: String) throws -> String
    
    // CallContract executes a message call transaction, which is directly executed in the VM
    // of the node, but never mined into the blockchain.
    //
    // blockNumber selects the block height at which the call runs. It can be nil, in which
    // case the code is taken from the latest known block. Note that state from very old
    // blocks might not be available.
    func callContract(_ transaction: EthereumTransaction, blockNumber: BigUInt?, completion: @escaping (Result<Data>) -> Void)
    // CallContractL2 is almost the same as CallContract except that it executes a message call
    // for EIP-712 transaction.
    func callContractL2(_ transaction: EthereumTransaction, blockNumber: BigUInt?, completion: @escaping (Result<Data>) -> Void)
    // CallContractAtHash is almost the same as CallContract except that it selects
    // the block by block hash instead of block height.
    func callContractAtHash(_ transaction: EthereumTransaction, hash: String, completion: @escaping (Result<Data>) -> Void)
    // CallContractAtHashL2 is almost the same as CallContractL2 except that it selects
    // the block by block hash instead of block height.
    func callContractAtHashL2(_ transaction: EthereumTransaction, hash: String, completion: @escaping (Result<Data>) -> Void)
    // PendingCallContract executes a message call transaction using the EVM.
    // The state seen by the contract call is the pending state.
    func pendingCallContract(_ transaction: EthereumTransaction, hash: String, completion: @escaping (Result<Data>) -> Void)
    // PendingCallContractL2 executes a message call for EIP-712 transaction using the EVM.
    // The state seen by the contract call is the pending state.
    func pendingCallContractL2(_ transaction: EthereumTransaction, hash: String, completion: @escaping (Result<Data>) -> Void)
    // SuggestGasPrice retrieves the currently suggested gas price to allow a timely
    // execution of a transaction.
    func suggestGasPrice(completion: @escaping (Result<BigUInt>) -> Void)
    // SuggestGasTipCap retrieves the currently suggested gas tip cap after 1559 to
    // allow a timely execution of a transaction.
    func suggestGasTipCap(completion: @escaping (Result<BigUInt>) -> Void)
    // EstimateGas tries to estimate the gas needed to execute a transaction based on
    // the current pending state of the backend blockchain. There is no guarantee that this is
    // the true gas limit requirement as other transactions may be added or removed by miners,
    // but it should provide a basis for setting a reasonable default.
    func estimateGas(_ transaction: EthereumTransaction, completion: @escaping (Result<BigUInt>) -> Void)
    // EstimateGasL2 is almost the same as EstimateGas except that it executes an EIP-712 transaction.
    func estimateGasL2(_ transaction: EthereumTransaction, completion: @escaping (Result<BigUInt>) -> Void)
    // SendTransaction injects a signed transaction into the pending pool for execution.
    //
    // If the transaction was a contract creation use the TransactionReceipt method to get the
    // contract address after the transaction has been mined.
    func sendTransaction(_ transaction: EthereumTransaction, transactionOptions: TransactionOptions, completion: @escaping (Result<TransactionSendingResult>) -> Void)
    // SendRawTransaction injects a signed raw transaction into the pending pool for execution.
    func sendRawTransaction(transaction: Data, completion: @escaping (Result<TransactionSendingResult>) -> Void)
}
