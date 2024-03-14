//
//  Adapter.swift
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

// AdapterL1 is associated with an account and provides common operations on the
// L1 network for the associated account.
public protocol AdapterL1 {
    var zkSync: ZkSyncClient { get }
    var ethClient: EthereumClient { get }
    var web: Web3 { get }
    
    func getAddress() async throws -> String
    func approveERC20(token: String, amount: BigUInt?, bridgeAddress: String?) async throws -> TransactionSendingResult
    // MainContract returns the zkSync L1 smart contract.
    func mainContract(transaction: CodableTransaction) async throws -> Web3.Contract
    // L1BridgeContracts returns L1 bridge contracts.
    func L1BridgeContracts() async throws -> BridgeAddresses
    // BalanceL1 returns the balance of the specified token on L1 that can be
    // either ETH or any ERC20 token.
    func balanceL1() async -> BigUInt
    // BaseCost returns base cost for L2 transaction.
    func baseCost(_ gasLimit: BigUInt, gasPerPubdataByte: BigUInt, gasPrice: BigUInt?) async throws -> [String: Any]
    // Deposit transfers the specified token from the associated account on the L1 network
    // to the target account on the L2 network. The token can be either ETH or any ERC20 token.
    // For ERC20 tokens, enough approved tokens must be associated with the specified L1 bridge
    // (default one or the one defined in DepositTransaction.BridgeAddress). In this case,
    // DepositTransaction.ApproveERC20 can be enabled to perform token approval.
    // If there are already enough approved tokens for the L1 bridge, token approval will be skipped.
    // To check the amount of approved tokens for a specific bridge, use the AdapterL1.AllowanceL1 method.
    func deposit(transaction: DepositTransaction) async throws -> TransactionSendingResult
    func estimateGasdepositTransaction(transaction: DepositTransaction) async throws -> BigUInt
    func getDepositTransaction(transaction: DepositTransaction) async throws -> DepositTransaction
    // ClaimFailedDeposit withdraws funds from the initiated deposit, which failed when finalizing on L2.
    // If the deposit L2 transaction has failed, it sends an L1 transaction calling ClaimFailedDeposit method
    // of the L1 bridge, which results in returning L1 tokens back to the depositor, otherwise throws the error.
    func claimFailedDeposit(_ l1BridgeAddress: String, depositSender: String, l1Token: String, l2TxHash: Data, l2BlockNumber: BigUInt, l2MessageIndex: BigUInt, l2TxNumberInBlock: UInt, proof: [Data]) async throws -> TransactionSendingResult
    // RequestExecute request execution of L2 transaction from L1.
    func getRequestExecute(transaction: RequestExecuteTransaction) async throws -> CodableTransaction
    func estimateGasRequestExecute(transaction: RequestExecuteTransaction) async throws -> BigUInt?
    func requestExecute(transaction: RequestExecuteTransaction) async throws -> TransactionSendingResult
    func getAllowanceL1(token: String, bridgeAddress: String?) async throws -> BigUInt
    func isWithdrawalFinalized(withdrawHash: String, index: Int) async -> Bool
    func finalizeWithdrawal(withdrawalHash: String, index: Int, options: TransactionOption?) async throws -> TransactionSendingResult?
    func signTransaction(transaction: inout CodableTransaction)
}

// AdapterL2 is associated with an account and provides common operations on the
// L2 network for the associated account.
public protocol AdapterL2 {
    var zkSync: ZkSyncClient { get }
    var ethClient: EthereumClient { get }
    var web: Web3 { get }
    
    // Balance returns the balance of the specified token that can be either ETH or any ERC20 token.
    // The block number can be nil, in which case the balance is taken from the latest known block.
    func balance(token: String, blockNumber: BlockNumber) async throws -> BigUInt
    // AllBalances returns all balances for confirmed tokens given by an associated
    // account.
    func allBalances(_ address: String) async throws -> Dictionary<String, String>
    // Withdraw initiates the withdrawal process which withdraws ETH or any ERC20
    // token from the associated account on L2 network to the target account on L1
    // network.
    func withdraw(_ amount: BigUInt, to: String?, token: String?, options: TransactionOption?, paymasterParams: PaymasterParams?) async throws -> TransactionSendingResult?
    // Transfer moves the ETH or any ERC20 token from the associated account to the
    // target account.
    func transfer(_ to: String, amount: BigUInt, token: String?, options: TransactionOption?, paymasterParams: PaymasterParams?) async -> TransactionSendingResult
    // CallContract executes a message call for EIP-712 transaction, which is
    // directly executed in the VM of the node, but never mined into the blockchain.
    //
    // blockNumber selects the block height at which the call runs. It can be nil, in
    // which case the code is taken from the latest known block. Note that state from
    // very old blocks might not be available.
    func callContract(_ transaction: CodableTransaction, blockNumber: BigUInt?) async throws -> Data
    // PopulateTransaction is designed for users who prefer a simplified approach by
    // providing only the necessary data to create a valid transaction. The only
    // required fields are Transaction.To and either Transaction.Data or
    // Transaction.Value (or both, if the method is payable). Any other fields that
    // are not set will be prepared by this method.
    func populateTransaction(_ transaction: inout CodableTransaction) async
    // SignTransaction returns a signed transaction that is ready to be broadcast to
    // the network. The input transaction must be a valid transaction with all fields
    // having appropriate values. To obtain a valid transaction, you can use the
    // PopulateTransaction method.
    func signTransaction(_ transaction: CodableTransaction) -> CodableTransaction
    // SendTransaction injects a transaction into the pending pool for execution. Any
    // unset transaction fields are prepared using the PopulateTransaction method.
    func sendTransaction(_ transaction: CodableTransaction) async throws -> TransactionSendingResult
    
    func execute(_ contractAddress: String, encodedFunction: Data, nonce: BigUInt?) async -> TransactionSendingResult
}

// Deployer is associated with an account and provides deployment of smart contracts
// and smart accounts on L2 network for the associated account.
public protocol Deployer {
    // Deploy deploys smart contract using CREATE2 opcode.
    func deploy(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) async -> TransactionSendingResult
    // DeployWithCreate deploys smart contract using CREATE opcode.
    func deployWithCreate(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) async -> TransactionSendingResult
    // DeployAccount deploys smart account using CREATE2 opcode.
    func deployAccount(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) async -> TransactionSendingResult
    // DeployAccountWithCreate deploys smart account using CREATE opcode.
    func deployAccountWithCreate(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) async -> TransactionSendingResult
}

public struct Adapter {
    public var adapterL1: AdapterL1
    public var adapterL2: AdapterL2
    public var deployer: Deployer
    
    public init(adapterL1: AdapterL1, adapterL2: AdapterL2, deployer: Deployer) {
        self.adapterL1 = adapterL1
        self.adapterL2 = adapterL2
        self.deployer = deployer
    }
}
