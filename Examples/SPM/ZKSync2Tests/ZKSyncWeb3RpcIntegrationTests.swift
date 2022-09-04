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

    func sendTestMoney() {
        
    }
    
    func testGetBalanceOfTokenL1() {
        
    }
    
    func testDeposit() {
        
    }
    
    func testGetBalanceOfNative() {
        
    }
    
    func testGetNonce() {
        
    }
    
    func testGetDeploymentNonce() {
        
    }
    
    func testGetTransactionReceipt() {
        
    }

    func testGetTransaction() {
        
    }
    
    func testTransferNativeToSelf() {
        
    }
    
    func testTransferNativeToSelfWeb3j_Legacy() {
        
    }
    
    func testTransferNativeToSelfWeb3j() {
        
    }
    
    func testTransferTokenToSelf() {
        
    }
    
    func testTransferTokenToSelfWeb3jContract() {
        
    }
    
    func testWithdraw() {
        
    }
    
    func testEstimateGas_Withdraw() {
        
    }
    
    func testEstimateGas_TransferNative() {
        
    }
    
    func testEstimateGas_Execute() {
        
    }
    
    func testEstimateFee_DeployContract() {
        
    }
    
    func testDeployWeb3jContract() {
        
    }
    
    func testReadWeb3jContract() {
        
    }
    
    func testWriteWeb3jContract() {
        
    }
    
    func testDeployContract_Create() {
        
    }
    
    func testDeployContractWithConstructor_Create() {
        
    }
    
    func testDeployContract_Create2() {
        
    }
    
    func testExecuteContract() {
        
    }
    
    func testGetAllAccountBalances() {
        let expectation = expectation(description: "Expectation.")
        // TODO: Add credentials storage.
        zkSync.zksGetAllAccountBalances("0x7e5f4552091a69125d5dfcb7b8c2659029395bdf") { accountBalances in
            switch accountBalances {
            case .success(let result):
                print(result)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetConfirmedTokens() {
        let offset = 0
        // Last 10 transactions.
        let limit = 10
        
        let expectation = expectation(description: "Expectation.")
        zkSync.zksGetConfirmedTokens(offset,
                                     limit: limit) { result in
            switch result {
            case .success(let tokens):
                print(tokens)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetTokenPrice() {
        let expectedTokenPrice: Decimal = 3500.0
        let expectation = expectation(description: "Expectation.")
        zkSync.zksGetTokenPrice(Token.ETH.l2Address) { result in
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
    
    func testGetL1ChainId() {
        let expectation = expectation(description: "Expectation.")
        zkSync.zksL1ChainId { result in
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
    
    func testGetBridgeContracts() {
        let expectation = expectation(description: "Expectation.")
        zkSync.zksGetBridgeContracts() { result in
            switch result {
            case .success(let bridgeAddresses):
                print(bridgeAddresses)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGetTestnetPaymaster() {
        let expectation = expectation(description: "Expectation.")
        zkSync.zksGetTestnetPaymaster() { result in
            switch result {
            case .success(let address):
                print(address)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
