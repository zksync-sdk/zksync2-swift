//
//  ZkSyncWalletIntegrationTests.swift
//  ZkSync2Tests
//
//  Created by Maxim Makhun on 7/26/22.
//

import XCTest
import web3swift
import Web3Core
import BigInt
import PromiseKit
@testable import ZkSync2

class ZkSyncWalletIntegrationTests: XCTestCase {
    
    static let L1NodeUrl = URL(string: "http://127.0.0.1:8545")!
    static let L2NodeUrl = URL(string: "http://127.0.0.1:3050")!
    static let PaymasterAddress = "0x594E77D36eB367b3AbAb98775c99eB383079F966"
    static let PaymasterToken = "0x0183Fe07a98bc036d6eb23C3943d823bcD66a90F"
    static let L1DAI = "0x70a0F165d6f8054d0d0CF8dFd4DD2005f0AF6B55"
    
    
    let credentials = Credentials("0x7726827caac94a7f9e1b160f7ea819f172f7b6f9d2a97f992c38edeab82d4110")
    
    var wallet: Wallet!
    var zkSync: ZkSyncClient!
    
    override func setUpWithError() throws {
        let expectation = expectation(description: "Expectation.")
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            self.zkSync = BaseClient(ZkSyncWalletIntegrationTests.L2NodeUrl)
            
            let l1Web3 = EthereumClientImpl(ZkSyncWalletIntegrationTests.L1NodeUrl)
            
            
            let chainId = BigUInt(9)
            
            let signer = BaseSigner(self.credentials,
                                    chainId: chainId)
            let signerL2 = BaseSigner(self.credentials,
                                      chainId: BigUInt(270))
            let walletL1 = WalletL1(zkSync, ethClient: l1Web3, web3: l1Web3.web3, ethSigner: signer)
            let walletL2 = WalletL2(zkSync, ethClient: l1Web3, web3: zkSync.web3, ethSigner: signerL2)
            let baseDeployer = BaseDeployer(adapterL2: walletL2, signer: signerL2)
            self.wallet = Wallet(walletL1: walletL1, walletL2: walletL2, deployer: baseDeployer)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testBalance() async {
        let balanceL1 = await wallet.walletL1.balanceL1()
        XCTAssertNotNil(balanceL1)

        let balanceL2 = try! await wallet.walletL2.getBalance()
        XCTAssertNotNil(balanceL2)
    }
    
    func testBaseCost() async{
        let result = try! await wallet.walletL1.baseCost(BigUInt(100000), gasPrice: nil)
        
        XCTAssertNotNil(result)
    }
    
    func testEstimateRequestExecute() async {
        let mainContractAddress = try! await zkSync.mainContract()
        let txRequest = RequestExecuteTransaction(contractAddress: mainContractAddress, calldata: Data(hex: "0x"), l2Value: BigUInt(7000000000))
        
        let result = try! await wallet.walletL1.estimateRequestExecute(transaction: txRequest)
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result!, BigUInt.zero)
    }
    
    func testDepositETH() async {
        let amount = BigUInt(7000000000)
        
        let l1BalanceBeforeDeposit = await wallet.walletL1.balanceL1()
        let l2BalanceBeforeDeposit = await wallet.walletL2.balance()
        
        let tx = DepositTransaction(token: ZkSyncAddresses.EthAddress, amount: amount)
        let result = try! await wallet.walletL1.deposit(transaction: tx)
        let receipt = try! await wallet.walletL1.ethClient.waitforTransactionReceipt(transactionHash: result.hash, timeout: 120, pollLatency: 0.5)
        let l2Hash = try! await wallet.walletL1.zkSync.getL2HashFromPriorityOp(receipt: receipt!)
        sleep(5)
        let l2receipt = await ZkSyncTransactionReceiptProcessor(zkSync: zkSync).waitForTransactionReceipt(hash: l2Hash!)
        XCTAssertNotNil(l2receipt)
        
        let l1BalanceAfterDeposit = await wallet.walletL1.balanceL1()
        let l2BalanceAfterDeposit = await wallet.walletL2.balance()
        
        XCTAssertGreaterThanOrEqual(l2BalanceAfterDeposit - l2BalanceBeforeDeposit, amount)
        XCTAssertGreaterThanOrEqual(l1BalanceBeforeDeposit - l1BalanceAfterDeposit, amount)
    }
    
