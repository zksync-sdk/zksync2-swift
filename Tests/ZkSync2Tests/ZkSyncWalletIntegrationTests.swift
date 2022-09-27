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
        
    }
    
    func testDeploy() {
        
    }
    
    func testDeployWithConstructor() {
        
    }
    
    func testExecute() {
        
    }
}
