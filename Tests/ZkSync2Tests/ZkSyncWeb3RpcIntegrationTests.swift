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
    
    static let L1NodeUrl = URL(string: "https://goerli.infura.io/v3/fc6f2c1e05b447969453c194a0326020")!
    static let L2NodeUrl = URL(string: "https://zksync2-testnet.zksync.dev")!
    
    let ethToken = Token.ETH
    
    var zkSync: JsonRpc2_0ZkSync!
    
    let credentials = Credentials(BigUInt.one)
    
    var signer: EthSigner!
    
    var chainId: BigUInt!
    
    var feeProvider: ZkTransactionFeeProvider!
    
    var l1Web3: web3!
    
    override func setUpWithError() throws {
        let expectation = expectation(description: "Expectation.")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            self.zkSync = JsonRpc2_0ZkSync(ZKSyncWeb3RpcIntegrationTests.L2NodeUrl)
            
            self.chainId = try! self.zkSync.web3.eth.getChainIdPromise().wait()
            
            self.signer = PrivateKeyEthSigner(self.credentials,
                                              chainId: self.chainId)
            
            self.feeProvider = DefaultTransactionFeeProvider(zkSync: self.zkSync,
                                                             feeToken: self.ethToken)
            
            self.l1Web3 = try! Web3.new(ZKSyncWeb3RpcIntegrationTests.L1NodeUrl)
            
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
            
            let account = try! self.l1Web3.eth.getAccounts().first!
            
            let from = account
            XCTAssertEqual(from.address.lowercased(), "0x8a91dc2d28b689474298d91899f0c1baf62cb85b")
            
            let gasPrice = Web3.Utils.parseToBigUInt("1", units: .Gwei)!
            XCTAssertEqual(gasPrice.toHexString().addHexPrefix(), "0x3b9aca00")
            
            let gasLimit = BigUInt(21_000)
            XCTAssertEqual(gasLimit.toHexString().addHexPrefix(), "0x5208")
            
            let to = self.credentials.ethereumAddress
            XCTAssertEqual(to.address.lowercased(), "0x7e5f4552091a69125d5dfcb7b8c2659029395bdf")
            
            let nonce = try! self.l1Web3.eth.getTransactionCount(address: to)
            XCTAssertEqual(nonce, BigUInt(0))
            
            let value = Web3.Utils.parseToBigUInt("1000000", units: .Gwei)!
            
            let chainId = try! self.l1Web3.eth.getChainIdPromise().wait()
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
            
            let transactionSendingResult = try! self.l1Web3.eth.sendRawTransactionPromise(encodedAndSignedTransaction).wait()
            print("Result: \(transactionSendingResult)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetBalanceOfNativeL1() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let address = self.credentials.ethereumAddress
            XCTAssertEqual(address, EthereumAddress("0x7e5f4552091a69125d5dfcb7b8c2659029395bdf")!)
            
            let block: DefaultBlockParameterName = .latest
            let balance = try! self.l1Web3.eth.getBalancePromise(address: address,
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
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let balance = try! self.zkSync.web3.eth.getBalancePromise(address: self.credentials.ethereumAddress).wait()
            XCTAssertEqual(balance, 0)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
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
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let nonceHolder = NonceHolder(EthereumAddress(ZkSyncAddresses.NonceHolderAddress)!,
                                          zkSync: self.zkSync,
                                          contractGasProvider: DefaultGasProvider(),
                                          credentials: self.credentials)
            
            let data = try! nonceHolder.getDeploymentNonce(self.credentials.ethereumAddress).wait()
            let nonce = BigUInt.init(fromHex: data.toHexString().addHexPrefix())
            print("Nonce: \(String(describing: nonce))")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetTransactionReceipt() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let transactionReceipt = try! self.zkSync.web3.eth.getTransactionReceiptPromise("0xea87f073bbb8826edf51abbbc77b5812848c92bfb8a825f82a74586ad3553309").wait()
            print("Transaction receipt: \(transactionReceipt)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetTransaction() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let transactionReceipt = try! self.zkSync.web3.eth.getTransactionDetailsPromise("0x60c05fffdfca5ffb5884f8dd0a80268f16ef768c71f6e173ed1fb58a50790e29").wait()
            print("Transaction receipt: \(transactionReceipt)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testTransferNativeToSelf() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let value = Web3.Utils.parseToBigUInt("0.01", units: .eth)!
            
            let nonce = try! self.zkSync.web3.eth.getTransactionCountPromise(address: self.credentials.ethereumAddress,
                                                                             onBlock: ZkBlockParameterName.committed.rawValue).wait()
            
            var estimate = EthereumTransaction.createEtherTransaction(from: self.credentials.ethereumAddress,
                                                                      gasPrice: BigUInt.zero,
                                                                      gasLimit: BigUInt.zero,
                                                                      to: self.credentials.ethereumAddress,
                                                                      value: value)
            
            let fee = try! self.zkSync.zksEstimateFee(estimate).wait()
            print("Fee: \(fee)")
            
            let gasPrice = try! self.zkSync.web3.eth.getGasPricePromise().wait()
            print("Gas price: \(gasPrice)")
            
            estimate.parameters.EIP712Meta?.gasPerPubdata = fee.gasPerPubdataLimit
            
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.type = .eip712
            transactionOptions.from = self.credentials.ethereumAddress
            transactionOptions.to = estimate.to
            transactionOptions.gasLimit = .manual(fee.gasLimit)
            transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
            transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
            transactionOptions.value = value
            transactionOptions.nonce = .manual(nonce)
            transactionOptions.chainID = self.chainId
            
            var ethereumParameters = EthereumParameters(from: transactionOptions)
            ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta
            
            var transaction = EthereumTransaction(type: .eip712,
                                                  to: estimate.to,
                                                  nonce: nonce,
                                                  chainID: self.chainId,
                                                  value: value,
                                                  data: estimate.data,
                                                  parameters: ethereumParameters)
            
            let signature = self.signer.signTypedData(self.signer.domain, typedData: transaction).addHexPrefix()
            print("signature: \(signature)")
            
            // assert(signature == "")
            
            let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
            transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
            transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
            transaction.envelope.v = BigUInt(unmarshalledSignature.v)
            
            guard let message = transaction.encode(for: .transaction) else {
                fatalError("Failed to encode transaction.")
            }
            
            print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
            
            let sent = try! self.zkSync.web3.eth.sendRawTransactionPromise(transaction).wait()
            print("Result: \(sent)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }
    
    func testTransferTokenToSelf() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let nonce = try! self.zkSync.web3.eth.getTransactionCountPromise(address: self.credentials.ethereumAddress,
                                                                             onBlock: ZkBlockParameterName.committed.rawValue).wait()
            
            let token = try! self.zkSync.zksGetConfirmedTokens(0, limit: 100).wait().filter({ $0.symbol == "USDC" }).first
            
            guard let token = token else {
                XCTFail("Token should be valid")
                return
            }
            
            let tokenAddress = EthereumAddress(token.l2Address)!
            print("Token address: \(tokenAddress)")
            
            let value = BigUInt(10000000)
            
            let calldata = ZkERC20.encodeTransfer(self.credentials.ethereumAddress, value: value)
            print("calldata: \(calldata.toHexString().addHexPrefix())")
            
            var estimate = EthereumTransaction.createFunctionCallTransaction(from: self.credentials.ethereumAddress,
                                                                             to: tokenAddress,
                                                                             gasPrice: BigUInt.zero,
                                                                             gasLimit: BigUInt.zero,
                                                                             data: calldata)
            
            let fee = try! self.zkSync.zksEstimateFee(estimate).wait()
            print("Fee: \(fee)")
            
            let gasPrice = try! self.zkSync.web3.eth.getGasPricePromise().wait()
            print("Gas price: \(gasPrice)")
            
            estimate.parameters.EIP712Meta?.gasPerPubdata = fee.gasPerPubdataLimit
            
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.type = .eip712
            transactionOptions.from = self.credentials.ethereumAddress
            transactionOptions.to = estimate.to
            transactionOptions.gasLimit = .manual(fee.gasLimit)
            transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
            transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
            transactionOptions.value = estimate.value
            transactionOptions.nonce = .manual(nonce)
            transactionOptions.chainID = self.chainId
            
            var ethereumParameters = EthereumParameters(from: transactionOptions)
            ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta
            
            var transaction = EthereumTransaction(type: .eip712,
                                                  to: estimate.to,
                                                  nonce: nonce,
                                                  chainID: self.chainId,
                                                  value: value,
                                                  data: estimate.data,
                                                  parameters: ethereumParameters)
            
            let signature = self.signer.signTypedData(self.signer.domain, typedData: transaction).addHexPrefix()
            print("signature: \(signature)")
            
            // assert(signature == "")
            
            let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
            transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
            transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
            transaction.envelope.v = BigUInt(unmarshalledSignature.v)
            
            guard let message = transaction.encode(for: .transaction) else {
                fatalError("Failed to encode transaction.")
            }
            
            print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
            
            let sent = try! self.zkSync.web3.eth.sendRawTransactionPromise(transaction).wait()
            print("Result: \(sent)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }
    
    func testTransferTokenToSelfWeb3jContract() {
        
    }
    
    func testWithdraw() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let token = Token.ETH
            
            let nonce = try! self.zkSync.web3.eth.getTransactionCountPromise(address: self.credentials.ethereumAddress,
                                                                             onBlock: ZkBlockParameterName.committed.rawValue).wait()
            
            let l2EthBridge = try! EthereumAddress(self.zkSync.zksGetBridgeContracts().wait().l2EthDefaultBridge)!
            print("l2EthBridge: \(l2EthBridge)")
            
            let inputs = [
                ABI.Element.InOut(name: "_l1Receiver", type: .address),
                ABI.Element.InOut(name: "_l2Token", type: .address),
                ABI.Element.InOut(name: "_amount", type: .uint(bits: 256))
            ]
            
            let withdrawFunction = ABI.Element.Function(name: "withdraw",
                                                        inputs: inputs,
                                                        outputs: [],
                                                        constant: false,
                                                        payable: false)
            
            let elementFunction: ABI.Element = .function(withdrawFunction)
            
            let amount = BigUInt(10000000000000000)
            
            let parameters: [AnyObject] = [
                self.credentials.ethereumAddress as AnyObject,
                EthereumAddress(token.l2Address)! as AnyObject,
                amount as AnyObject
            ]
            
            let calldata = elementFunction.encodeParameters(parameters)!
            print("calldata: \(calldata.toHexString().addHexPrefix())")
            
            var estimate = EthereumTransaction.createFunctionCallTransaction(from: self.credentials.ethereumAddress,
                                                                             to: l2EthBridge,
                                                                             gasPrice: BigUInt.zero,
                                                                             gasLimit: BigUInt.zero,
                                                                             data: calldata)
            
            print("Value: \(estimate.value)")
            
            let fee = try! self.zkSync.zksEstimateFee(estimate).wait()
            print("Fee: \(fee)")
            
            let gasPrice = try! self.zkSync.web3.eth.getGasPricePromise().wait()
            print("Gas price: \(gasPrice)")
            
            estimate.parameters.EIP712Meta?.gasPerPubdata = fee.gasPerPubdataLimit
            
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.type = .eip712
            transactionOptions.from = self.credentials.ethereumAddress
            transactionOptions.to = estimate.to
            transactionOptions.gasLimit = .manual(fee.gasLimit)
            transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
            transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
            transactionOptions.value = estimate.value
            transactionOptions.nonce = .manual(nonce)
            transactionOptions.chainID = self.chainId
            
            var ethereumParameters = EthereumParameters(from: transactionOptions)
            ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta
            
            var transaction = EthereumTransaction(type: .eip712,
                                                  to: estimate.to,
                                                  nonce: nonce,
                                                  chainID: self.chainId,
                                                  value: estimate.value,
                                                  data: estimate.data,
                                                  parameters: ethereumParameters)
            
            let signature = self.signer.signTypedData(self.signer.domain, typedData: transaction).addHexPrefix()
            print("Signature: \(signature)")
            
            // assert(signature == "")
            
            let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
            transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
            transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
            transaction.envelope.v = BigUInt(unmarshalledSignature.v)
            
            guard let message = transaction.encode(for: .transaction) else {
                fatalError("Failed to encode transaction.")
            }
            
            print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
            
            let sent = try! self.zkSync.web3.eth.sendRawTransactionPromise(transaction).wait()
            print("Result: \(sent)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }
    
    func testWithdrawToken() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let token = try! self.zkSync.zksGetConfirmedTokens(0, limit: 100).wait().filter({ $0.symbol == "USDC" }).first!
            
            let nonce = try! self.zkSync.web3.eth.getTransactionCountPromise(address: self.credentials.ethereumAddress,
                                                                             onBlock: ZkBlockParameterName.committed.rawValue).wait()
            
            let l2EthBridge = try! EthereumAddress(self.zkSync.zksGetBridgeContracts().wait().l2EthDefaultBridge)!
            print("l2EthBridge: \(l2EthBridge)")
            
            let inputs = [
                ABI.Element.InOut(name: "_l1Receiver", type: .address),
                ABI.Element.InOut(name: "_l2Token", type: .address),
                ABI.Element.InOut(name: "_amount", type: .uint(bits: 256))
            ]
            
            let withdrawFunction = ABI.Element.Function(name: "withdraw",
                                                        inputs: inputs,
                                                        outputs: [],
                                                        constant: false,
                                                        payable: false)
            
            let elementFunction: ABI.Element = .function(withdrawFunction)
            
            let amount = BigUInt(10000000)
            
            let parameters: [AnyObject] = [
                self.credentials.ethereumAddress as AnyObject,
                EthereumAddress(token.l2Address)! as AnyObject,
                amount as AnyObject
            ]
            
            let calldata = elementFunction.encodeParameters(parameters)!
            print("calldata: \(calldata.toHexString().addHexPrefix())")
            
            var estimate = EthereumTransaction.createFunctionCallTransaction(from: self.credentials.ethereumAddress,
                                                                             to: l2EthBridge,
                                                                             gasPrice: BigUInt.zero,
                                                                             gasLimit: BigUInt.zero,
                                                                             data: calldata)
            
            print("Value: \(estimate.value)")
            
            let fee = try! self.zkSync.zksEstimateFee(estimate).wait()
            print("Fee: \(fee)")
            
            let gasPrice = try! self.zkSync.web3.eth.getGasPricePromise().wait()
            print("Gas price: \(gasPrice)")
            
            estimate.parameters.EIP712Meta?.gasPerPubdata = fee.gasPerPubdataLimit
            
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.type = .eip712
            transactionOptions.from = self.credentials.ethereumAddress
            transactionOptions.to = estimate.to
            transactionOptions.gasLimit = .manual(fee.gasLimit)
            transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
            transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
            transactionOptions.value = estimate.value
            transactionOptions.nonce = .manual(nonce)
            transactionOptions.chainID = self.chainId
            
            var ethereumParameters = EthereumParameters(from: transactionOptions)
            ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta
            
            var transaction = EthereumTransaction(type: .eip712,
                                                  to: estimate.to,
                                                  nonce: nonce,
                                                  chainID: self.chainId,
                                                  value: estimate.value,
                                                  data: estimate.data,
                                                  parameters: ethereumParameters)
            
            let signature = self.signer.signTypedData(self.signer.domain, typedData: transaction).addHexPrefix()
            print("Signature: \(signature)")
            
            // assert(signature == "")
            
            let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
            transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
            transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
            transaction.envelope.v = BigUInt(unmarshalledSignature.v)
            
            guard let message = transaction.encode(for: .transaction) else {
                fatalError("Failed to encode transaction.")
            }
            
            print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
            
            let sent = try! self.zkSync.web3.eth.sendRawTransactionPromise(transaction).wait()
            print("Result: \(sent)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testEstimateGas_Withdraw() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let l2EthBridge = try! EthereumAddress(self.zkSync.zksGetBridgeContracts().wait().l2EthDefaultBridge)!
            print("l2EthBridge: \(l2EthBridge)")
            
            let inputs = [
                ABI.Element.InOut(name: "_l1Receiver", type: .address),
                ABI.Element.InOut(name: "_l2Token", type: .address),
                ABI.Element.InOut(name: "_amount", type: .uint(bits: 256))
            ]
            
            let withdrawFunction = ABI.Element.Function(name: "withdraw",
                                                        inputs: inputs,
                                                        outputs: [],
                                                        constant: false,
                                                        payable: false)
            
            let elementFunction: ABI.Element = .function(withdrawFunction)
            
            let amount = BigUInt(1000000000000000000)
            
            let parameters: [AnyObject] = [
                self.credentials.ethereumAddress as AnyObject,
                EthereumAddress(Token.ETH.l2Address)! as AnyObject,
                amount as AnyObject
            ]
            
            let calldata = elementFunction.encodeParameters(parameters)!
            print("calldata: \(calldata.toHexString().addHexPrefix())")
            
            let estimate = EthereumTransaction.createFunctionCallTransaction(from: self.credentials.ethereumAddress,
                                                                             to: l2EthBridge,
                                                                             gasPrice: BigUInt.zero,
                                                                             gasLimit: BigUInt.zero,
                                                                             data: calldata)
            
            let estimateGas = try! self.zkSync.ethEstimateGas(estimate).wait()
            XCTAssertEqual(estimateGas, BigUInt(5897360))
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testEstimateGas_TransferNative() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let estimate = EthereumTransaction.createFunctionCallTransaction(from: self.credentials.ethereumAddress,
                                                                             to: self.credentials.ethereumAddress,
                                                                             gasPrice: BigUInt.zero,
                                                                             gasLimit: BigUInt.zero,
                                                                             data: Data(fromHex: "0x")!)
            
            let estimateGas = try! self.zkSync.ethEstimateGas(estimate).wait()
            XCTAssertEqual(estimateGas, BigUInt(2576507))
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testEstimateFee_TransferNative() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let estimate = EthereumTransaction.createFunctionCallTransaction(from: self.credentials.ethereumAddress,
                                                                             to: self.credentials.ethereumAddress,
                                                                             gasPrice: BigUInt.zero,
                                                                             gasLimit: BigUInt.zero,
                                                                             data: Data(fromHex: "0x")!)
            
            let estimateFee = try! self.zkSync.zksEstimateFee(estimate).wait()
            print("Estimate fee: \(estimateFee)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testEstimateGas_Execute() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let calldata = ZkERC20.encodeTransfer(EthereumAddress("0xe1fab3efd74a77c23b426c302d96372140ff7d0c")!,
                                                  value: BigUInt(1))
            
            print("calldata: \(calldata.toHexString().addHexPrefix())")
            
            let estimate = EthereumTransaction.createFunctionCallTransaction(from: self.credentials.ethereumAddress,
                                                                             to: EthereumAddress("0x79f73588fa338e685e9bbd7181b410f60895d2a3")!,
                                                                             gasPrice: BigUInt.zero,
                                                                             gasLimit: BigUInt.zero,
                                                                             data: calldata)
            
            let estimateGas = try! self.zkSync.ethEstimateGas(estimate).wait()
            print("estimateGas: \(estimateGas)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testEstimateGas_DeployContract() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let estimate = EthereumTransaction.create2ContractTransaction(from: self.credentials.ethereumAddress,
                                                                          gasPrice: BigUInt.zero,
                                                                          gasLimit: BigUInt.zero,
                                                                          bytecode: Data.fromHex(CounterContract.Binary)!)
            
            let estimateGas = try! self.zkSync.ethEstimateGas(estimate).wait()
            print("estimateGas: \(estimateGas)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testEstimateFee_DeployContract() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let estimate = EthereumTransaction.create2ContractTransaction(from: self.credentials.ethereumAddress,
                                                                          gasPrice: BigUInt.zero,
                                                                          gasLimit: BigUInt.zero,
                                                                          bytecode: Data(fromHex: CounterContract.Binary)!)
            
            let fee = try! self.zkSync.zksEstimateFee(estimate).wait()
            print("Fee: \(fee)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDeployWeb3jContract() {

    }
    
    func testWeb3jContract() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            var deploy = EthereumTransaction.createContractTransaction(from: self.credentials.ethereumAddress,
                                                                       gasPrice: BigUInt.zero,
                                                                       gasLimit: BigUInt.zero,
                                                                       bytecode: CounterContract.Binary)
            
            let nonce = try! self.zkSync.web3.eth.getTransactionCountPromise(address: self.credentials.ethereumAddress,
                                                                             onBlock: DefaultBlockParameterName.pending.rawValue).wait()
            
            let fee = try! self.zkSync.zksEstimateFee(deploy).wait()
            print("Fee: \(fee)")
            
            let gasPrice = try! self.zkSync.web3.eth.getGasPricePromise().wait()
            print("Gas price: \(gasPrice)")
            
            deploy.parameters.EIP712Meta?.gasPerPubdata = fee.gasPerPubdataLimit
            
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.type = .eip712
            transactionOptions.from = self.credentials.ethereumAddress
            transactionOptions.to = deploy.to
            transactionOptions.gasLimit = .manual(fee.gasLimit)
            transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
            transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
            transactionOptions.value = deploy.value
            transactionOptions.nonce = .manual(nonce)
            transactionOptions.chainID = self.chainId
            
            var ethereumParameters = EthereumParameters(from: transactionOptions)
            ethereumParameters.EIP712Meta = deploy.parameters.EIP712Meta
            
            var transaction = EthereumTransaction(type: .eip712,
                                                  to: deploy.to,
                                                  nonce: nonce,
                                                  chainID: self.chainId,
                                                  value: deploy.value,
                                                  data: deploy.data,
                                                  parameters: ethereumParameters)
            
            let signature = self.signer.signTypedData(self.signer.domain, typedData: transaction).addHexPrefix()
            print("signature: \(signature)")
            
            // assert(signature == "")
            
            let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
            transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
            transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
            transaction.envelope.v = BigUInt(unmarshalledSignature.v)
            
            guard let message = transaction.encode(for: .transaction) else {
                fatalError("Failed to encode transaction.")
            }
            
            print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
            
            let sent = try! self.zkSync.web3.eth.sendRawTransactionPromise(transaction).wait()
            print("Result: \(sent)")
            
            // TODO: Implement `CounterContract`.
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }
    
    func testDeployContract_Create() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let nonce = try! self.zkSync.web3.eth.getTransactionCountPromise(address: self.credentials.ethereumAddress,
                                                                             onBlock: DefaultBlockParameterName.pending.rawValue).wait()
            
            let nonceHolder = NonceHolder(EthereumAddress(ZkSyncAddresses.NonceHolderAddress)!,
                                          zkSync: self.zkSync,
                                          contractGasProvider: DefaultGasProvider(),
                                          credentials: self.credentials)
            
            let deploymentNonceData = try! nonceHolder.getDeploymentNonce(self.credentials.ethereumAddress).wait()
            
            let deploymentNonce = BigUInt(fromHex: deploymentNonceData.toHexString().addHexPrefix())!
            print("Deployment nonce: \(deploymentNonce)")
            
            let precomputedAddress = ContractDeployer.computeL2CreateAddress(self.credentials.ethereumAddress,
                                                                             nonce: deploymentNonce)
            
            var estimate = EthereumTransaction.createContractTransaction(from: self.credentials.ethereumAddress,
                                                                         gasPrice: BigUInt.zero,
                                                                         gasLimit: BigUInt.zero,
                                                                         bytecode: CounterContract.Binary)
            
            let fee = try! self.zkSync.zksEstimateFee(estimate).wait()
            print("Fee: \(fee)")
            
            let gasPrice = try! self.zkSync.web3.eth.getGasPricePromise().wait()
            print("Gas price: \(gasPrice)")
            
            estimate.parameters.EIP712Meta?.gasPerPubdata = fee.gasPerPubdataLimit
            
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.type = .eip712
            transactionOptions.from = self.credentials.ethereumAddress
            transactionOptions.to = estimate.to
            transactionOptions.gasLimit = .manual(fee.gasLimit)
            transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
            transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
            transactionOptions.value = estimate.value
            transactionOptions.nonce = .manual(nonce)
            transactionOptions.chainID = self.chainId
            
            var ethereumParameters = EthereumParameters(from: transactionOptions)
            ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta
            
            var transaction = EthereumTransaction(type: .eip712,
                                                  to: estimate.to,
                                                  nonce: nonce,
                                                  chainID: self.chainId,
                                                  value: estimate.value,
                                                  data: estimate.data,
                                                  parameters: ethereumParameters)
            
            let signature = self.signer.signTypedData(self.signer.domain, typedData: transaction).addHexPrefix()
            print("signature: \(signature)")
            
            // assert(signature == "")
            
            let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
            transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
            transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
            transaction.envelope.v = BigUInt(unmarshalledSignature.v)
            
            guard let message = transaction.encode(for: .transaction) else {
                fatalError("Failed to encode transaction.")
            }
            
            print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
            
            let sent = try! self.zkSync.web3.eth.sendRawTransactionPromise(transaction).wait()
            print("Result: \(sent)")
            
            // TODO: Implement `EthereumTransaction.createEthCallTransaction`.
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }
    
    func testDeployContractWithConstructor_Create() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let nonce = try! self.zkSync.web3.eth.getTransactionCountPromise(address: self.credentials.ethereumAddress,
                                                                             onBlock: DefaultBlockParameterName.pending.rawValue).wait()
            
            let nonceHolder = NonceHolder(EthereumAddress(ZkSyncAddresses.NonceHolderAddress)!,
                                          zkSync: self.zkSync,
                                          contractGasProvider: DefaultGasProvider(),
                                          credentials: self.credentials)
            
            let deploymentNonceData = try! nonceHolder.getDeploymentNonce(self.credentials.ethereumAddress).wait()
            
            let deploymentNonce = BigUInt(fromHex: deploymentNonceData.toHexString().addHexPrefix())!
            print("Deployment nonce: \(deploymentNonce)")
            
            let precomputedAddress = ContractDeployer.computeL2CreateAddress(self.credentials.ethereumAddress,
                                                                             nonce: deploymentNonce)
            
            let constructor = ConstructorContract.encodeConstructor(a: BigUInt(42),
                                                                    b: BigUInt(43),
                                                                    shouldRevert: false)
            
            let constructorContractBinaryFileURL = Bundle.module.url(forResource: "constructorContractBinary", withExtension: "hex")!
            let constructorContract = try! String(contentsOf: constructorContractBinaryFileURL, encoding: .ascii).trim()
            
            var estimate = EthereumTransaction.createContractTransaction(from: self.credentials.ethereumAddress,
                                                                         gasPrice: BigUInt.zero,
                                                                         gasLimit: BigUInt.zero,
                                                                         bytecode: constructorContract,
                                                                         calldata: constructor)
            
            let fee = try! self.zkSync.zksEstimateFee(estimate).wait()
            print("Fee: \(fee)")
            
            let gasPrice = try! self.zkSync.web3.eth.getGasPricePromise().wait()
            print("Gas price: \(gasPrice)")
            
            estimate.parameters.EIP712Meta?.gasPerPubdata = fee.gasPerPubdataLimit
            
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.type = .eip712
            transactionOptions.from = self.credentials.ethereumAddress
            transactionOptions.to = estimate.to
            transactionOptions.gasLimit = .manual(fee.gasLimit)
            transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
            transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
            transactionOptions.value = estimate.value
            transactionOptions.nonce = .manual(nonce)
            transactionOptions.chainID = self.chainId
            
            var ethereumParameters = EthereumParameters(from: transactionOptions)
            ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta
            
            var transaction = EthereumTransaction(type: .eip712,
                                                  to: estimate.to,
                                                  nonce: nonce,
                                                  chainID: self.chainId,
                                                  value: estimate.value,
                                                  data: estimate.data,
                                                  parameters: ethereumParameters)
            
            let signature = self.signer.signTypedData(self.signer.domain, typedData: transaction).addHexPrefix()
            print("signature: \(signature)")
            
            // assert(signature == "")
            
            let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
            transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
            transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
            transaction.envelope.v = BigUInt(unmarshalledSignature.v)
            
            guard let message = transaction.encode(for: .transaction) else {
                fatalError("Failed to encode transaction.")
            }
            
            print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
            
            let sent = try! self.zkSync.web3.eth.sendRawTransactionPromise(transaction).wait()
            print("Result: \(sent)")
            
            Thread.sleep(forTimeInterval: 1.0)
            
            let transactionReceipt = try! self.zkSync.web3.eth.getTransactionReceiptPromise(sent.hash).wait()
            print("Transaction receipt: \(transactionReceipt)")
            XCTAssertEqual(transactionReceipt.status, .ok)
            
            // TODO: Implement `EthereumTransaction.createEthCallTransaction`.
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }
    
    func testDeployContract_Create2() {
        
    }
    
    func testDeployContractWithDeps_Create() {
        
    }
    
    func testDeployContractWithDeps_Create2() {
        
    }
    
    func testExecuteContract() {
        
    }
    
    func testGetAllAccountBalances() {
        let expectation = expectation(description: "Expectation")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let accountBalances = try! self.zkSync.zksGetAllAccountBalances(self.credentials.address).wait()
            print("Account balances: \(accountBalances)")
            
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
    
    func testGetMainContract() {
        let expectation = expectation(description: "Expectation.")
        
        zkSync.zksMainContract { result in
            switch result {
            case .success(let mainContract):
                print(mainContract)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGetTransactionDetails() {
        let expectation = expectation(description: "Expectation.")
        
        zkSync.zksGetTransactionDetails("0x0898f4b225276625e1d5d2cc4dc5b7a1acb896daece7e46c8202a47da9a13a27",
                                        completion: { result in
            switch result {
            case .success(let transactionDetails):
                print(transactionDetails)
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 5.0)
    }
}
