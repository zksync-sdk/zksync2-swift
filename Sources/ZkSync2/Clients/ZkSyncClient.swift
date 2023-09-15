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
import Web3Core
#else
import web3swift_zksync2
#endif

public protocol ZkSyncClient {
    var web3: Web3 { get set }
    
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
    func contractAccountInfo()
    
    // L1ChainID returns the chain id of the underlying L1.
    func L1ChainId(_ completion: @escaping (Result<BigUInt>) -> Void)
    // L1BatchNumber returns the latest L1 batch number.
    func l1BatchNumber(_ completion: @escaping (Result<String>) -> Void)
    // L1BatchBlockRange returns the range of blocks contained within a batch given
    // by batch number.
    func l1BatchBlockRange(l1BatchNumber: BigUInt, _ completion: @escaping (Result<String>) -> Void)
    // L1BatchDetails returns data pertaining to a given batch.
    func l1BatchDetails(l1BatchNumber: BigUInt, _ completion: @escaping (Result<String>) -> Void)
    // BlockDetails returns additional zkSync Era-specific information about the L2
    // block.
    func blockDetails(_ blockNumber: BigUInt, returnFullTransactionObjects: Bool, completion: @escaping (Result<BlockDetails>) -> Void)
    // TransactionDetails returns data from a specific transaction given by the
    // transaction hash.
    func transactionDetails(_ transactionHash: String, completion: @escaping (Result<TransactionDetails>) -> Void)
    // LogProof returns the proof for a transaction's L2 to L1 log sent via the
    // L1Messenger system contract.
    func logProof(txHash: Data, logIndex: BigUInt, _ completion: @escaping (Result<String>) -> Void)
    // Deprecated: Deprecated in favor of LogProof.
    func msgProof(block: BigUInt, sender: String, _ completion: @escaping (Result<String>) -> Void)
    
    // ConfirmedTokens returns [address, symbol, name, and decimal] information of
    // all tokens within a range of ids given by parameters from and limit.
    func confirmedTokens(_ from: Int, limit: Int, completion: @escaping (Result<[Token]>) -> Void)
    // Deprecated: Method is deprecated and will be removed in the near future.
    func tokenPrice(_ tokenAddress: String, completion: @escaping (Result<Decimal>) -> Void)
    // L2TokenAddress returns the L2 token address equivalent for a L1 token address
    // as they are not equal. ETH address is set to zero address.
    func l2TokenAddress()
    // L1TokenAddress returns the L1 token address equivalent for a L2 token address
    // as they are not equal. ETH address is set to zero address.
    func l1TokenAddress()
    // AllAccountBalances returns all balances for confirmed tokens given by an
    // account address.
    func allAccountBalances(_ address: String, completion: @escaping (Result<Dictionary<String, String>>) -> Void)
    
    // EstimateFee Returns the fee for the transaction.
    func estimateFee(_ transaction: CodableTransaction) async throws -> Fee
    // EstimateGasL1 estimates the amount of gas required to submit a transaction
    // from L1 to L2.
    func estimateGasL1(_ transaction: CodableTransaction) -> Promise<Fee>
    // EstimateGasTransfer estimates the amount of gas required for a transfer
    // transaction.
    func estimateGasTransfer(_ transaction: CodableTransaction) -> Promise<BigUInt>
    // EstimateGasWithdraw estimates the amount of gas required for a withdrawal
    // transaction.
    func estimateGasWithdraw(_ transaction: CodableTransaction) -> Promise<BigUInt>
    // EstimateL1ToL2Execute estimates the amount of gas required for an L1 to L2
    // execute operation.
    func estimateL1ToL2Execute(_ transaction: CodableTransaction) -> Promise<BigUInt>
}
