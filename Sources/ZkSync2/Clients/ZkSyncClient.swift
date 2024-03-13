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
    
    func getL2ToL1LogProof(_ txHash: String, logIndex: Int) async throws -> L2ToL1MessageProof
    
    // MainContractAddress returns the address of the zkSync Era contract.
    func mainContract() async throws -> String
    // TestnetPaymaster returns the testnet paymaster address if available, or nil.
    func getTestnetPaymaster() async throws -> String
    // BridgeContracts returns the addresses of the default zkSync Era bridge
    // contracts on both L1 and L2.
    func bridgeContracts() async throws -> BridgeAddresses
    
    // L1ChainID returns the chain id of the underlying L1.
    func L1ChainId() async throws -> BigUInt
    // L1BatchNumber returns the latest L1 batch number.
    func l1BatchNumber() async throws -> String
    // L1BatchBlockRange returns the range of blocks contained within a batch given
    // by batch number.
    func l1BatchBlockRange(l1BatchNumber: BigUInt) async throws -> String
    // L1BatchDetails returns data pertaining to a given batch.
    func l1BatchDetails(l1BatchNumber: BigUInt) async throws -> String
    // BlockDetails returns additional zkSync Era-specific information about the L2
    // block.
    func blockDetails(_ blockNumber: BigUInt, returnFullTransactionObjects: Bool) async throws -> BlockDetails
    // TransactionDetails returns data from a specific transaction given by the
    // transaction hash.
    func transactionDetails(_ txHash: String) async throws -> TransactionDetails
    // LogProof returns the proof for a transaction's L2 to L1 log sent via the
    // L1Messenger system contract.
    func logProof(txHash: String, logIndex: Int) async throws -> L2ToL1MessageProof
    // Deprecated: Deprecated in favor of LogProof.
    func msgProof(block: BigUInt, sender: String) async throws -> String
    
    // ConfirmedTokens returns [address, symbol, name, and decimal] information of
    // all tokens within a range of ids given by parameters from and limit.
    func confirmedTokens(_ from: Int, limit: Int) async throws -> [Token]
    // Deprecated: Method is deprecated and will be removed in the near future.
    func tokenPrice(_ tokenAddress: String) async throws -> Decimal
    // AllAccountBalances returns all balances for confirmed tokens given by an
    // account address.
    func allAccountBalances(_ address: String) async throws -> Dictionary<String, String>
    
    // EstimateFee Returns the fee for the transaction.
    func estimateFee(_ transaction: CodableTransaction) async throws -> Fee
    // EstimateGasL1 estimates the amount of gas required to submit a transaction
    // from L1 to L2.
    func estimateGasL1(_ transaction: CodableTransaction) async throws -> BigUInt
    func estimateL1ToL2Execute(_ to: String, from: String, calldata: Data, amount: BigUInt, gasPerPubData: BigUInt) async throws -> BigUInt
    // EstimateGasTransfer estimates the amount of gas required for a transfer
    // transaction.
    func estimateGasTransfer(_ transaction: CodableTransaction) async throws -> BigUInt
    // EstimateGasWithdraw estimates the amount of gas required for a withdrawal
    // transaction.
    func estimateGasWithdraw(_ transaction: CodableTransaction) async throws -> BigUInt
    func sendRawTransaction(transaction: String) async throws -> TransactionResponse?
    func getL2HashFromPriorityOp(receipt: TransactionReceipt) async throws -> String?
    func getBalance(address: String, blockNumber: BlockNumber, token: String?) async throws -> BigUInt
    func estimateGas(_ transaction: CodableTransaction) async throws -> BigUInt 
    func l1TokenAddress(address: String) async throws -> String
    func l2TokenAddress(address: String) async throws -> String
}
