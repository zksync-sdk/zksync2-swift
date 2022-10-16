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
    
    static let L1NodeUrl = URL(string: "http://206.189.96.247:8545")!
    static let L2NodeUrl = URL(string: "http://206.189.96.247:3050")!
    
//    static let L1NodeUrl = URL(string: "https://goerli.infura.io/v3/25be7ab42c414680a5f89297f8a11a4d")!
//    static let L2NodeUrl = URL(string: "https://zksync2-testnet.zksync.dev")!
    
    var wallet: ZKSyncWallet!
    
    let address = "0x7e5f4552091a69125d5dfcb7b8c2659029395bdf"
    
    override func setUpWithError() throws {
        guard let web3 = try? Web3.new(ZkSyncWalletIntegrationTests.L2NodeUrl) else {
            XCTFail("web3 should be valid.")
            return
        }
        
        let zkSync = JsonRpc2_0ZkSync(web3,
                                      transport: HTTPTransport(ZkSyncWalletIntegrationTests.L2NodeUrl))
        
        let ethSigner: EthSigner = PrivateKeyEthSigner("0x0000000000000000000000000000000000000000000000000000000000000001")
        
        wallet = ZKSyncWallet(web3,
                              zkSync: zkSync,
                              ethSigner: ethSigner)
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testSendMoney() {
        guard let web3 = try? Web3.new(ZkSyncWalletIntegrationTests.L1NodeUrl) else {
            XCTFail("web3 should be valid.")
            return
        }
        
        do {
            let account = try web3.eth.getAccounts().first
            XCTAssertNotNil(account)
        } catch {
            XCTFail()
        }
        
        // web3.eth.sendTransaction(EthereumTransaction, transactionOptions: <#T##TransactionOptions#>)
    }
    
    func testDeposit() {
        
    }
    
    func testTransfer() {
        
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
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }
    
    func testExecute() {
        
    }
}
