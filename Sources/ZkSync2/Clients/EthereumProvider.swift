//
//  EthereumProvider.swift
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

protocol EthereumProvider {
    //111
    var l1ERC20BridgeAddress: String { get }
    //111
    var mainContractAddress: String { get }
    //111
    func transfer(with token: Token, amount: BigUInt, to address: String) throws -> Promise<TransactionSendingResult>
    //111
    func withdraw(with token: Token, amount: BigUInt, from userAddress: String) throws -> Promise<TransactionSendingResult>
    
//111    GetClient() *ethclient.Client
//111    GetAddress() common.Address
//111    ApproveDeposit(token *zkTypes.Token, limit *big.Int, options *GasOptions) (*types.Transaction, error)
    func approveDeposit(with token: Token, limit: BigUInt?) throws -> Promise<TransactionSendingResult>
//111    IsDepositApproved(token *zkTypes.Token, to common.Address, threshold *big.Int) (bool, error)
    func isDepositApproved(with token: Token, address: String, threshold: BigUInt?) throws -> Bool
//111    Deposit(token *zkTypes.Token, amount *big.Int, address common.Address, options *GasOptions) (*types.Transaction, error)
    func deposit(with token: Token, amount: BigUInt, operatorTips: BigUInt, to userAddress: String) throws -> Promise<TransactionSendingResult>
//111    RequestExecute(contractL2 common.Address, l2Value *big.Int, calldata []byte, l2GasLimit *big.Int, l2GasPerPubdataByteLimit *big.Int, factoryDeps [][]byte, refundRecipient common.Address, auth *bind.TransactOpts) (*types.Transaction, error)
    func requestExecute(_ contractAddress: String, l2Value: BigUInt, calldata: Data, gasLimit: BigUInt, factoryDeps: [Data]?, operatorTips: BigUInt?, gasPrice: BigUInt?, refundRecipient: String) throws -> Promise<TransactionSendingResult>
//111    FinalizeEthWithdrawal(l2BlockNumber *big.Int, l2MessageIndex *big.Int, l2TxNumberInBlock *big.Int, message []byte, proof []common.Hash, options *GasOptions) (*types.Transaction, error)
//111    FinalizeWithdrawal(l1BridgeAddress common.Address, l2BlockNumber *big.Int, l2MessageIndex *big.Int, l2TxNumberInBlock *big.Int, message []byte, proof []common.Hash, options *GasOptions) (*types.Transaction, error)
//111    IsEthWithdrawalFinalized(l2BlockNumber *big.Int, l2MessageIndex *big.Int) (bool, error)
//111    IsWithdrawalFinalized(l1BridgeAddress common.Address, l2BlockNumber *big.Int, l2MessageIndex *big.Int) (bool, error)
//111    ClaimFailedDeposit(l1BridgeAddress common.Address, depositSender common.Address, l1Token common.Address, l2TxHash common.Hash, l2BlockNumber *big.Int, l2MessageIndex *big.Int, l2TxNumberInBlock *big.Int, proof []common.Hash, options *GasOptions) (*types.Transaction, error)
//111    GetL2HashFromPriorityOp(l1Receipt *types.Receipt) (common.Hash, error)
//111    GetBaseCost(l2GasLimit *big.Int, l2GasPerPubdataByteLimit *big.Int, gasPrice *big.Int) (*big.Int, error)
    func getBaseCost(_ gasLimit: BigUInt, gasPerPubdataByte: BigUInt, gasPrice: BigUInt?) throws -> Promise<[String: Any]>
//111    WaitMined(ctx context.Context, txHash common.Hash) (*types.Transaction, error)
}
