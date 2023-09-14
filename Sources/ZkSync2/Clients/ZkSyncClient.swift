//
//  ZkSyncClient.swift
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

public protocol ZkSyncClient {
    var web3: web3 { get set }
    
    func getL2ToL1LogProof(_ txHash: String, logIndex: Int, completion: @escaping (Result<L2ToL1MessageProof>) -> Void)
    
    // MainContractAddress returns the address of the zkSync Era contract.
    func mainContract(_ completion: @escaping (Result<String>) -> Void)
    // TestnetPaymaster returns the testnet paymaster address if available, or nil.
    func getTestnetPaymaster(_ completion: @escaping (Result<String>) -> Void)
    // BridgeContracts returns the addresses of the default zkSync Era bridge
    // contracts on both L1 and L2.
    func bridgeContracts(_ completion: @escaping (Result<BridgeAddresses>) -> Void)
    // ContractAccountInfo returns the version of the supported account abstraction
    // and nonce ordering from a given contract address.
//111    ContractAccountInfo(ctx context.Context, address common.Address) (*zkTypes.ContractAccountInfo, error)
    
    // L1ChainID returns the chain id of the underlying L1.
    func L1ChainId(_ completion: @escaping (Result<BigUInt>) -> Void)
    // L1BatchNumber returns the latest L1 batch number.
//111    L1BatchNumber(ctx context.Context) (*big.Int, error)
    // L1BatchBlockRange returns the range of blocks contained within a batch given
    // by batch number.
//111    L1BatchBlockRange(ctx context.Context, l1BatchNumber *big.Int) (*BlockRange, error)
    // L1BatchDetails returns data pertaining to a given batch.
//111    L1BatchDetails(ctx context.Context, l1BatchNumber *big.Int) (*zkTypes.BatchDetails, error)
    // BlockDetails returns additional zkSync Era-specific information about the L2
    // block.
    func blockDetails(_ blockNumber: BigUInt, returnFullTransactionObjects: Bool, completion: @escaping (Result<BlockDetails>) -> Void)
    // TransactionDetails returns data from a specific transaction given by the
    // transaction hash.
    func transactionDetails(_ transactionHash: String, completion: @escaping (Result<TransactionDetails>) -> Void)
    // LogProof returns the proof for a transaction's L2 to L1 log sent via the
    // L1Messenger system contract.
//111    LogProof(ctx context.Context, txHash common.Hash, logIndex int) (*zkTypes.MessageProof, error)
    // Deprecated: Deprecated in favor of LogProof.
//111    MsgProof(ctx context.Context, block uint32, sender common.Address, msg common.Hash) (*zkTypes.MessageProof, error)
    // L2TransactionFromPriorityOp returns transaction on L2 network from transaction
    // receipt on L1 network.
//111    L2TransactionFromPriorityOp(ctx context.Context, l1TxReceipt *types.Receipt) (*zkTypes.TransactionResponse, error)
    
    // ConfirmedTokens returns [address, symbol, name, and decimal] information of
    // all tokens within a range of ids given by parameters from and limit.
    func confirmedTokens(_ from: Int, limit: Int, completion: @escaping (Result<[Token]>) -> Void)
    // Deprecated: Method is deprecated and will be removed in the near future.
    func tokenPrice(_ tokenAddress: String, completion: @escaping (Result<Decimal>) -> Void)
    // L2TokenAddress returns the L2 token address equivalent for a L1 token address
    // as they are not equal. ETH address is set to zero address.
//111    L2TokenAddress(ctx context.Context, token common.Address) (common.Address, error)
    // L1TokenAddress returns the L1 token address equivalent for a L2 token address
    // as they are not equal. ETH address is set to zero address.
//111    L1TokenAddress(ctx context.Context, token common.Address) (common.Address, error)
    // AllAccountBalances returns all balances for confirmed tokens given by an
    // account address.
    func allAccountBalances(_ address: String, completion: @escaping (Result<Dictionary<String, String>>) -> Void)
    
    // EstimateFee Returns the fee for the transaction.
    func estimateFee(_ transaction: EthereumTransaction) -> Promise<Fee>
    // EstimateGasL1 estimates the amount of gas required to submit a transaction
    // from L1 to L2.
    func estimateGasL1(_ transaction: EthereumTransaction) -> Promise<Fee>
    // EstimateGasTransfer estimates the amount of gas required for a transfer
    // transaction.
//111    EstimateGasTransfer(ctx context.Context, msg TransferCallMsg) (uint64, error)
    // EstimateGasWithdraw estimates the amount of gas required for a withdrawal
    // transaction.
//111    EstimateGasWithdraw(ctx context.Context, msg WithdrawalCallMsg) (uint64, error)
    // EstimateL1ToL2Execute estimates the amount of gas required for an L1 to L2
    // execute operation.
//111    EstimateL1ToL2Execute(ctx context.Context, msg zkTypes.CallMsg) (uint64, error)
}
