//
//  CustomPaymasterTests.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/8/22.
//

import XCTest
@testable import ZkSync2
import web3swift
import BigInt

class CustomPaymasterTests: BaseIntegrationEnv {
    
    let salt = "TestPaymaster".data(using: .ascii)!.sha3(.keccak256).toHexString().addHexPrefix()
    
    let token = Token(l1Address: "0xd35cceead182dcee0f148ebac9447da2c4d449c4",
                      l2Address: "0x72c4f199cb8784425542583d345e7c00d642e345",
                      symbol: "USDC",
                      decimals: 6)
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let expectation = expectation(description: "Expectation.")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            XCTAssertEqual(self.salt, "0xe40ea7e9177d58c620a00ffe31df0b825fed6239a4626dbf8591decf5575c7ad")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testDeployPaymaster() {
        let expectation = expectation(description: "Expectation.")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            if self.isDeployed() {
                XCTFail("Test paymaster should not be deployed")
                return
            }
            
            let nonce = try! self.zkSync.web3.eth.getTransactionCount(address: self.credentials.ethereumAddress,
                                                                      onBlock: DefaultBlockParameterName.pending.rawValue)
            
            let constructor = ""
            
            let precomputedAddress = self.paymasterAddress()
            
            let customPaymasterBinaryFileURL = Bundle.module.url(forResource: "customPaymasterBinary", withExtension: "hex")!
            let customPaymasterBinaryContents = try! String(contentsOf: customPaymasterBinaryFileURL, encoding: .ascii).trim().addHexPrefix()
            
            let estimate = EthereumTransaction.create2ContractTransaction(from: self.credentials.ethereumAddress,
                                                                          ergsPrice: BigUInt.zero,
                                                                          ergsLimit: BigUInt.zero,
                                                                          bytecode: Data.fromHex(customPaymasterBinaryContents)!,
                                                                          calldata: Data.fromHex(constructor)!,
                                                                          salt: Data.fromHex(self.salt)!)
            
            let estimateGas = try! self.zkSync.ethEstimateGas(estimate).wait()
            print("estimateGas: \(estimateGas)")
            
            let gasPrice = try! self.zkSync.web3.eth.getGasPricePromise().wait()
            print("gasPrice: \(gasPrice)")
            
            print("Fee for transaction is: \(estimateGas.multiplied(by: gasPrice))")
            
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.type = .eip712
            transactionOptions.from = self.credentials.ethereumAddress
            transactionOptions.to = estimate.to
            transactionOptions.gasLimit = .manual(estimateGas)
            transactionOptions.maxPriorityFeePerGas = .manual(BigUInt(100000000))
            transactionOptions.maxFeePerGas = .manual(gasPrice)
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
    
    func testSendFundsForFee() {
        
    }
    
    func testSendFundsWithPaymaster() {
        
    }
    
    func checkBalance() {
        let balance = try! zkSync.web3.eth.getBalancePromise(address: credentials.ethereumAddress,
                                                             onBlock: DefaultBlockParameterName.pending.rawValue).wait()
        
        let balanceThreshold = Web3.Utils.parseToBigUInt("0.005", units: .eth)!
        
        if balanceThreshold > balance {
            fatalError("Not enough balance of the wallet (min 0.005 ETH): \(credentials.address)")
        }
    }
    
    func isDeployed() -> Bool {
        let paymasterAddress = EthereumAddress(fromHex: paymasterAddress())!
        let code = try! zkSync.web3.eth.getCodePromise(address: paymasterAddress,
                                                       onBlock: ZkBlockParameterName.committed.rawValue).wait()
        
        return code.count > 0
    }
    
    func paymasterAddress() -> String {
        return try! zkSync.zksGetTestnetPaymaster().wait()
    }
}
