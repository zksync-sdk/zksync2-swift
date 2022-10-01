//
//  ZkSyncWeb3RpcIntegrationTests.swift
//  ZkSync2Tests
//
//  Created by Maxim Makhun on 7/26/22.
//

import XCTest
import web3swift
import BigInt
import PromiseKit
@testable import ZkSync2

class ZKSyncWeb3RpcIntegrationTests: XCTestCase {
    
    static let L1NodeUrl = URL(string: "http://206.189.96.247:8545")!
    static let L2NodeUrl = URL(string: "http://206.189.96.247:3050")!
    
//    static let L1NodeUrl = URL(string: "https://goerli.infura.io/v3/25be7ab42c414680a5f89297f8a11a4d")!
//    static let L2NodeUrl = URL(string: "https://zksync2-testnet.zksync.dev")!
    
    let ethToken = Token.ETH
    
    var zkSync: JsonRpc2_0ZkSync!
    
    let credentials = Credentials(BigUInt.one)
    
    var chainId: BigUInt!
    
    let contractAddress = "0xca9e8bfcd17df56ae90c2a5608e8824dfd021067"
    
    override func setUpWithError() throws {
        let expectation = expectation(description: "Expectation.")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let web3 = try! Web3.new(ZKSyncWeb3RpcIntegrationTests.L2NodeUrl)
            self.zkSync = JsonRpc2_0ZkSync(web3,
                                           transport: HTTPTransport(ZKSyncWeb3RpcIntegrationTests.L2NodeUrl))
            
            self.chainId = try! self.zkSync.chainId().wait()
            XCTAssertEqual(self.chainId, BigUInt(270))
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testSendTestMoney() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let web3 = try! Web3.new(ZKSyncWeb3RpcIntegrationTests.L1NodeUrl)
            let account = try! web3.eth.getAccounts().first!
            
            let from = account
            XCTAssertEqual(from.address.lowercased(), "0x8a91dc2d28b689474298d91899f0c1baf62cb85b")
            
            let gasPrice = Web3.Utils.parseToBigUInt("1", units: .Gwei)!
            XCTAssertEqual(gasPrice.toHexString().addHexPrefix(), "0x3b9aca00")
            
            let gasLimit = BigUInt(21_000)
            XCTAssertEqual(gasLimit.toHexString().addHexPrefix(), "0x5208")
            
            let to = self.credentials.ethereumAddress
            XCTAssertEqual(to.address.lowercased(), "0x7e5f4552091a69125d5dfcb7b8c2659029395bdf")
            
            let nonce = try! web3.eth.getTransactionCount(address: to)
            XCTAssertEqual(nonce, BigUInt(0))
            
            let value = Web3.Utils.parseToBigUInt("1000000", units: .Gwei)!
            
            let chainId = try! web3.eth.getChainIdPromise().wait()
            XCTAssertEqual(chainId, BigUInt(9))
            
            var ethereumTransaction = EthereumTransaction.createEtherTransaction(from: from,
                                                                                 nonce: nonce,
                                                                                 gasPrice: gasPrice,
                                                                                 gasLimit: gasLimit,
                                                                                 to: to,
                                                                                 value: value,
                                                                                 chainID: chainId)
            
            let privateKey = self.credentials.privateKey
            XCTAssertEqual(privateKey.toHexString().addHexPrefix(), "0x0000000000000000000000000000000000000000000000000000000000000001")
            
            try! ethereumTransaction.sign(privateKey: privateKey)
            
            guard let encodedAndSignedTransaction = ethereumTransaction.encode(for: .transaction) else {
                fatalError("Failed to encode transaction.")
            }
            
            print("Encoded and signed transaction: \(encodedAndSignedTransaction.toHexString().addHexPrefix())")
            
            let transactionSendingResult = try! web3.eth.sendRawTransactionPromise(encodedAndSignedTransaction).wait()
            print("Result: \(transactionSendingResult)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetBalanceOfTokenL1() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let web3 = try! Web3.new(ZKSyncWeb3RpcIntegrationTests.L1NodeUrl)
            let address = self.credentials.ethereumAddress
            XCTAssertEqual(address, EthereumAddress("0x7e5f4552091a69125d5dfcb7b8c2659029395bdf")!)
            
            let block: DefaultBlockParameterName = .latest
            let balance = try! web3.eth.getBalancePromise(address: address,
                                                          onBlock: block.rawValue).wait()
            XCTAssertEqual(balance, BigUInt(0))
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDeposit() {
//        do {
//            let web3 = try Web3.new(ZKSyncWeb3RpcIntegrationTests.l1NodeUrl)
//            let chainIdExpectation = expectation(description: "Expectation.")
//            var chainId: BigUInt!
//            zkSync.chainId { result in
//                switch result {
//                case .success(let resultChainId):
//                    chainId = resultChainId
//                    chainIdExpectation.fulfill()
//                case .failure(let error):
//                    print("Error occured: \(error.localizedDescription)")
//                }
//            }
//            wait(for: [chainIdExpectation], timeout: 10.0)
//
//        } catch {
//            XCTFail("Failed with error: \(error)")
//        }
    }
    
    func testGetBalanceOfNative() {
        
    }
    
    func testGetNonce() {
        let expectation = expectation(description: "Expectation")
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let nonce = try! self.zkSync.web3.eth.getTransactionCountPromise(address: self.credentials.ethereumAddress).wait()
            XCTAssertEqual(nonce, 0)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetDeploymentNonce() {
        
    }
    
    func testGetTransactionReceipt() {
        let expectation = expectation(description: "Expectation.")
        _ = firstly {
            zkSync.web3.eth.getTransactionReceiptPromise("0xc47004cd0ab1d9d7866cfb6d699b73ea5872938f14541661b0f0132e5b8365d1")
        }.done { transactionReceipt in
            print("Transaction receipt: \(transactionReceipt)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }

    func testGetTransaction() {
        let expectation = expectation(description: "Expectation.")
        _ = firstly {
            zkSync.web3.eth.getTransactionDetailsPromise("0xf6b0c2b7f815befda19e895efc26805585ae2002cd7d7f9e782d2c346a108ab6")
        }.done { transactionDetails in
            print("Transaction details: \(transactionDetails)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
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
        let expectation = expectation(description: "Expectation")
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let tokenPrice = try! self.zkSync.zksGetTokenPrice(Token.ETH.l2Address).wait()
            XCTAssertEqual(tokenPrice, 3500.0)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetL1ChainId() {
        let expectation = expectation(description: "Expectation")
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let chainId = try! self.zkSync.zksL1ChainId().wait()
            XCTAssertEqual(chainId, 9)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
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
    
    func testGetL2ToL1MsgProof() {
        let expectation = expectation(description: "Expectation.")
        zkSync.zksGetL2ToL1MsgProof(0,
                                    sender: "",
                                    message: "",
                                    l2LogPosition: nil,
                                    completion: { result in
            switch result {
            case .success(let messageProof):
                print(messageProof)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 5.0)
    }
}
