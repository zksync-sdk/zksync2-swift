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

class ZKSyncWeb3RpcIntegrationTests: BaseIntegrationEnv {
    
//    static let L1NodeUrl = URL(string: "https://rpc.ankr.com/eth_goerli")!
//    static let L2NodeUrl = URL(string: "https://zksync2-testnet.zksync.dev")!
//    
//    let ethToken = Token.ETH
//    
//    var zkSync: JsonRpc2_0ZkSync!
//    
//    let credentials = Credentials(BigUInt.one)
//    
//    var signer: EthSigner!
//    
//    var chainId: BigUInt!
//    
//    var feeProvider: ZkTransactionFeeProvider!
//    
//    var l1Web3: web3!
//    
//    override func setUpWithError() throws {
//        
//    }
//    
//    override func tearDownWithError() throws {
//        
//    }

//    
//    func testGetBalanceOfNative() {
//        let expectation = expectation(description: "Expectation")
//        
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            
//            let balance = try! self.zkSync.web3.eth.getBalancePromise(address: self.credentials.ethereumAddress).wait()
//            XCTAssertEqual(balance, 0)
//            
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 10.0)
//    }
//    
//    func testGetNonce() {
//        let expectation = expectation(description: "Expectation")
//        
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            
//            let nonce = try! self.zkSync.web3.eth.getTransactionCountPromise(address: self.credentials.ethereumAddress).wait()
//            XCTAssertEqual(nonce, 0)
//            
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 10.0)
//    }
//    
//    func testGetDeploymentNonce() {
//        let expectation = expectation(description: "Expectation")
//        
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            
//            let nonceHolder = NonceHolder(EthereumAddress(ZkSyncAddresses.NonceHolderAddress)!,
//                                          zkSync: self.zkSync,
//                                          contractGasProvider: DefaultGasProvider(),
//                                          credentials: self.credentials)
//            
//            let data = try! nonceHolder.getDeploymentNonce(self.credentials.ethereumAddress).wait()
//            let nonce = BigUInt.init(fromHex: data.toHexString().addHexPrefix())
//            print("Nonce: \(String(describing: nonce))")
//            
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 10.0)
//    }
//
//    
//
//    
//    func testWeb3jContract() {
//        let expectation = expectation(description: "Expectation")
//        
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            
//            var deploy = EthereumTransaction.createContractTransaction(from: self.credentials.ethereumAddress,
//                                                                       gasPrice: BigUInt.zero,
//                                                                       gasLimit: BigUInt.zero,
//                                                                       bytecode: CounterContract.Binary)
//            
//            let nonce = try! self.zkSync.web3.eth.getTransactionCountPromise(address: self.credentials.ethereumAddress,
//                                                                             onBlock: DefaultBlockParameterName.pending.rawValue).wait()
//            
//            let fee = try! self.zkSync.zksEstimateFee(deploy).wait()
//            print("Fee: \(fee)")
//            
//            let gasPrice = try! self.zkSync.web3.eth.getGasPricePromise().wait()
//            print("Gas price: \(gasPrice)")
//            
//            deploy.parameters.EIP712Meta?.gasPerPubdata = fee.gasPerPubdataLimit
//            
//            var transactionOptions = TransactionOptions.defaultOptions
//            transactionOptions.type = .eip712
//            transactionOptions.from = self.credentials.ethereumAddress
//            transactionOptions.to = deploy.to
//            transactionOptions.gasLimit = .manual(fee.gasLimit)
//            transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
//            transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
//            transactionOptions.value = deploy.value
//            transactionOptions.nonce = .manual(nonce)
//            transactionOptions.chainID = self.chainId
//            
//            var ethereumParameters = EthereumParameters(from: transactionOptions)
//            ethereumParameters.EIP712Meta = deploy.parameters.EIP712Meta
//            
//            var transaction = EthereumTransaction(type: .eip712,
//                                                  to: deploy.to,
//                                                  nonce: nonce,
//                                                  chainID: self.chainId,
//                                                  value: deploy.value,
//                                                  data: deploy.data,
//                                                  parameters: ethereumParameters)
//            
//            let signature = self.signer.signTypedData(self.signer.domain, typedData: transaction).addHexPrefix()
//            print("signature: \(signature)")
//            
//            // assert(signature == "")
//            
//            let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
//            transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
//            transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
//            transaction.envelope.v = BigUInt(unmarshalledSignature.v)
//            
//            guard let message = transaction.encode(for: .transaction) else {
//                fatalError("Failed to encode transaction.")
//            }
//            
//            print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
//            
//            let sent = try! self.zkSync.web3.eth.sendRawTransactionPromise(transaction).wait()
//            print("Result: \(sent)")
//            
//            // TODO: Implement `CounterContract`.
//            
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 1000.0)
//    }
//    
//    func testDeployContract_Create() {
//        let expectation = expectation(description: "Expectation")
//        
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            
//            let nonce = try! self.zkSync.web3.eth.getTransactionCountPromise(address: self.credentials.ethereumAddress,
//                                                                             onBlock: DefaultBlockParameterName.pending.rawValue).wait()
//            
//            let nonceHolder = NonceHolder(EthereumAddress(ZkSyncAddresses.NonceHolderAddress)!,
//                                          zkSync: self.zkSync,
//                                          contractGasProvider: DefaultGasProvider(),
//                                          credentials: self.credentials)
//            
//            let deploymentNonceData = try! nonceHolder.getDeploymentNonce(self.credentials.ethereumAddress).wait()
//            
//            let deploymentNonce = BigUInt(fromHex: deploymentNonceData.toHexString().addHexPrefix())!
//            print("Deployment nonce: \(deploymentNonce)")
//            
//            let precomputedAddress = ContractDeployer.computeL2CreateAddress(self.credentials.ethereumAddress,
//                                                                             nonce: deploymentNonce)
//            
//            var estimate = EthereumTransaction.createContractTransaction(from: self.credentials.ethereumAddress,
//                                                                         gasPrice: BigUInt.zero,
//                                                                         gasLimit: BigUInt.zero,
//                                                                         bytecode: CounterContract.Binary)
//            
//            let fee = try! self.zkSync.zksEstimateFee(estimate).wait()
//            print("Fee: \(fee)")
//            
//            let gasPrice = try! self.zkSync.web3.eth.getGasPricePromise().wait()
//            print("Gas price: \(gasPrice)")
//            
//            estimate.parameters.EIP712Meta?.gasPerPubdata = fee.gasPerPubdataLimit
//            
//            var transactionOptions = TransactionOptions.defaultOptions
//            transactionOptions.type = .eip712
//            transactionOptions.from = self.credentials.ethereumAddress
//            transactionOptions.to = estimate.to
//            transactionOptions.gasLimit = .manual(fee.gasLimit)
//            transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
//            transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
//            transactionOptions.value = estimate.value
//            transactionOptions.nonce = .manual(nonce)
//            transactionOptions.chainID = self.chainId
//            
//            var ethereumParameters = EthereumParameters(from: transactionOptions)
//            ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta
//            
//            var transaction = EthereumTransaction(type: .eip712,
//                                                  to: estimate.to,
//                                                  nonce: nonce,
//                                                  chainID: self.chainId,
//                                                  value: estimate.value,
//                                                  data: estimate.data,
//                                                  parameters: ethereumParameters)
//            
//            let signature = self.signer.signTypedData(self.signer.domain, typedData: transaction).addHexPrefix()
//            print("signature: \(signature)")
//            
//            // assert(signature == "")
//            
//            let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
//            transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
//            transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
//            transaction.envelope.v = BigUInt(unmarshalledSignature.v)
//            
//            guard let message = transaction.encode(for: .transaction) else {
//                fatalError("Failed to encode transaction.")
//            }
//            
//            print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
//            
//            let sent = try! self.zkSync.web3.eth.sendRawTransactionPromise(transaction).wait()
//            print("Result: \(sent)")
//            
//            // TODO: Implement `EthereumTransaction.createEthCallTransaction`.
//            
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 1000.0)
//    }
//    
//    func testDeployContractWithConstructor_Create() {
//        let expectation = expectation(description: "Expectation")
//        
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            
//            let nonce = try! self.zkSync.web3.eth.getTransactionCountPromise(address: self.credentials.ethereumAddress,
//                                                                             onBlock: DefaultBlockParameterName.pending.rawValue).wait()
//            
//            let nonceHolder = NonceHolder(EthereumAddress(ZkSyncAddresses.NonceHolderAddress)!,
//                                          zkSync: self.zkSync,
//                                          contractGasProvider: DefaultGasProvider(),
//                                          credentials: self.credentials)
//            
//            let deploymentNonceData = try! nonceHolder.getDeploymentNonce(self.credentials.ethereumAddress).wait()
//            
//            let deploymentNonce = BigUInt(fromHex: deploymentNonceData.toHexString().addHexPrefix())!
//            print("Deployment nonce: \(deploymentNonce)")
//            
//            let precomputedAddress = ContractDeployer.computeL2CreateAddress(self.credentials.ethereumAddress,
//                                                                             nonce: deploymentNonce)
//            
//            let constructor = ConstructorContract.encodeConstructor(a: BigUInt(42),
//                                                                    b: BigUInt(43),
//                                                                    shouldRevert: false)
//            
//            let constructorContractBinaryFileURL = Bundle.module.url(forResource: "constructorContractBinary", withExtension: "hex")!
//            let constructorContract = try! String(contentsOf: constructorContractBinaryFileURL, encoding: .ascii).trim()
//            
//            var estimate = EthereumTransaction.createContractTransaction(from: self.credentials.ethereumAddress,
//                                                                         gasPrice: BigUInt.zero,
//                                                                         gasLimit: BigUInt.zero,
//                                                                         bytecode: constructorContract,
//                                                                         calldata: constructor)
//            
//            let fee = try! self.zkSync.zksEstimateFee(estimate).wait()
//            print("Fee: \(fee)")
//            
//            let gasPrice = try! self.zkSync.web3.eth.getGasPricePromise().wait()
//            print("Gas price: \(gasPrice)")
//            
//            estimate.parameters.EIP712Meta?.gasPerPubdata = fee.gasPerPubdataLimit
//            
//            var transactionOptions = TransactionOptions.defaultOptions
//            transactionOptions.type = .eip712
//            transactionOptions.from = self.credentials.ethereumAddress
//            transactionOptions.to = estimate.to
//            transactionOptions.gasLimit = .manual(fee.gasLimit)
//            transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
//            transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
//            transactionOptions.value = estimate.value
//            transactionOptions.nonce = .manual(nonce)
//            transactionOptions.chainID = self.chainId
//            
//            var ethereumParameters = EthereumParameters(from: transactionOptions)
//            ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta
//            
//            var transaction = EthereumTransaction(type: .eip712,
//                                                  to: estimate.to,
//                                                  nonce: nonce,
//                                                  chainID: self.chainId,
//                                                  value: estimate.value,
//                                                  data: estimate.data,
//                                                  parameters: ethereumParameters)
//            
//            let signature = self.signer.signTypedData(self.signer.domain, typedData: transaction).addHexPrefix()
//            print("signature: \(signature)")
//            
//            // assert(signature == "")
//            
//            let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
//            transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
//            transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
//            transaction.envelope.v = BigUInt(unmarshalledSignature.v)
//            
//            guard let message = transaction.encode(for: .transaction) else {
//                fatalError("Failed to encode transaction.")
//            }
//            
//            print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
//            
//            let sent = try! self.zkSync.web3.eth.sendRawTransactionPromise(transaction).wait()
//            print("Result: \(sent)")
//            
//            Thread.sleep(forTimeInterval: 1.0)
//            
//            let transactionReceipt = try! self.zkSync.web3.eth.getTransactionReceiptPromise(sent.hash).wait()
//            print("Transaction receipt: \(transactionReceipt)")
//            XCTAssertEqual(transactionReceipt.status, .ok)
//            
//            // TODO: Implement `EthereumTransaction.createEthCallTransaction`.
//            
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 1000.0)
//    }
//    
//    func testGetAllAccountBalances() {
//        let expectation = expectation(description: "Expectation")
//        
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            
//            let accountBalances = try! self.zkSync.zksGetAllAccountBalances(self.credentials.address).wait()
//            print("Account balances: \(accountBalances)")
//            
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 10.0)
//    }
//
//    
//    func testGetTokenPrice() {
//        let expectation = expectation(description: "Expectation")
//        
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            
//            let tokenPrice = try! self.zkSync.zksGetTokenPrice(Token.ETH.l2Address).wait()
//            XCTAssertEqual(tokenPrice, 3500.0)
//            
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 10.0)
//    }
//    
//    func testGetL1ChainId() {
//        let expectation = expectation(description: "Expectation")
//        
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            
//            let chainId = try! self.zkSync.zksL1ChainId().wait()
//            XCTAssertEqual(chainId, 9)
//            
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 10.0)
//    }
//    
//    func testGetBridgeContracts() {
//        let expectation = expectation(description: "Expectation.")
//        
//        zkSync.zksGetBridgeContracts() { result in
//            switch result {
//            case .success(let bridgeAddresses):
//                print(bridgeAddresses)
//            case .failure(let error):
//                XCTFail("Failed with error: \(error)")
//            }
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 5.0)
//    }
//    
//    func testGetTestnetPaymaster() {
//        let expectation = expectation(description: "Expectation.")
//        
//        zkSync.zksGetTestnetPaymaster() { result in
//            switch result {
//            case .success(let address):
//                print(address)
//            case .failure(let error):
//                XCTFail("Failed with error: \(error)")
//            }
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 5.0)
//    }
//    
//    func testGetL2ToL1MsgProof() {
//        let expectation = expectation(description: "Expectation.")
//        
//        zkSync.zksGetL2ToL1MsgProof(0,
//                                    sender: "",
//                                    message: "",
//                                    l2LogPosition: nil,
//                                    completion: { result in
//            switch result {
//            case .success(let messageProof):
//                print(messageProof)
//            case .failure(let error):
//                XCTFail("Failed with error: \(error)")
//            }
//            expectation.fulfill()
//        })
//        
//        wait(for: [expectation], timeout: 5.0)
//    }
//    
//    func testGetMainContract() {
//        let expectation = expectation(description: "Expectation.")
//        
//        zkSync.zksMainContract { result in
//            switch result {
//            case .success(let mainContract):
//                print(mainContract)
//            case .failure(let error):
//                XCTFail("Failed with error: \(error)")
//            }
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 5.0)
//    }
//    
//    func testGetTransactionDetails() {
//        let expectation = expectation(description: "Expectation.")
//        
//        zkSync.zksGetTransactionDetails("0x0898f4b225276625e1d5d2cc4dc5b7a1acb896daece7e46c8202a47da9a13a27",
//                                        completion: { result in
//            switch result {
//            case .success(let transactionDetails):
//                print(transactionDetails)
//            case .failure(let error):
//                XCTFail("Failed with error: \(error)")
//            }
//            expectation.fulfill()
//        })
//        
//        wait(for: [expectation], timeout: 5.0)
//    }
//    
//    func testGetTransactionByHash() {
//        let expectation = expectation(description: "Expectation.")
//        
//        zkSync.zksGetTransactionByHash("0x0898f4b225276625e1d5d2cc4dc5b7a1acb896daece7e46c8202a47da9a13a27",
//                                       completion: { result in
//            switch result {
//            case .success(let transactionResponse):
//                print(transactionResponse)
//            case .failure(let error):
//                XCTFail("Failed with error: \(error)")
//            }
//            expectation.fulfill()
//        })
//        
//        wait(for: [expectation], timeout: 5.0)
//    }
//    
//    func testGetLogs() {
//        let expectation = expectation(description: "Expectation.")
//        
//        zkSync.zksGetLogs { result in
//            switch result {
//            case .success(let logs):
//                print(logs)
//            case .failure(let error):
//                XCTFail("Failed with error: \(error)")
//            }
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 5.0)
//    }
//    
//    func testGetBlockByHash() {
//        let expectation = expectation(description: "Expectation.")
//        
//        zkSync.zksGetBlockByHash("0x0898f4b225276625e1d5d2cc4dc5b7a1acb896daece7e46c8202a47da9a13a27",
//                                 returnFullTransactionObjects: true,
//                                 completion: { result in
//            switch result {
//            case .success(let block):
//                print(block)
//            case .failure(let error):
//                XCTFail("Failed with error: \(error)")
//            }
//            expectation.fulfill()
//        })
//        
//        wait(for: [expectation], timeout: 5.0)
//    }
//    
//    func testGetBlockByNumber() {
//        let expectation = expectation(description: "Expectation.")
//        zkSync.zksGetBlockByNumber(.finalized,
//                                   returnFullTransactionObjects: true,
//                                   completion: { result in
//            switch result {
//            case .success(let block):
//                print(block)
//            case .failure(let error):
//                XCTFail("Failed with error: \(error)")
//            }
//            expectation.fulfill()
//        })
//        
//        wait(for: [expectation], timeout: 5.0)
//    }
//    
//    func testGetBlockDetails() {
//        let expectation = expectation(description: "Expectation.")
//        zkSync.zksGetBlockDetails(0,
//                                  completion: { result in
//            switch result {
//            case .success(let blockDetails):
//                print(blockDetails)
//            case .failure(let error):
//                XCTFail("Failed with error: \(error)")
//            }
//            expectation.fulfill()
//        })
//        
//        wait(for: [expectation], timeout: 5.0)
//    }
}
