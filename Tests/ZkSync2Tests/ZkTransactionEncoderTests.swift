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
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testEncodeWithdraw() {
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
        
        // zksync2-java
        //        Transaction1559 transaction1559 = new Transaction1559(
        //                0, // chainId
        //                BigInteger.valueOf(0), // nonce
        //                BigInteger.valueOf(0), // gasLimit
        //                "0x8c98381FfE6229Ee9E53B6aAb784E86863f61885", // to
        //                BigInteger.valueOf(0), // value
        //                "", // data
        //                BigInteger.valueOf(0), // maxPriorityFeePerGas
        //                BigInteger.valueOf(0) // maxFeePerGas
        //        );
        
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip1559
        transactionOptions.chainID = BigUInt(0)
        transactionOptions.nonce = .manual(BigUInt(0))
        transactionOptions.gasLimit = .manual(BigUInt(0))
        transactionOptions.gasPrice = nil
        transactionOptions.to = EthereumAddress("0x8c98381FfE6229Ee9E53B6aAb784E86863f61885")!
        transactionOptions.value = BigUInt(0)
        transactionOptions.maxPriorityFeePerGas = .manual(BigUInt(0))
        transactionOptions.maxFeePerGas = .manual(BigUInt(0))
        transactionOptions.callOnBlock = nil
        
        let ethereumParameters = EthereumParameters(from: transactionOptions)
        let transaction = EthereumTransaction(type: .eip1559,
                                              to: EthereumAddress("0x8c98381FfE6229Ee9E53B6aAb784E86863f61885")!,
                                              nonce: BigUInt(0),
                                              chainID: BigUInt(0),
                                              value: BigUInt(0),
                                              data: "".data(using: .ascii)!,
                                              parameters: ethereumParameters)
        
        let encodedTransaction = transaction.encode(for: .signature)?.toHexString().addHexPrefix()
        let expectedEncodedTransaction = "0x02dd8080808080948c98381ffe6229ee9e53b6aab784e86863f618858080c0"
        XCTAssertEqual(encodedTransaction, expectedEncodedTransaction)
    }
    
    func testEncodeDeploy() {
        
    }
    
    func testEncodeExecute() {
        
    }
}
