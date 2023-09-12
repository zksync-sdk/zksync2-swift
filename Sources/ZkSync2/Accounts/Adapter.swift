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
//111    BalanceL1(opts *CallOpts, token common.Address) (*big.Int, error)
    // AllowanceL1 returns the amount of approved tokens for a specific L1 bridge.
//111    AllowanceL1(opts *CallOpts, token common.Address, bridgeAddress common.Address) (*big.Int, error)
    // L2TokenAddress returns the corresponding address on the L2 network for the token on the L1 network.
//111    L2TokenAddress(ctx context.Context, token common.Address) (common.Address, error)
    // ApproveERC20 approves the specified amount of tokens for the specified L1 bridge.
//111    ApproveERC20(auth *TransactOpts, token common.Address, amount *big.Int, bridgeAddress common.Address) (*types.Transaction, error)
    // BaseCost returns base cost for L2 transaction.
//111    BaseCost(opts *CallOpts, gasLimit, gasPerPubdataByte, gasPrice *big.Int) (*big.Int, error)
    // Deposit transfers the specified token from the associated account on the L1 network
    // to the target account on the L2 network. The token can be either ETH or any ERC20 token.
    // For ERC20 tokens, enough approved tokens must be associated with the specified L1 bridge
    // (default one or the one defined in DepositTransaction.BridgeAddress). In this case,
    // DepositTransaction.ApproveERC20 can be enabled to perform token approval.
    // If there are already enough approved tokens for the L1 bridge, token approval will be skipped.
    // To check the amount of approved tokens for a specific bridge, use the AdapterL1.AllowanceL1 method.
//111    Deposit(auth *TransactOpts, tx DepositTransaction) (*types.Transaction, error)
    func deposit(_ to: String, amount: BigUInt) -> Promise<TransactionSendingResult>
    func deposit(_ to: String, amount: BigUInt, token: Token) -> Promise<TransactionSendingResult>
    func deposit(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
    // EstimateGasDeposit estimates the amount of gas required for a deposit transaction on L1 network.
    // Gas of approving ERC20 token is not included in estimation.
//111    EstimateGasDeposit(ctx context.Context, msg DepositCallMsg) (uint64, error)
    // FullRequiredDepositFee retrieves the full needed ETH fee for the deposit on both L1 and L2 networks.
//111    FullRequiredDepositFee(ctx context.Context, msg DepositCallMsg) (*FullDepositFee, error)
    // FinalizeWithdraw proves the inclusion of the L2 -> L1 withdrawal message.
//111    FinalizeWithdraw(auth *TransactOpts, withdrawalHash common.Hash, index int) (*types.Transaction, error)
    // IsWithdrawFinalized checks if the withdrawal finalized on L1 network.
//111    IsWithdrawFinalized(opts *CallOpts, withdrawalHash common.Hash, index int) (bool, error)
    // ClaimFailedDeposit withdraws funds from the initiated deposit, which failed when finalizing on L2.
    // If the deposit L2 transaction has failed, it sends an L1 transaction calling ClaimFailedDeposit method
    // of the L1 bridge, which results in returning L1 tokens back to the depositor, otherwise throws the error.
//111    ClaimFailedDeposit(auth *TransactOpts, depositHash common.Hash) (*types.Transaction, error)
    // RequestExecute request execution of L2 transaction from L1.
//111    RequestExecute(auth *TransactOpts, tx RequestExecuteTransaction) (*types.Transaction, error)
    // EstimateGasRequestExecute estimates the amount of gas required for a request execute transaction.
//111    EstimateGasRequestExecute(ctx context.Context, msg RequestExecuteCallMsg) (uint64, error)
}

