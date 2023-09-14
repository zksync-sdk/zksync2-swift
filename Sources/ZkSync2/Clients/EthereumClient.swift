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
//111    ChainID(ctx context.Context) (*big.Int, error)
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
    // HeaderByHash returns the block header with the given hash.
//111    HeaderByHash(ctx context.Context, hash common.Hash) (*types.Header, error)
    // HeaderByNumber returns a block header from the current canonical chain. If number is
    // nil, the latest known header is returned.
//111    HeaderByNumber(ctx context.Context, number *big.Int) (*types.Header, error)
    // TransactionByHash returns the transaction with the given hash.
    func transactionByHash(_ transactionHash: String, completion: @escaping (Result<TransactionResponse>) -> Void)
    // TransactionSender returns the sender address of the given transaction. The transaction
    // must be known to the remote node and included in the blockchain at the given block and
    // index. The sender is the one derived by the protocol at the time of inclusion.
//111    TransactionSender(ctx context.Context, tx *zkTypes.TransactionResponse, block common.Hash, index uint) (common.Address, error)
    // TransactionCount returns the total number of transactions in the given block.
//111    TransactionCount(ctx context.Context, blockHash common.Hash) (uint, error)
    // TransactionInBlock returns a single transaction at index in the given block.
//111    TransactionInBlock(ctx context.Context, blockHash common.Hash, index uint) (*zkTypes.TransactionResponse, error)
    // TransactionReceipt returns the receipt of a transaction by transaction hash.
    // Note that the receipt is not available for pending transactions.
//111    TransactionReceipt(ctx context.Context, txHash common.Hash) (*zkTypes.Receipt, error)
    // SyncProgress retrieves the current progress of the sync algorithm. If there's
    // no sync currently running, it returns nil.
//111    SyncProgress(ctx context.Context) (*ethereum.SyncProgress, error)
    // SubscribeNewHead subscribes to notifications about the current blockchain head
    // on the given channel.
//111    SubscribeNewHead(ctx context.Context, ch chan<- *types.Header) (ethereum.Subscription, error)
    
    // NetworkID returns the network ID for this client.
//111    NetworkID(ctx context.Context) (*big.Int, error)
    // BalanceAt returns the wei balance of the given account.
    // The block number can be nil, in which case the balance is taken from the latest known block.
//111    BalanceAt(ctx context.Context, account common.Address, blockNumber *big.Int) (*big.Int, error)
    // StorageAt returns the value of key in the contract storage of the given account.
    // The block number can be nil, in which case the value is taken from the latest known block.
//111    StorageAt(ctx context.Context, account common.Address, key common.Hash, blockNumber *big.Int) ([]byte, error)
    // CodeAt returns the contract code of the given account.
    // The block number can be nil, in which case the code is taken from the latest known block.
//111    CodeAt(ctx context.Context, account common.Address, blockNumber *big.Int) ([]byte, error)
    // NonceAt returns the account nonce of the given account.
    // The block number can be nil, in which case the nonce is taken from the latest known block.
//111    NonceAt(ctx context.Context, account common.Address, blockNumber *big.Int) (uint64, error)
    
    // FilterLogs performs the same function as FilterLogsL2, and that method should be used instead.
    // This method is designed to be compatible with bind.ContractBackend.
//111    FilterLogs(ctx context.Context, query ethereum.FilterQuery) ([]types.Log, error)
    // FilterLogsL2 executes a log filter operation, blocking during execution and
    // returning all the results in one batch.
//111    FilterLogsL2(ctx context.Context, query ethereum.FilterQuery) ([]zkTypes.Log, error)
    // SubscribeFilterLogs performs the same function as SubscribeFilterLogsL2, and that method should be used instead.
    // This method is designed to be compatible with bind.ContractBackend.
