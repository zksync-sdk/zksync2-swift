//
//  PaymasterIntegrationTests.swift
//
//
//  Created by Petar Kopestinskij on 13.3.24..
//

import XCTest
@testable import ZkSync2
import web3swift
import Web3Core
import Foundation
import BigInt

class PaymasterTests: BaseIntegrationEnv {
    
    let SALT = "0x293328ad84b118194c65a0dc0defdb6483740d3163fd99b260907e15f2e2f642"
    let PAYMASTER_ADDRESS = "0x594E77D36eB367b3AbAb98775c99eB383079F966"
    
    func testDepolyPaymaster() async {
        let nonce = try! await self.zkSync.web3.eth.getTransactionCount(for: self.credentials.ethereumAddress)
        
        let constructor = ""
        
        let precomputedAddress = PAYMASTER_ADDRESS
        
        let customPaymasterBinaryFileURL = Bundle.module.url(forResource: "customPaymasterBinary", withExtension: "hex")!
        let customPaymasterBinaryContents = try! String(contentsOf: customPaymasterBinaryFileURL, encoding: .ascii).trim()
        
        let estimate = CodableTransaction.create2ContractTransaction(from: self.credentials.ethereumAddress, gasPrice: BigUint.zero, gasLimit: BigUInt.zero, bytecode: <#T##Data#>, deps: <#T##[Data]#>, salt: <#T##Data#>, chainId: <#T##BigUInt#>)
        let estimate = CodableTransaction.create2ContractTransaction(from: self.credentials.ethereumAddress,
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
    }
}