    func testDepositERC20() async {
        let amount = BigUInt(10)
        let l2DAI = try! await zkSync.l2TokenAddress(address: ZkSyncWalletIntegrationTests.L1DAI)
        
        let l1BalanceBeforeDeposit = await wallet.walletL1.balanceL1()
        let l2BalanceBeforeDeposit = await wallet.walletL2.balance(token: l2DAI)
        
        let tx = DepositTransaction(token: ZkSyncWalletIntegrationTests.L1DAI, amount: amount, approveERC20: true)
        let result = try! await wallet.walletL1.deposit(transaction: tx)
        let receipt = try! await wallet.walletL1.ethClient.waitforTransactionReceipt(transactionHash: result.hash, timeout: 120, pollLatency: 0.5)
        let l2Hash = try! await wallet.walletL1.zkSync.getL2HashFromPriorityOp(receipt: receipt!)
        sleep(5)
        let l2receipt = await ZkSyncTransactionReceiptProcessor(zkSync: zkSync).waitForTransactionReceipt(hash: l2Hash!)
        
        XCTAssertNotNil(l2receipt)
        let l1BalanceAfterDeposit = await wallet.walletL1.balanceL1()
        let l2BalanceAfterDeposit = await wallet.walletL2.balance()
        
        XCTAssertGreaterThanOrEqual(l2BalanceAfterDeposit - l2BalanceBeforeDeposit, amount)
        XCTAssertGreaterThanOrEqual(l1BalanceBeforeDeposit - l1BalanceAfterDeposit, amount)
    }
    
    func testTransferETH() async {
        let amount = BigUInt(1)
        let balanceBefore = try! await zkSync.getBalance(address: "0xa61464658AfeAf65CccaaFD3a512b69A83B77618", blockNumber: .latest, token: ZkSyncAddresses.EthAddress)
        
        let result = await wallet.walletL2.transfer("0xa61464658AfeAf65CccaaFD3a512b69A83B77618", amount: amount)
        let receipt = await ZkSyncTransactionReceiptProcessor(zkSync: zkSync).waitForTransactionReceipt(hash: result.hash)
        
        XCTAssertNotNil(receipt)
        
        let balanceAfter =  try! await zkSync.getBalance(address: "0xa61464658AfeAf65CccaaFD3a512b69A83B77618", blockNumber: .latest, token: ZkSyncAddresses.EthAddress)
        XCTAssertEqual(balanceAfter - balanceBefore, amount)
    }
    
    func testTransferETHWithPaymaster() async {
        let amount = BigUInt(7000000000)
        
        let paymasterBalanceBefore = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncAddresses.EthAddress)
        let paymasterTokenBalanceBefore = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        let senderBalanceBefore = await wallet.walletL2.balance()
        let senderTokenBalanceBefore = await wallet.walletL2.balance(token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        let paymasterInput = Paymaster.encodeApprovalBased(
            EthereumAddress(ZkSyncWalletIntegrationTests.PaymasterToken)!,
            minimalAllowance: BigUInt(1),
            paymasterInput: Data()
        )
        
        let paymasterParams = PaymasterParams(paymaster: EthereumAddress(ZkSyncWalletIntegrationTests.PaymasterAddress)!, paymasterInput: paymasterInput)
        
        let result = await wallet.walletL2.transfer("0xa61464658AfeAf65CccaaFD3a512b69A83B77618", amount: amount, token: ZkSyncAddresses.EthAddress, options: nil, paymasterParams: paymasterParams)
        let receipt = await ZkSyncTransactionReceiptProcessor(zkSync: zkSync).waitForTransactionReceipt(hash: result.hash)
        
        let paymasterBalanceAfter = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncAddresses.EthAddress)
        let paymasterTokenBalanceAfter = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        let senderBalanceAfter = await wallet.walletL2.balance()
        let senderTokenBalanceAfter = await wallet.walletL2.balance(token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        XCTAssertNotNil(receipt)
        XCTAssertGreaterThanOrEqual(paymasterBalanceBefore - paymasterBalanceAfter, BigUInt.zero)
        XCTAssertEqual(paymasterTokenBalanceAfter - paymasterTokenBalanceBefore, 1)
        XCTAssertEqual(senderBalanceBefore - senderBalanceAfter, amount)
        XCTAssertEqual(senderTokenBalanceBefore - senderTokenBalanceAfter, 1)
    }
    
