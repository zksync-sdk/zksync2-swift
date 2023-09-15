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
#else
import web3swift_zksync2
#endif

// AdapterL1 is associated with an account and provides common operations on the
// L1 network for the associated account.
public protocol AdapterL1 {
    // MainContract returns the zkSync L1 smart contract.
    func mainContract(callback: @escaping ((web3.web3contract) -> Void))
    // L1BridgeContracts returns L1 bridge contracts.
    func L1BridgeContracts(callback: @escaping ((Result<BridgeAddresses>) -> Void))
    // BalanceL1 returns the balance of the specified token on L1 that can be
    // either ETH or any ERC20 token.
    func balanceL1(token: Token) -> Promise<BigUInt>
    // AllowanceL1 returns the amount of approved tokens for a specific L1 bridge.
    func allowanceL1()
    // L2TokenAddress returns the corresponding address on the L2 network for the token on the L1 network.
    func l2TokenAddress()
    // ApproveERC20 approves the specified amount of tokens for the specified L1 bridge.
    func approveERC20()
    // BaseCost returns base cost for L2 transaction.
    func baseCost()
    // Deposit transfers the specified token from the associated account on the L1 network
    // to the target account on the L2 network. The token can be either ETH or any ERC20 token.
    // For ERC20 tokens, enough approved tokens must be associated with the specified L1 bridge
    // (default one or the one defined in DepositTransaction.BridgeAddress). In this case,
    // DepositTransaction.ApproveERC20 can be enabled to perform token approval.
    // If there are already enough approved tokens for the L1 bridge, token approval will be skipped.
    // To check the amount of approved tokens for a specific bridge, use the AdapterL1.AllowanceL1 method.
    func deposit(_ to: String, amount: BigUInt) -> Promise<TransactionSendingResult>
    func deposit(_ to: String, amount: BigUInt, token: Token) -> Promise<TransactionSendingResult>
    func deposit(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
    // EstimateGasDeposit estimates the amount of gas required for a deposit transaction on L1 network.
    // Gas of approving ERC20 token is not included in estimation.
    func estimateGasDeposit()
    // FullRequiredDepositFee retrieves the full needed ETH fee for the deposit on both L1 and L2 networks.
    func fullRequiredDepositFee()
    // FinalizeWithdraw proves the inclusion of the L2 -> L1 withdrawal message.
    func finalizeWithdraw()
    // IsWithdrawFinalized checks if the withdrawal finalized on L1 network.
    func isWithdrawFinalized()
    // ClaimFailedDeposit withdraws funds from the initiated deposit, which failed when finalizing on L2.
    // If the deposit L2 transaction has failed, it sends an L1 transaction calling ClaimFailedDeposit method
    // of the L1 bridge, which results in returning L1 tokens back to the depositor, otherwise throws the error.
    func claimFailedDeposit()
    // RequestExecute request execution of L2 transaction from L1.
    func requestExecute()
    // EstimateGasRequestExecute estimates the amount of gas required for a request execute transaction.
    func estimateGasRequestExecute()
}

// AdapterL2 is associated with an account and provides common operations on the
// L2 network for the associated account.
public protocol AdapterL2 {
    // Balance returns the balance of the specified token that can be either ETH or any ERC20 token.
    // The block number can be nil, in which case the balance is taken from the latest known block.
    func balance()
    // AllBalances returns all balances for confirmed tokens given by an associated
    // account.
    func allBalances()
    // L2BridgeContracts returns L2 bridge contracts.
    func l2BridgeContracts()
    // Withdraw initiates the withdrawal process which withdraws ETH or any ERC20
    // token from the associated account on L2 network to the target account on L1
    // network.
    func withdraw(_ to: String, amount: BigUInt) -> Promise<TransactionSendingResult>
    func withdraw(_ to: String, amount: BigUInt, token: Token) -> Promise<TransactionSendingResult>
    func withdraw(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
    // EstimateGasWithdraw estimates the amount of gas required for a withdrawal
    // transaction.
    func estimateGasWithdraw(_ transaction: EthereumTransaction) -> Promise<BigUInt>
    // Transfer moves the ETH or any ERC20 token from the associated account to the
    // target account.
    func transfer(_ to: String, amount: BigUInt) -> Promise<TransactionSendingResult>
    func transfer(_ to: String, amount: BigUInt, token: Token) -> Promise<TransactionSendingResult>
    func transfer(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
    // EstimateGasTransfer estimates the amount of gas required for a transfer
    // transaction.
    func estimateGasTransfer(_ transaction: EthereumTransaction) -> Promise<BigUInt>
    // CallContract executes a message call for EIP-712 transaction, which is
    // directly executed in the VM of the node, but never mined into the blockchain.
    //
    // blockNumber selects the block height at which the call runs. It can be nil, in
    // which case the code is taken from the latest known block. Note that state from
    // very old blocks might not be available.
    func callContract(_ transaction: EthereumTransaction, blockNumber: BigUInt?, completion: @escaping (Result<Data>) -> Void)
    // PopulateTransaction is designed for users who prefer a simplified approach by
    // providing only the necessary data to create a valid transaction. The only
    // required fields are Transaction.To and either Transaction.Data or
    // Transaction.Value (or both, if the method is payable). Any other fields that
    // are not set will be prepared by this method.
    func populateTransaction(_ transaction: inout EthereumTransaction)
    // SignTransaction returns a signed transaction that is ready to be broadcast to
    // the network. The input transaction must be a valid transaction with all fields
    // having appropriate values. To obtain a valid transaction, you can use the
    // PopulateTransaction method.
    func signTransaction(_ transaction: inout EthereumTransaction)
    // SendTransaction injects a transaction into the pending pool for execution. Any
    // unset transaction fields are prepared using the PopulateTransaction method.
    func sendTransaction(_ transaction: EthereumTransaction, transactionOptions: TransactionOptions, completion: @escaping (Result<TransactionSendingResult>) -> Void)
}

// Deployer is associated with an account and provides deployment of smart contracts
// and smart accounts on L2 network for the associated account.
public protocol Deployer {
    // Deploy deploys smart contract using CREATE2 opcode.
    func deploy(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
    // DeployWithCreate deploys smart contract using CREATE opcode.
    func deployWithCreate(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
    // DeployAccount deploys smart account using CREATE2 opcode.
    func deployAccount(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
    // DeployAccountWithCreate deploys smart account using CREATE opcode.
    func deployAccountWithCreate(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
}
