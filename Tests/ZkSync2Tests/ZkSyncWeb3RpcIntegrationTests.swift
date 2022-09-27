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
    
    let ethToken: Token = Token.ETH

    var zkSync: ZkSync!
    
    var chainId: BigUInt!
    
    let contractAddress = "0xca9e8bfcd17df56ae90c2a5608e8824dfd021067"
    
    override func setUpWithError() throws {
        let web3 = try Web3.new(ZKSyncWeb3RpcIntegrationTests.L1NodeUrl)
        zkSync = JsonRpc2_0ZkSync(web3,
                                  transport: HTTPTransport(ZKSyncWeb3RpcIntegrationTests.L2NodeUrl))
        
        zkSync.chainId { result in
            switch result {
            case .success(let resultChainId):
                self.chainId = resultChainId
            case .failure(let error):
                print("Error occured: \(error.localizedDescription)")
            }
        }
    }
    
    override func tearDownWithError() throws {
        
    }

    func testSendTestMoney() {
        do {
            let web3 = try Web3.new(ZKSyncWeb3RpcIntegrationTests.L1NodeUrl)
            let account = try web3.eth.getAccounts()[0]
            
    //        public init(type: TransactionType? = nil, to: EthereumAddress, nonce: BigUInt = 0,
    //                    chainID: BigUInt? = nil, value: BigUInt? = nil, data: Data,
    //                    v: BigUInt = 1, r: BigUInt = 0, s: BigUInt = 0, parameters: EthereumParameters? = nil) {
            
//            let transaction = EthereumTransaction(to: account,
//                                                  chainID: <#T##BigUInt?#>,
//                                                  value: <#T##BigUInt?#>,
//                                                  data: <#T##Data#>,
//                                                  parameters: <#T##EthereumParameters?#>)
//
//            let transactionOptions: TransactionOptions = TransactionOptions()

//            try web3.eth.sendTransaction(transaction, transactionOptions: transactionOptions)
        } catch {
            
        }
    }
    
    func testGetBalanceOfTokenL1() {
        do {
            let web3 = try Web3.new(ZKSyncWeb3RpcIntegrationTests.L1NodeUrl)
            let address = EthereumAddress("0x7e5f4552091a69125d5dfcb7b8c2659029395bdf")
            let block: DefaultBlockParameterName = .latest
            
            let expectation = expectation(description: "Expectation.")
            _ = firstly {
                web3.eth.getBalancePromise(address: address!, onBlock: block.rawValue)
            }.done { result in
                XCTAssertEqual(BigUInt(stringLiteral: "3999899999858895000000000"), result)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        } catch {
            XCTFail("Failed with error: \(error)")
        }
    }
    
//    @Test
//    public void testDeposit() throws IOException {
//        Web3j web3j = Web3j.build(new HttpService(L1_NODE));
//        BigInteger chainId = web3j.ethChainId().send().getChainId();
//        TransactionManager manager = new RawTransactionManager(web3j, credentials, chainId.longValue());
//        ContractGasProvider gasProvider = new StaticGasProvider(Convert.toWei("1", Unit.GWEI).toBigInteger(), BigInteger.valueOf(555_000L));
//        TransactionReceipt receipt = EthereumProvider
//                .load(zksync, web3j, manager, gasProvider).join()
//                .deposit(ETH, Convert.toWei("100", Unit.ETHER).toBigInteger(), credentials.getAddress()).join();
//
//        System.out.println("!!! " + receipt);
//    }
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
