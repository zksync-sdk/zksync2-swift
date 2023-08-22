//
//  ZkSyncWalletIntegrationTests.swift
//  ZkSync2Tests
//
//  Created by Maxim Makhun on 7/26/22.
//

import XCTest
import web3swift
import BigInt
import PromiseKit
@testable import ZkSync2

class ZkSyncWalletIntegrationTests: XCTestCase {
    
    static let L1NodeUrl = URL(string: "https://rpc.ankr.com/eth_goerli")!
    static let L2NodeUrl = URL(string: "https://zksync2-testnet.zksync.dev")!
    
    let credentials = Credentials(BigUInt.one)
    
    var wallet: ZkSyncWallet!
    
    override func setUpWithError() throws {
        let expectation = expectation(description: "Expectation.")
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let zkSync = JsonRpc2_0ZkSync(ZkSyncWalletIntegrationTests.L2NodeUrl)
            
            let chainId = try! zkSync.web3.eth.getChainIdPromise().wait()
            
            let signer = PrivateKeyEthSigner(self.credentials,
                                             chainId: chainId)
            
            self.wallet = ZkSyncWallet(zkSync,
                                       ethSigner: signer,
                                       feeToken: Token.ETH)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testBalance() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let web3 = try! Web3.new(ZkSyncWalletIntegrationTests.L1NodeUrl)
            
            let balanceL1 = try! web3.eth.getBalance(address: self.credentials.ethereumAddress)
            print("Balance (L1, \(self.credentials.address)): \(balanceL1)")
            
            let balanceL2 = try! self.wallet.zkSync.web3.eth.getBalance(address: self.credentials.ethereumAddress,
                                                                        onBlock: ZkBlockParameterName.committed.rawValue)
            print("Balance (L2, \(self.credentials.address)): \(balanceL2)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }
    
    func testSendTestMoney() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let web3 = try! Web3.new(ZkSyncWalletIntegrationTests.L1NodeUrl)
            let account = try! web3.eth.getAccountsPromise().wait().first!
            
            let value = Web3.Utils.parseToBigUInt("1000", units: .eth)!
            XCTAssertEqual(value.toHexString().addHexPrefix(), "0x3635c9adc5dea00000")
            
            let chainID = try! web3.eth.getChainIdPromise().wait()
            
            let sent = EthereumTransaction.createEtherTransaction(from: account,
                                                                  nonce: nil,
                                                                  gasPrice: BigUInt.zero,
                                                                  gasLimit: BigUInt(21_000),
                                                                  to: self.credentials.ethereumAddress,
                                                                  value: value,
                                                                  chainID: chainID)
            
            let transactionSendingResult = try! web3.eth.sendTransactionPromise(sent).wait()
            print("Transaction hash: \(transactionSendingResult.hash)")
            
            Thread.sleep(forTimeInterval: 1.0)
            
            let transactionReceipt = try! self.wallet.zkSync.web3.eth.getTransactionReceiptPromise(transactionSendingResult.hash).wait()
            print("Transaction receipt: \(transactionReceipt)")
            XCTAssertEqual(transactionReceipt.status, .ok)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDeposit() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let web3 = try! Web3.new(BaseIntegrationEnv.L1NodeUrl)
            
            let amount = Web3.Utils.parseToBigUInt("1", units: .Gwei)!
            
            let gasProvider = DefaultGasProvider()
            
            let defaultEthereumProvider = try! DefaultEthereumProvider.load(self.wallet.zkSync,
                                                                            web3: web3,
                                                                            gasProvider: gasProvider).wait()
            
            let transactionSendingResult = try! defaultEthereumProvider.deposit(with: Token.ETH,
                                                                                amount: amount,
                                                                                operatorTips: BigUInt.zero,
                                                                                to: self.credentials.address).wait()
            
            print("Transaction hash: \(transactionSendingResult.hash)")
            
            Thread.sleep(forTimeInterval: 1.0)
            
            let transactionReceipt = try! self.wallet.zkSync.web3.eth.getTransactionReceiptPromise(transactionSendingResult.hash).wait()
            print("Transaction receipt: \(transactionReceipt)")
            XCTAssertEqual(transactionReceipt.status, .ok)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }
    
    func testTransfer() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let amount = BigUInt(500000000000000000)
            
            let desiredFee = BigUInt(10560).multiplied(by: BigUInt(28572))
            
            let balance = try! self.wallet.zkSync.web3.eth.getBalancePromise(address: self.credentials.ethereumAddress,
                                                                             onBlock: ZkBlockParameterName.committed.rawValue).wait()
            print("Balance: \(balance)")
            
            let transactionSendingResult = try! self.wallet.transfer(self.credentials.address, amount: amount).wait()
            
            Thread.sleep(forTimeInterval: 1.0)
            
            let transactionReceipt = try! self.wallet.zkSync.web3.eth.getTransactionReceiptPromise(transactionSendingResult.hash).wait()
            print("Transaction receipt: \(transactionReceipt)")
            XCTAssertEqual(transactionReceipt.status, .ok)
            
            let balanceNow = try! self.wallet.zkSync.web3.eth.getBalancePromise(address: self.credentials.ethereumAddress,
                                                                                onBlock: ZkBlockParameterName.committed.rawValue).wait()
            
            print("Balance now: \(balance)")
            
            XCTAssertEqual(balanceNow, balance.subtracting(amount).subtracting(desiredFee))
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }
    