    func testTransferERC20() async {
        let amount = BigUInt(5)
        let l2DAI = try! await zkSync.l2TokenAddress(address: ZkSyncWalletIntegrationTests.L1DAI)
        let balanceBefore = await wallet.walletL2.balance(token: l2DAI)
        
        let result = await wallet.walletL2.transfer("0xa61464658AfeAf65CccaaFD3a512b69A83B77618", amount: amount, token: l2DAI)
        let receipt = await ZkSyncTransactionReceiptProcessor(zkSync: zkSync).waitForTransactionReceipt(hash: result.hash)
        
        XCTAssertNotNil(receipt)
        
        let balanceAfter = await wallet.walletL2.balance(token: l2DAI)
        XCTAssertEqual(balanceBefore - balanceAfter, amount)
    }
    
    func testTransferERC20WithPaymaster() async {
        let amount = BigUInt(5)
        let l2DAI = try! await zkSync.l2TokenAddress(address: ZkSyncWalletIntegrationTests.L1DAI)
        
        let paymasterBalanceBefore = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncAddresses.EthAddress)
        let paymasterTokenBalanceBefore = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        let senderBalanceBefore = await wallet.walletL2.balance(token: l2DAI)
        let senderTokenBalanceBefore = await wallet.walletL2.balance(token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        let paymasterInput = Paymaster.encodeApprovalBased(
            EthereumAddress(ZkSyncWalletIntegrationTests.PaymasterToken)!,
            minimalAllowance: BigUInt(1),
            paymasterInput: Data()
        )
        
        let paymasterParams = PaymasterParams(paymaster: EthereumAddress(ZkSyncWalletIntegrationTests.PaymasterAddress)!, paymasterInput: paymasterInput)
        
        let result = await wallet.walletL2.transfer("0xa61464658AfeAf65CccaaFD3a512b69A83B77618", amount: amount, token: l2DAI, options: nil, paymasterParams: paymasterParams)
        let receipt = await ZkSyncTransactionReceiptProcessor(zkSync: zkSync).waitForTransactionReceipt(hash: result.hash)
        
        let paymasterBalanceAfter = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncAddresses.EthAddress)
        let paymasterTokenBalanceAfter = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        let senderBalanceAfter = await wallet.walletL2.balance(token: l2DAI)
        let senderTokenBalanceAfter = await wallet.walletL2.balance(token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        XCTAssertNotNil(receipt)
        XCTAssertGreaterThanOrEqual(paymasterBalanceBefore - paymasterBalanceAfter, BigUInt.zero)
        XCTAssertEqual(paymasterTokenBalanceAfter - paymasterTokenBalanceBefore, 1)
        XCTAssertEqual(senderBalanceBefore - senderBalanceAfter, amount)
        XCTAssertEqual(senderTokenBalanceBefore - senderTokenBalanceAfter, 1)
    }
    
    func testWithdrawEth() async {
        let amount = BigUInt(7_000_000_000)
        
        let l2BalanceBefore = await wallet.walletL2.balance()
        
        
        let result = try! await wallet.walletL2.withdraw(amount, to: nil, token: ZkSyncAddresses.EthAddress)
        let receipt = await ZkSyncTransactionReceiptProcessor(zkSync: zkSync).waitForTransactionReceipt(hash: result!.hash)
        XCTAssertNotNil(receipt)
        let isFinalized = await wallet.walletL1.isWithdrawalFinalized(withdrawHash: result!.hash)
        sleep(10)
        XCTAssertFalse(isFinalized)
        _ = try! await wallet.walletL1.finalizeWithdrawal(withdrawalHash: result!.hash)
        
        let l2BalanceAfter = await wallet.walletL2.balance()
        XCTAssertGreaterThanOrEqual(l2BalanceBefore - l2BalanceAfter, amount)
    }
    
    func testWithdrawEthWithPaymaster() async {
        let amount = BigUInt(7_000_000_000)
        
        let paymasterBalanceBefore = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncAddresses.EthAddress)
        let paymasterTokenBalanceBefore = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        let senderBalanceBefore = await wallet.walletL2.balance()
        let senderTokenBalanceBefore = await wallet.walletL2.balance(token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        let paymasterInput = Paymaster.encodeApprovalBased(
            EthereumAddress(ZkSyncWalletIntegrationTests.PaymasterToken)!,
            minimalAllowance: BigUInt(1),
            paymasterInput: Data()
        )
        
        let paymasterParams = PaymasterParams(paymaster: EthereumAddress(ZkSyncWalletIntegrationTests.PaymasterAddress)!, paymasterInput: paymasterInput)
        
        let result = try! await wallet.walletL2.withdraw(amount, to: nil, token: ZkSyncAddresses.EthAddress, paymasterParams: paymasterParams)
        let receipt = await ZkSyncTransactionReceiptProcessor(zkSync: zkSync).waitForTransactionReceipt(hash: result!.hash)
        XCTAssertNotNil(receipt)
        let isFinalized = await wallet.walletL1.isWithdrawalFinalized(withdrawHash: result!.hash)
        XCTAssertFalse(isFinalized)
        sleep(10)
        _ = try! await wallet.walletL1.finalizeWithdrawal(withdrawalHash: result!.hash)
        
        let paymasterBalanceAfter = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncAddresses.EthAddress)
        let paymasterTokenBalanceAfter = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        let senderBalanceAfter = await wallet.walletL2.balance()
        let senderTokenBalanceAfter = await wallet.walletL2.balance(token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        XCTAssertGreaterThanOrEqual(paymasterBalanceBefore - paymasterBalanceAfter, BigUInt.zero)
        XCTAssertEqual(paymasterTokenBalanceAfter - paymasterTokenBalanceBefore, 1)
        XCTAssertEqual(senderBalanceBefore - senderBalanceAfter, amount)
        XCTAssertEqual(senderTokenBalanceBefore - senderTokenBalanceAfter, 1)
    }
    