//111    SubscribeFilterLogs(ctx context.Context, query ethereum.FilterQuery, ch chan<- types.Log) (ethereum.Subscription, error)
    // SubscribeFilterLogsL2 creates a background log filtering operation, returning
    // a subscription immediately, which can be used to stream the found events.
//111    SubscribeFilterLogsL2(ctx context.Context, query ethereum.FilterQuery, ch chan<- zkTypes.Log) (ethereum.Subscription, error)
    
    // PendingBalanceAt returns the wei balance of the given account in the pending state.
//111    PendingBalanceAt(ctx context.Context, account common.Address) (*big.Int, error)
    // PendingStorageAt returns the value of key in the contract storage of the given account in the pending state.
//111    PendingStorageAt(ctx context.Context, account common.Address, key common.Hash) ([]byte, error)
    // PendingCodeAt returns the contract code of the given account in the pending state.
//111    PendingCodeAt(ctx context.Context, account common.Address) ([]byte, error)
    // PendingNonceAt returns the account nonce of the given account in the pending state.
    // This is the nonce that should be used for the next transaction.
//111    PendingNonceAt(ctx context.Context, account common.Address) (uint64, error)
    // PendingTransactionCount returns the total number of transactions in the pending state.
//111    PendingTransactionCount(ctx context.Context) (uint, error)
    
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
//111    CallContractAtHash(ctx context.Context, msg ethereum.CallMsg, blockHash common.Hash) ([]byte, error)
    // CallContractAtHashL2 is almost the same as CallContractL2 except that it selects
    // the block by block hash instead of block height.
//111    CallContractAtHashL2(ctx context.Context, msg zkTypes.CallMsg, blockHash common.Hash) ([]byte, error)
    // PendingCallContract executes a message call transaction using the EVM.
    // The state seen by the contract call is the pending state.
//111    PendingCallContract(ctx context.Context, msg ethereum.CallMsg) ([]byte, error)
    // PendingCallContractL2 executes a message call for EIP-712 transaction using the EVM.
    // The state seen by the contract call is the pending state.
//111    PendingCallContractL2(ctx context.Context, msg zkTypes.CallMsg) ([]byte, error)
    // SuggestGasPrice retrieves the currently suggested gas price to allow a timely
    // execution of a transaction.
//111    SuggestGasPrice(ctx context.Context) (*big.Int, error)
    // SuggestGasTipCap retrieves the currently suggested gas tip cap after 1559 to
    // allow a timely execution of a transaction.
//111    SuggestGasTipCap(ctx context.Context) (*big.Int, error)
    // EstimateGas tries to estimate the gas needed to execute a transaction based on
    // the current pending state of the backend blockchain. There is no guarantee that this is
    // the true gas limit requirement as other transactions may be added or removed by miners,
    // but it should provide a basis for setting a reasonable default.
    func estimateGas(_ transaction: EthereumTransaction, completion: @escaping (Result<BigUInt>) -> Void)
    // EstimateGasL2 is almost the same as EstimateGas except that it executes an EIP-712 transaction.
//111    EstimateGasL2(ctx context.Context, msg zkTypes.CallMsg) (uint64, error)
    // SendTransaction injects a signed transaction into the pending pool for execution.
    //
    // If the transaction was a contract creation use the TransactionReceipt method to get the
    // contract address after the transaction has been mined.
//111    SendTransaction(ctx context.Context, tx *types.Transaction) error
    // SendRawTransaction injects a signed raw transaction into the pending pool for execution.
//111    SendRawTransaction(ctx context.Context, tx []byte) (common.Hash, error)
    
    // WaitMined waits for tx to be mined on the blockchain.
    // It stops waiting when the context is canceled.
//111    WaitMined(ctx context.Context, txHash common.Hash) (*zkTypes.Receipt, error)
    // WaitFinalized waits for tx to be finalized on the blockchain.
    // It stops waiting when the context is canceled.
//111    WaitFinalized(ctx context.Context, txHash common.Hash) (*zkTypes.Receipt, error)
}
