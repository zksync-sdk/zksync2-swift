//
//  ZkSyncWalletIntegrationTests.swift
//  ZkSync2Tests
//
//  Created by Maxim Makhun on 7/26/22.
//

import XCTest
import web3swift
@testable import ZkSync2

class ZkSyncWalletIntegrationTests: XCTestCase {
    
    static let L1NodeUrl = URL(string: "http://206.189.96.247:8545")!
    static let L2NodeUrl = URL(string: "http://206.189.96.247:3050")!
    
    var zkSync: ZkSync!
    
    var wallet: ZKSyncWallet!
    
    override func setUpWithError() throws {
        guard let web3 = try? Web3.new(ZkSyncWalletIntegrationTests.L2NodeUrl) else {
            XCTFail("web3 should be valid.")
            return
        }
        
        zkSync = JsonRpc2_0ZkSync(web3,
                                  transport: HTTPTransport(ZkSyncWalletIntegrationTests.L2NodeUrl))
        
        let ethSigner: EthSigner = PrivateKeyEthSigner("")
        
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
        
    }
    
    func testDeploy() {
        
    }
    
    func testDeployWithConstructor() {
        
    }
    
    func testExecute() {
        
    }
}