    func testWithdraw() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let amount = BigUInt(500000000000000000)
            
            let desiredFee = BigUInt(10560).multiplied(by: BigUInt(28572))
            
            let balance = try! self.wallet.zkSync.web3.eth.getBalancePromise(address: self.credentials.ethereumAddress,
                                                                             onBlock: ZkBlockParameterName.committed.rawValue).wait()
            print("Balance: \(balance)")
            
            let transactionSendingResult = try! self.wallet.withdraw(self.credentials.address, amount: amount).wait()
            
            Thread.sleep(forTimeInterval: 1.0)
            
            let transactionReceipt = try! self.wallet.zkSync.web3.eth.getTransactionReceiptPromise(transactionSendingResult.hash).wait()
            print("Transaction receipt: \(transactionReceipt)")
            XCTAssertEqual(transactionReceipt.status, .ok)
            
            let balanceNow = try! self.wallet.zkSync.web3.eth.getBalancePromise(address: self.credentials.ethereumAddress,
                                                                                onBlock: ZkBlockParameterName.committed.rawValue).wait()
            
            print("Balance now: \(balance)")
            
            XCTAssertEqual(balanceNow, balance.subtracting(amount).subtracting(desiredFee))
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }
    
    func testDeploy() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let nonce = try! self.wallet.getNonce().wait()
            XCTAssertEqual(nonce, BigUInt(0))
            
            let contractAddress = ContractUtils.generateContractAddress(address: self.credentials.address,
                                                                        nonce: nonce).toHexString().addHexPrefix()
            
            print("Contract address: \(contractAddress)")
            assert(contractAddress == "0xf2e246bb76df876cef8b38ae84130f4f55de395b")
            
            let code = try! self.wallet.zkSync.web3.eth.getCodePromise(address: EthereumAddress(contractAddress)!,
                                                                       onBlock: DefaultBlockParameterName.pending.rawValue).wait()
            XCTAssertEqual(code, "0x")
            
            let counterContractBinary = Data(fromHex: CounterContract.Binary)!
            
            let transactionSendingResult = try! self.wallet.deploy(counterContractBinary).wait()
            
            Thread.sleep(forTimeInterval: 1.0)
            
            let transactionReceipt = try! self.wallet.zkSync.web3.eth.getTransactionReceiptPromise(transactionSendingResult.hash).wait()
            print("Transaction receipt: \(transactionReceipt)")
            XCTAssertEqual(transactionReceipt.status, .ok)
            
            let codeDeployed = try! self.wallet.zkSync.web3.eth.getCodePromise(address: EthereumAddress(contractAddress)!,
                                                                               onBlock: DefaultBlockParameterName.pending.rawValue).wait()
            print("Deployed code: \(codeDeployed)")
            XCTAssertNotEqual(codeDeployed, "0x")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }
    
    func testDeployWithConstructor() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let nonce = try! self.wallet.getNonce().wait()
            XCTAssertEqual(nonce, BigUInt(0))
            
            let contractAddress = ContractUtils.generateContractAddress(address: self.credentials.address,
                                                                        nonce: nonce).toHexString().addHexPrefix()
            
            print("Contract address: \(contractAddress)")
            assert(contractAddress == "0xf2e246bb76df876cef8b38ae84130f4f55de395b")
            
            let code = try! self.wallet.zkSync.web3.eth.getCodePromise(address: EthereumAddress(contractAddress)!,
                                                                       onBlock: DefaultBlockParameterName.pending.rawValue).wait()
            XCTAssertEqual(code, "0x")
            
            let constructor = ConstructorContract.encodeConstructor(a: BigUInt(42),
                                                                    b: BigUInt(43),
                                                                    shouldRevert: false)
            XCTAssertEqual(constructor.toHexString(), "000000000000000000000000000000000000000000000000000000000000002a000000000000000000000000000000000000000000000000000000000000002b0000000000000000000000000000000000000000000000000000000000000000")
            
            let constructorContractBinaryFileURL = Bundle.module.url(forResource: "constructorContractBinary", withExtension: "hex")!
            let constructorContractContents = try! Data(contentsOf: constructorContractBinaryFileURL)
            
            let transactionSendingResult = try! self.wallet.deploy(constructorContractContents,
                                                                   calldata: constructor).wait()
            
            Thread.sleep(forTimeInterval: 1.0)
            
            let transactionReceipt = try! self.wallet.zkSync.web3.eth.getTransactionReceiptPromise(transactionSendingResult.hash).wait()
            print("Transaction receipt: \(transactionReceipt)")
            XCTAssertEqual(transactionReceipt.status, .ok)
            
            let codeDeployed = try! self.wallet.zkSync.web3.eth.getCodePromise(address: contractAddress,
                                                                               onBlock: DefaultBlockParameterName.pending.rawValue).wait()
            
            print("Code deployed: \(codeDeployed)")
            
            XCTAssertNotEqual("0x", codeDeployed)
            
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.from = self.credentials.ethereumAddress
            
            let to = EthereumAddress(contractAddress)!
            transactionOptions.to = to
            
            let chainID = try! self.wallet.zkSync.web3.eth.getChainIdPromise().wait()
            
            let data = CounterContract.get()
            
            let ethereumParameters = EthereumParameters(from: transactionOptions)
            let transaction = EthereumTransaction(type: .eip1559,
                                                  to: to,
                                                  nonce: BigUInt.zero,
                                                  chainID: chainID,
                                                  value: BigUInt.zero,
                                                  data: data,
                                                  parameters: ethereumParameters)
            
            let after = try! self.wallet.zkSync.web3.eth.callPromise(transaction, transactionOptions: transactionOptions).wait()
            print("Result: \(after)")
            
            XCTAssertEqual(BigUInt(42).multiplied(by: BigUInt(43)), BigUInt(fromHex: after.toHexString().addHexPrefix()))
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }
    
    func testExecute() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let bytecode = Data(fromHex: CounterContract.Binary)!
            
            var transactionSendingResult = try! self.wallet.deploy(bytecode).wait()
            
            Thread.sleep(forTimeInterval: 1.0)
            
            var transactionReceipt = try! self.wallet.zkSync.web3.eth.getTransactionReceiptPromise(transactionSendingResult.hash).wait()
            print("Transaction receipt: \(transactionReceipt)")
            XCTAssertEqual(transactionReceipt.status, .ok)
            
            let contractAddress = transactionReceipt.contractAddress!
            
            print("contractAddress: \(contractAddress.address)")
            
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.from = self.credentials.ethereumAddress
            
            let to = contractAddress
            transactionOptions.to = to
            
            let chainID = try! self.wallet.zkSync.web3.eth.getChainIdPromise().wait()
            
            let data = CounterContract.get()
            
            var ethereumParameters = EthereumParameters(from: transactionOptions)
            var transaction = EthereumTransaction(type: .eip1559,
                                                  to: to,
                                                  nonce: BigUInt.zero,
                                                  chainID: chainID,
                                                  value: BigUInt.zero,
                                                  data: data,
                                                  parameters: ethereumParameters)
            
            let before = try! self.wallet.zkSync.web3.eth.callPromise(transaction, transactionOptions: transactionOptions).wait()
            print("Result: \(before)")
            
            XCTAssertEqual(BigUInt.zero, BigUInt(fromHex: before.toHexString().addHexPrefix()))
            
            transactionSendingResult = try! self.wallet.execute(contractAddress.address,
                                                                encodedFunction: CounterContract.encodeIncrement(BigUInt(10))).wait()
            
            print("Transaction hash: \(transactionSendingResult.hash)")
            
            Thread.sleep(forTimeInterval: 1.0)
            
            transactionReceipt = try! self.wallet.zkSync.web3.eth.getTransactionReceiptPromise(transactionSendingResult.hash).wait()
            print("Transaction receipt: \(transactionReceipt)")
            XCTAssertEqual(transactionReceipt.status, .ok)
            
            let after = try! self.wallet.zkSync.web3.eth.callPromise(transaction, transactionOptions: transactionOptions).wait()
            print("Result: \(after)")
            
            XCTAssertEqual(BigUInt(10), BigUInt(after))
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }
    
    func testSendMessageL2ToL1() {
        
    }
}
