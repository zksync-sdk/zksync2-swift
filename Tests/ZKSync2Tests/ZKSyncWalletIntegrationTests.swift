//
//  ZKSyncWalletIntegrationTests.swift
//  ZKSync2Tests
//
//  Created by Maxim Makhun on 7/26/22.
//

import XCTest
import web3swift
@testable import ZKSync2

class ZKSyncWalletIntegrationTests: XCTestCase {
    
    static let L1NodeUrl = URL(string: "http://206.189.96.247:8545")!
    static let L2NodeUrl = URL(string: "http://206.189.96.247:3050")!
    
    var zkSync: ZKSync!
    
    var wallet: ZKSyncWallet!
    
    override func setUpWithError() throws {
        guard let web3 = try? Web3.new(ZKSyncWalletIntegrationTests.L2NodeUrl) else {
            XCTFail("web3 should be valid.")
            return
        }
        
        zkSync = JsonRpc2_0ZkSync(web3,
                                  transport: HTTPTransport(ZKSyncWalletIntegrationTests.L2NodeUrl))
        
        let ethSigner: EthSigner = PrivateKeyEthSigner("")
        
        wallet = ZKSyncWallet(web3,
                              zkSync: zkSync,
                              ethSigner: ethSigner)
    }
    
    override func tearDownWithError() throws {
        
    }
    
//    Web3j web3j = Web3j.build(new HttpService(L1_NODE));
//
//    String account = web3j.ethAccounts().sendAsync().join().getAccounts().get(0);
//
//    EthSendTransaction sent = web3j.ethSendTransaction(
//                    Transaction.createEtherTransaction(account, null, BigInteger.ZERO, BigInteger.valueOf(21_000L),
//                            credentials.getAddress(), Convert.toWei("1000", Convert.Unit.ETHER).toBigInteger()))
//            .sendAsync().join();
//
//    assertResponse(sent);
    func testSendMoney() {
        guard let web3 = try? Web3.new(ZKSyncWalletIntegrationTests.L1NodeUrl) else {
            XCTFail("web3 should be valid.")
            return
        }
        
        do {
            let account = try web3.eth.getAccounts().first
            XCTAssertNotNil(account)
        } catch {
            XCTFail()
        }
        
//        web3.eth.sendTransaction(EthereumTransaction, transactionOptions: <#T##TransactionOptions#>)
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
