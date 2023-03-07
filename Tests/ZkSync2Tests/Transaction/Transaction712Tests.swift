//
//  Transaction712Tests.swift
//  ZkSync2Tests
//
//  Created by Maxim Makhun on 9/25/22.
//

import XCTest
@testable import ZkSync2
import web3swift
import BigInt

class Transaction712Tests: XCTestCase {
    
    static let Sender = EthereumAddress("0x1234512345123451234512345123451234512345")!
    static let Receiver = EthereumAddress("0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC")!
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testEncodeToEIP712TypeString() {
        let transactionRequest = buildTransaction()
        let encodedType = transactionRequest.encodeType()
        
        XCTAssertEqual(encodedType, "Transaction(uint256 txType,uint256 from,uint256 to,uint256 gasLimit,uint256 gasPerPubdataByteLimit,uint256 maxFeePerGas,uint256 maxPriorityFeePerGas,uint256 paymaster,uint256 nonce,uint256 value,bytes data,bytes32[] factoryDeps,bytes paymasterInput)")
    }
    
    func testSerializeToEIP712EncodedValue() {
        let transactionRequest = buildTransaction()
        let encodedTransaction = EIP712Encoder.encodeValue(transactionRequest)
        
        print("Encoded transaction: \(encodedTransaction.toHexString().addHexPrefix())")
        
        XCTAssertEqual(encodedTransaction.toHexString().addHexPrefix(), "0x1e40bcee418db11047ffefb27b304f8ec1b5d644c35c56878f5cc12988b3162d")
    }
    
    func testSerializeToEIP712Message() {
        let transactionRequest = buildTransaction()
        let EIP712Domain = EIP712Domain(ZkSyncNetwork.localhost)
        let encoded = EIP712Encoder.typedDataToSignedBytes(EIP712Domain,
                                                           typedData: transactionRequest)
        
        print("Encoded EIP712Domain: \(encoded.toHexString().addHexPrefix())")
        
        XCTAssertEqual(encoded.toHexString().addHexPrefix(), "0x2506074540188226a81a8dc006ab311c06b680232d39699d348e8ec83c81388b")
    }
    
    func buildTransaction() -> EthereumTransaction {
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        let chainID = BigUInt(42)
        transactionOptions.chainID = chainID
        let nonce = BigUInt(42)
        transactionOptions.nonce = .manual(nonce)
        transactionOptions.gasLimit = .manual(BigUInt(54321))
        transactionOptions.to = Transaction712Tests.Receiver
        let value = BigUInt.zero
        transactionOptions.value = value
        transactionOptions.maxPriorityFeePerGas = .manual(BigUInt.zero)
        transactionOptions.maxFeePerGas = .manual(BigUInt.zero)
        transactionOptions.from = Transaction712Tests.Sender
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt.zero
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = nil
        EIP712Meta.paymasterParams = PaymasterParams()
        ethereumParameters.EIP712Meta = EIP712Meta
        
        ethereumParameters.from = Transaction712Tests.Sender
        
        let encodedFunction = CounterContract.encodeIncrement(BigUInt(42))
        XCTAssertEqual(encodedFunction.toHexString().addHexPrefix(), "0x7cf5dab0000000000000000000000000000000000000000000000000000000000000002a")
        
        let ethereumTransaction = EthereumTransaction(type: .eip712,
                                                      to: Transaction712Tests.Receiver,
                                                      nonce: nonce,
                                                      chainID: chainID,
                                                      value: value,
                                                      data: encodedFunction,
                                                      parameters: ethereumParameters)
        
        return ethereumTransaction
    }
}
