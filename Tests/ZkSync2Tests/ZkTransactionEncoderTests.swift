//
//  ZkTransactionEncoderTests.swift
//  ZkSync2Tests
//
//  Created by Maxim Makhun on 9/24/22.
//

import XCTest
@testable import ZkSync2
import web3swift
import BigInt

class ZkTransactionEncoderTests: XCTestCase {
    
    static let BridgeAddress = EthereumAddress("0x8c98381FfE6229Ee9E53B6aAb784E86863f61885")!
    static let ChainId = BigUInt(270)
    static let GasPrice = BigUInt(43)
    static let GasLimit = BigUInt(42)
    static let Address = EthereumAddress("0x7e5f4552091a69125d5dfcb7b8c2659029395bdf")!
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testEncodeWithdrawEIP1559() {
        let inputs = [
            ABI.Element.InOut(name: "_l1Receiver", type: .address),
            ABI.Element.InOut(name: "_l2Token", type: .address),
            ABI.Element.InOut(name: "_amount", type: .uint(bits: 256))
        ]
        
        let function = ABI.Element.Function(name: "withdraw",
                                            inputs: inputs,
                                            outputs: [],
                                            constant: false,
                                            payable: false)
        
        let elementFunction: ABI.Element = .function(function)
        
        let parameters: [AnyObject] = [
            "0x7e5f4552091a69125d5dfcb7b8c2659029395bdf" as AnyObject,
            Token.ETH.l2Address as AnyObject,
            BigInt("1000000000000000000") as AnyObject
        ]
        
        guard let calldata = elementFunction.encodeParameters(parameters) else {
            XCTFail("Encoded function should be valid.")
            return
        }
        
        let expectedCalldata = "0xd9caed120000000000000000000000007e5f4552091a69125d5dfcb7b8c2659029395bdf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000de0b6b3a7640000"
        XCTAssertEqual(calldata.toHexString().addHexPrefix(), expectedCalldata)
        
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip1559
        transactionOptions.chainID = ZkTransactionEncoderTests.ChainId
        transactionOptions.nonce = .manual(BigUInt.zero)
        transactionOptions.gasLimit = .manual(ZkTransactionEncoderTests.GasLimit)
        transactionOptions.gasPrice = nil
        transactionOptions.to = ZkTransactionEncoderTests.BridgeAddress
        transactionOptions.value = BigUInt.zero
        transactionOptions.maxPriorityFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
        transactionOptions.maxFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
        transactionOptions.callOnBlock = nil
        
        let ethereumParameters = EthereumParameters(from: transactionOptions)
        let transaction = EthereumTransaction(type: .eip1559,
                                              to: ZkTransactionEncoderTests.BridgeAddress,
                                              nonce: BigUInt.zero,
                                              chainID: ZkTransactionEncoderTests.ChainId,
                                              value: BigUInt.zero,
                                              data: calldata,
                                              parameters: ethereumParameters)
        
        guard let encodedTransaction = transaction.encode(for: .signature)?.toHexString().addHexPrefix() else {
            XCTFail("Encoded transaction should be valid.")
            return
        }
        print("Encoded transaction: \(encodedTransaction)")
        
        let expectedEncodedTransaction = "0x02f88482010e802b2b2a948c98381ffe6229ee9e53b6aab784e86863f6188580b864d9caed120000000000000000000000007e5f4552091a69125d5dfcb7b8c2659029395bdf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000de0b6b3a7640000c0"
        XCTAssertEqual(encodedTransaction, expectedEncodedTransaction)
    }
    
    func testEncodeWithdrawEIP712() {
        let inputs = [
            ABI.Element.InOut(name: "_l1Receiver", type: .address),
            ABI.Element.InOut(name: "_l2Token", type: .address),
            ABI.Element.InOut(name: "_amount", type: .uint(bits: 256))
        ]
        
        let function = ABI.Element.Function(name: "withdraw",
                                            inputs: inputs,
                                            outputs: [],
                                            constant: false,
                                            payable: false)
        
        let elementFunction: ABI.Element = .function(function)
        
        let parameters: [AnyObject] = [
            ZkTransactionEncoderTests.Address as AnyObject,
            Token.ETH.l2Address as AnyObject,
            BigInt("1000000000000000000") as AnyObject
        ]
        
        guard let calldata = elementFunction.encodeParameters(parameters) else {
            XCTFail("Encoded function should be valid.")
            return
        }
        
        let expectedCalldata = "0xd9caed120000000000000000000000007e5f4552091a69125d5dfcb7b8c2659029395bdf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000de0b6b3a7640000"
        XCTAssertEqual(calldata.toHexString().addHexPrefix(), expectedCalldata)
        
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.chainID = ZkTransactionEncoderTests.ChainId
        transactionOptions.nonce = .manual(BigUInt.zero)
        transactionOptions.gasLimit = .manual(ZkTransactionEncoderTests.GasLimit)
        transactionOptions.gasPrice = nil
        transactionOptions.to = ZkTransactionEncoderTests.BridgeAddress
        transactionOptions.value = BigUInt.zero
        transactionOptions.maxPriorityFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
        transactionOptions.maxFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
        transactionOptions.callOnBlock = nil
        transactionOptions.from = ZkTransactionEncoderTests.Address
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.ergsPerPubdata = BigUInt.zero
        EIP712Meta.customSignature = Data()
        ethereumParameters.EIP712Meta = EIP712Meta
        
        let transaction = EthereumTransaction(type: .eip712,
                                              to: ZkTransactionEncoderTests.BridgeAddress,
                                              nonce: BigUInt.zero,
                                              chainID: ZkTransactionEncoderTests.ChainId,
                                              value: BigUInt.zero,
                                              data: calldata,
                                              parameters: ethereumParameters)
        
        guard let encodedTransaction = transaction.encode(for: .signature)?.toHexString().addHexPrefix() else {
            XCTFail("Encoded transaction should be valid.")
            return
        }
        print("Encoded transaction: \(encodedTransaction)")
        
        let expectedEncodedTransaction = "0x71f8a1802b2b2a948c98381ffe6229ee9e53b6aab784e86863f6188580b864d9caed120000000000000000000000007e5f4552091a69125d5dfcb7b8c2659029395bdf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000de0b6b3a764000082010e808082010e947e5f4552091a69125d5dfcb7b8c2659029395bdf80c080c0"
        XCTAssertEqual(encodedTransaction, expectedEncodedTransaction)
    }
    
    func testEncodeDeploy() {
        
    }
    
    func testEncodeExecute() {
        
    }
}