    func testWithdrawErc20() async {
        let amount = BigUInt(5)
        let l2DAI = try! await zkSync.l2TokenAddress(address: ZkSyncWalletIntegrationTests.L1DAI)
        
        let l2BalanceBefore = await wallet.walletL2.balance(token: l2DAI)
        
        
        let result = try! await wallet.walletL2.withdraw(amount, to: nil, token: l2DAI)
        let receipt = await ZkSyncTransactionReceiptProcessor(zkSync: zkSync).waitForTransactionReceipt(hash: result!.hash)
        XCTAssertNotNil(receipt)
        sleep(10)
        let isFinalized = await wallet.walletL1.isWithdrawalFinalized(withdrawHash: result!.hash)
        XCTAssertFalse(isFinalized)
        _ = try! await wallet.walletL1.finalizeWithdrawal(withdrawalHash: result!.hash)
        
        let l2BalanceAfter = await wallet.walletL2.balance(token: l2DAI)
        XCTAssertGreaterThanOrEqual(l2BalanceBefore - l2BalanceAfter, amount)
    }
    
    
    func skipped_testWithdrawErc20WithPaymaster() async {
        let amount = BigUInt(5)
        let l2DAI = try! await zkSync.l2TokenAddress(address: ZkSyncWalletIntegrationTests.L1DAI)
        
        let paymasterBalanceBefore = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncAddresses.EthAddress)
        let paymasterTokenBalanceBefore = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        let l2BalanceBefore = await wallet.walletL2.balance(token: l2DAI)
        let senderTokenBalanceBefore = await wallet.walletL2.balance(token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        let paymasterInput = Paymaster.encodeApprovalBased(
            EthereumAddress(ZkSyncWalletIntegrationTests.PaymasterToken)!,
            minimalAllowance: BigUInt(1),
            paymasterInput: Data()
        )
        let paymasterParams = PaymasterParams(paymaster: EthereumAddress(ZkSyncWalletIntegrationTests.PaymasterAddress)!, paymasterInput: paymasterInput)
        
        let result = try! await wallet.walletL2.withdraw(amount, to: nil, token: l2DAI, paymasterParams: paymasterParams)
        let receipt = await ZkSyncTransactionReceiptProcessor(zkSync: zkSync).waitForTransactionReceipt(hash: result!.hash)
        XCTAssertNotNil(receipt)
        let isFinalized = await wallet.walletL1.isWithdrawalFinalized(withdrawHash: result!.hash)
        sleep(20)
        XCTAssertFalse(isFinalized)
        _ = try! await wallet.walletL1.finalizeWithdrawal(withdrawalHash: result!.hash)
        
        let paymasterBalanceAfter = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncAddresses.EthAddress)
        let paymasterTokenBalanceAfter = try! await zkSync.getBalance(address: ZkSyncWalletIntegrationTests.PaymasterAddress, blockNumber: .latest, token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        let senderTokenBalanceAfter = await wallet.walletL2.balance(token: ZkSyncWalletIntegrationTests.PaymasterToken)
        
        let l2BalanceAfter = await wallet.walletL2.balance(token: l2DAI)
        XCTAssertGreaterThanOrEqual(paymasterBalanceBefore - paymasterBalanceAfter, BigUInt.zero)
        XCTAssertEqual(paymasterTokenBalanceAfter - paymasterTokenBalanceBefore, 1)
        XCTAssertEqual(senderTokenBalanceBefore - senderTokenBalanceAfter, 1)
        XCTAssertEqual(l2BalanceBefore - l2BalanceAfter, amount)
    }
}
