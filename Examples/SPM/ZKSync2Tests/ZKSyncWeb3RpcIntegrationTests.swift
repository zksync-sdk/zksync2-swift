//
//  ZKSyncWeb3RpcIntegrationTests.swift
//  ZKSync2Tests
//
//  Created by Maxim Makhun on 7/26/22.
//

import XCTest
@testable import ZKSync2

class ZKSyncWeb3RpcIntegrationTests: XCTestCase {
    
    var zkSync: ZKSync!

    override func setUpWithError() throws {
        let url = URL(string: "http://206.189.96.247:3050")!
        zkSync = JsonRpc2_0ZkSync(transport: HTTPTransport(url))
    }

    override func tearDownWithError() throws {

    }
    
    func testSendTestMoney() {

    }
    
    func testDeposit() {
        
    }
    
    func testGetBalanceOfToken() {
        
    }
    
    func testGetTransactionReceipt() {
        
    }
    
    func testTransferToSelf() {
        
    }
    
    func testTransferToSelfWeb3jContract() {
        
    }
    
    func testWithdraw() {
        
    }
    
    func testEstimateFee_Withdraw() {
        
    }
    
    func testEstimateFee_Execute() {
        
    }
    
    func testEstimateFee_DeployContract() {
        
    }
    
    func testDeployWeb3jContract() {
        
    }
    
    func testReadWeb3jContract() {
        
    }
    
//    public void testGetAccountTransactions() throws IOException {
//        int offset = 0;
//        short limit = 10; // Get latest 10 transactions
//
//        ZksTransactions response = this.zksync.zksGetAccountTransactions(this.credentials.getAddress(), offset, limit).send();
//
//        assertResponse(response);
//    }

//    func testGetAccountTransactions() {
//        let offset = 0
//        
//        // Get latest 10 transactions
//        let limit = 10
//        
//        let expectation = expectation(description: "")
//        let zkSync = JsonRpc2_0ZkSync(transport: HTTPTransport(URL(string: "http://206.189.96.247:3050")!))
//        zkSync.getAccountTransactions("", before: offset, limit: limit) { result in
//            print("!!! \(result)")
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 10.0)
//    }
    
//    public void testGetConfirmedTokens() throws IOException {
//        int offset = 0;
//        short limit = 10; // Get first 10 confirmed tokens
//
//        ZksTokens response = this.zksync.zksGetConfirmedTokens(offset, limit).send();
//
//        assertResponse(response);
//    }
    
    func testGetConfirmedTokens() {
        let offset = 0
        // Last 10 transactions.
        let limit = 10
        
        let expectation = expectation(description: "Expectation.")
        zkSync.getConfirmedTokens(offset,
                                  limit: limit) { result in
            switch result {
            case .success(let result):
                print(result)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // +
//    public void testIsTokenLiquid() throws IOException {
//        ZksIsTokenLiquid response = this.zksync.zksIsTokenLiquid(ETH.getAddress()).send();
//
//        assertResponse(response);
//        assertTrue(response.getResult());
//    }
    
    func testIsTokenLiquid() {
        let expectation = expectation(description: "Expectation.")
        zkSync.isTokenLiquid(Token.ETH.address) { result in
            switch result {
            case .success(let isTokenLiquid):
                XCTAssertTrue(isTokenLiquid)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // +
//    public void testGetTokenPrice() throws IOException {
//        ZksTokenPrice response = this.zksync.zksGetTokenPrice(ETH.getAddress()).send();
//
//        assertResponse(response);
//    }
    
    func testGetTokenPrice() {
        let expectedTokenPrice: Decimal = 3500.0
        let expectation = expectation(description: "Expectation.")
        zkSync.getTokenPrice(Token.ETH.address) { result in
            switch result {
            case .success(let tokenPrice):
                XCTAssertEqual(tokenPrice, expectedTokenPrice)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    // +
//    public void testGetL1ChainId() throws IOException {
//        ZksL1ChainId response = this.zksync.zksL1ChainId().send();
//
//        assertResponse(response);
//    }
    
    func testL1ChainId() {
        let expectation = expectation(description: "Expectation.")
        zkSync.L1ChainId { result in
            switch result {
            case .success(let chainId):
                print(chainId)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