// AdapterL2 is associated with an account and provides common operations on the
// L2 network for the associated account.
public protocol AdapterL2 {
    // Balance returns the balance of the specified token that can be either ETH or any ERC20 token.
    // The block number can be nil, in which case the balance is taken from the latest known block.
//111    Balance(ctx context.Context, token common.Address, at *big.Int) (*big.Int, error)
    // AllBalances returns all balances for confirmed tokens given by an associated
    // account.
//111    AllBalances(ctx context.Context) (map[common.Address]*big.Int, error)
    // L2BridgeContracts returns L2 bridge contracts.
//111    L2BridgeContracts(ctx context.Context) (*zkTypes.L2BridgeContracts, error)
    // Withdraw initiates the withdrawal process which withdraws ETH or any ERC20
    // token from the associated account on L2 network to the target account on L1
    // network.
//111    Withdraw(auth *TransactOpts, tx WithdrawalTransaction) (*types.Transaction, error)
    func withdraw(_ to: String, amount: BigUInt) -> Promise<TransactionSendingResult>
    func withdraw(_ to: String, amount: BigUInt, token: Token) -> Promise<TransactionSendingResult>
    func withdraw(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
    // EstimateGasWithdraw estimates the amount of gas required for a withdrawal
    // transaction.
//111    EstimateGasWithdraw(ctx context.Context, msg WithdrawalCallMsg) (uint64, error)
    // Transfer moves the ETH or any ERC20 token from the associated account to the
    // target account.
//111    Transfer(auth *TransactOpts, tx TransferTransaction) (*types.Transaction, error)
    func transfer(_ to: String, amount: BigUInt) -> Promise<TransactionSendingResult>
    func transfer(_ to: String, amount: BigUInt, token: Token) -> Promise<TransactionSendingResult>
    func transfer(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
    // EstimateGasTransfer estimates the amount of gas required for a transfer
    // transaction.
//111    EstimateGasTransfer(ctx context.Context, msg TransferCallMsg) (uint64, error)
    // CallContract executes a message call for EIP-712 transaction, which is
    // directly executed in the VM of the node, but never mined into the blockchain.
    //
    // blockNumber selects the block height at which the call runs. It can be nil, in
    // which case the code is taken from the latest known block. Note that state from
    // very old blocks might not be available.
//111    CallContract(ctx context.Context, msg CallMsg, blockNumber *big.Int) ([]byte, error)
    // PopulateTransaction is designed for users who prefer a simplified approach by
    // providing only the necessary data to create a valid transaction. The only
    // required fields are Transaction.To and either Transaction.Data or
    // Transaction.Value (or both, if the method is payable). Any other fields that
    // are not set will be prepared by this method.
//111    PopulateTransaction(ctx context.Context, tx Transaction) (*zkTypes.Transaction712, error)
    // SignTransaction returns a signed transaction that is ready to be broadcast to
    // the network. The input transaction must be a valid transaction with all fields
    // having appropriate values. To obtain a valid transaction, you can use the
    // PopulateTransaction method.
//111    SignTransaction(tx *zkTypes.Transaction712) ([]byte, error)
    // SendTransaction injects a transaction into the pending pool for execution. Any
    // unset transaction fields are prepared using the PopulateTransaction method.
//111    SendTransaction(ctx context.Context, tx *Transaction) (common.Hash, error)
}

// Deployer is associated with an account and provides deployment of smart contracts
// and smart accounts on L2 network for the associated account.
public protocol Deployer {
    // Deploy deploys smart contract using CREATE2 opcode.
//111    Deploy(auth *TransactOpts, tx Create2Transaction) (common.Hash, error)
    func deploy(_ bytecode: Data) -> Promise<TransactionSendingResult>
    func deploy(_ bytecode: Data, calldata: Data?) -> Promise<TransactionSendingResult>
    func deploy(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
    // DeployWithCreate deploys smart contract using CREATE opcode.
//111    DeployWithCreate(auth *TransactOpts, tx CreateTransaction) (common.Hash, error)
    // DeployAccount deploys smart account using CREATE2 opcode.
//111    DeployAccount(auth *TransactOpts, tx Create2Transaction) (common.Hash, error)
    // DeployAccountWithCreate deploys smart account using CREATE opcode.
//111    DeployAccountWithCreate(auth *TransactOpts, tx CreateTransaction) (common.Hash, error)
}
