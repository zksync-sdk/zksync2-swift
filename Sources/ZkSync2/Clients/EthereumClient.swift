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
import Web3Core
#else
import web3swift_zksync2
#endif

public typealias Result<T> = Swift.Result<T, Error>

public protocol EthereumClient {
    var web3: Web3 { get set }
    
    // ChainID retrieves the current chain ID for transaction replay protection.
    func chainID() async throws -> BigUInt
    // BlockByHash returns the given full block.
    func blockByHash(_ blockHash: String, fullTransactions: Bool) async throws -> Block
    // BlockByNumber returns a block from the current canonical chain. If number is nil, the
    // latest known block is returned.
    func blockByNumber(_ blockNumber: BlockNumber, fullTransactions: Bool) async throws -> Block
    // BlockNumber returns the most recent block number
    func blockNumber() async throws -> BigUInt
    // TransactionByHash returns the transaction with the given hash.
    func transactionByHash(_ transactionHash: String) async throws -> TransactionResponse
    func getLogs() async throws -> Log 
    // TransactionSender returns the sender address of the given transaction. The transaction
    // must be known to the remote node and included in the blockchain at the given block and
    // index. The sender is the one derived by the protocol at the time of inclusion.
    func transactionSender(_ blockHash: String, index: Int) async throws -> Block
    // TransactionCount returns the total number of transactions in the given block.
    func transactionCount(address: String, blockNumber: BlockNumber) async throws -> BigUInt
    // TransactionInBlock returns a single transaction at index in the given block.
    func transactionInBlock(_ blockHash: String, index: Int) async throws -> Block
    // TransactionReceipt returns the receipt of a transaction by transaction hash.
    // Note that the receipt is not available for pending transactions.
    func transactionReceipt(_ txHash: String) async throws -> TransactionReceipt
    
    // BalanceAt returns the wei balance of the given account.
    // The block number can be nil, in which case the balance is taken from the latest known block.
    func balance(at address: String, blockNumber: BlockNumber) async throws -> BigUInt
    // CodeAt returns the contract code of the given account.
    // The block number can be nil, in which case the code is taken from the latest known block.
    func code(at address: String, blockNumber: BlockNumber) async throws -> String
    
    // CallContract executes a message call transaction, which is directly executed in the VM
    // of the node, but never mined into the blockchain.
    //
    // blockNumber selects the block height at which the call runs. It can be nil, in which
    // case the code is taken from the latest known block. Note that state from very old
    // blocks might not be available.
    func callContract(_ transaction: CodableTransaction, blockNumber: BigUInt?) async throws -> Data
    // CallContractL2 is almost the same as CallContract except that it executes a message call
    // for EIP-712 transaction.
    func callContractL2(_ transaction: CodableTransaction, blockNumber: BigUInt?) async throws -> Data
    // CallContractAtHash is almost the same as CallContract except that it selects
    // the block by block hash instead of block height.
    func callContractAtHash(_ transaction: CodableTransaction, hash: String) async throws -> Data
    // CallContractAtHashL2 is almost the same as CallContractL2 except that it selects
    // the block by block hash instead of block height.
    func callContractAtHashL2(_ transaction: CodableTransaction, hash: String) async throws -> Data
    // PendingCallContract executes a message call transaction using the EVM.
    // The state seen by the contract call is the pending state.
    func pendingCallContract(_ transaction: CodableTransaction) async throws -> Data
    // PendingCallContractL2 executes a message call for EIP-712 transaction using the EVM.
    // The state seen by the contract call is the pending state.
    func pendingCallContractL2(_ transaction: CodableTransaction) async throws -> Data
    // SuggestGasPrice retrieves the currently suggested gas price to allow a timely
    // execution of a transaction.
    func suggestGasPrice() async throws -> BigUInt
    // SuggestGasTipCap retrieves the currently suggested gas tip cap after 1559 to
    // allow a timely execution of a transaction.
    func suggestGasTipCap() async throws -> BigUInt
    // EstimateGas tries to estimate the gas needed to execute a transaction based on
    // the current pending state of the backend blockchain. There is no guarantee that this is
    // the true gas limit requirement as other transactions may be added or removed by miners,
    // but it should provide a basis for setting a reasonable default.
    func estimateGas(_ transaction: CodableTransaction) async throws -> BigUInt
    // EstimateGasL2 is almost the same as EstimateGas except that it executes an EIP-712 transaction.
    func estimateGasL2(_ transaction: CodableTransaction) async throws -> BigUInt
    // SendTransaction injects a signed transaction into the pending pool for execution.
    //
    // If the transaction was a contract creation use the TransactionReceipt method to get the
    // contract address after the transaction has been mined.
    func sendTransaction(_ transaction: CodableTransaction) async throws -> TransactionSendingResult
    // SendRawTransaction injects a signed raw transaction into the pending pool for execution.
    func sendRawTransaction(_ data: Data) async throws -> TransactionSendingResult
    func maxPriorityFeePerGas() async throws -> BigUInt
    func waitforTransactionReceipt(transactionHash: String, timeout: TimeInterval?, pollLatency: TimeInterval?) async throws -> TransactionReceipt?

}
