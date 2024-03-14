//
//  ZkTransactionEncoderTests.swift
//  ZkSync2Tests
//
//  Created by Maxim Makhun on 9/24/22.
//

import XCTest
@testable import ZkSync2
import web3swift
import Web3Core
import BigInt

class ZkTransactionEncoderTests: XCTestCase {
    
//    static let BridgeAddress = EthereumAddress("0x8c98381FfE6229Ee9E53B6aAb784E86863f61885")!
//    static let ChainId = BigUInt(270)
//    static let GasPrice = BigUInt(43)
//    static let GasLimit = BigUInt(42)
//    static let Address = EthereumAddress("0x7e5f4552091a69125d5dfcb7b8c2659029395bdf")!
//    
//    let credentials = Credentials(BigUInt.one)
//    
//    override func setUpWithError() throws {
//        
//    }
//    
//    override func tearDownWithError() throws {
//        
//    }
//    
//    func testEncodeWithdrawEIP1559() {
//        let inputs = [
//            ABI.Element.InOut(name: "_l1Receiver", type: .address),
//            ABI.Element.InOut(name: "_l2Token", type: .address),
//            ABI.Element.InOut(name: "_amount", type: .uint(bits: 256))
//        ]
//        
//        let function = ABI.Element.Function(name: "withdraw",
//                                            inputs: inputs,
//                                            outputs: [],
//                                            constant: false,
//                                            payable: false)
//        
//        let elementFunction: ABI.Element = .function(function)
//        
//        let parameters: [AnyObject] = [
//            "0x7e5f4552091a69125d5dfcb7b8c2659029395bdf" as AnyObject,
//            Token.ETH.l2Address as AnyObject,
//            BigInt("1000000000000000000") as AnyObject
//        ]
//        
//        guard let calldata = elementFunction.encodeParameters(parameters) else {
//            XCTFail("Encoded function should be valid.")
//            return
//        }
//        
//        let expectedCalldata = "0xd9caed120000000000000000000000007e5f4552091a69125d5dfcb7b8c2659029395bdf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000de0b6b3a7640000"
//        XCTAssertEqual(calldata.toHexString(), expectedCalldata)
//        
//        var transactionOptions = TransactionOptions.defaultOptions
//        transactionOptions.type = .eip1559
//        transactionOptions.chainID = ZkTransactionEncoderTests.ChainId
//        transactionOptions.nonce = .manual(BigUInt.zero)
//        transactionOptions.gasLimit = .manual(ZkTransactionEncoderTests.GasLimit)
//        transactionOptions.gasPrice = nil
//        transactionOptions.to = ZkTransactionEncoderTests.BridgeAddress
//        transactionOptions.value = BigUInt.zero
//        transactionOptions.maxPriorityFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
//        transactionOptions.maxFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
//        transactionOptions.callOnBlock = nil
//        
//        let ethereumParameters = EthereumParameters(from: transactionOptions)
//        let transaction = CodableTransaction(type: .eip1559,
//                                              to: ZkTransactionEncoderTests.BridgeAddress,
//                                              nonce: BigUInt.zero,
//                                              chainID: ZkTransactionEncoderTests.ChainId,
//                                              value: BigUInt.zero,
//                                              data: calldata)
//        
//        // FIXME: Transaction encoding should be used.
//        guard let encodedTransaction = transaction.encode(for: .signature)?.toHexString() else {
//            XCTFail("Encoded transaction should be valid.")
//            return
//        }
//        print("Encoded transaction: \(encodedTransaction)")
//        
//        let expectedEncodedTransaction = "0x02f88482010e802b2b2a948c98381ffe6229ee9e53b6aab784e86863f6188580b864d9caed120000000000000000000000007e5f4552091a69125d5dfcb7b8c2659029395bdf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000de0b6b3a7640000c0"
//        XCTAssertEqual(encodedTransaction, expectedEncodedTransaction)
//    }
//    
//    func testEncodeWithdrawEIP712() {
//        let inputs = [
//            ABI.Element.InOut(name: "_l1Receiver", type: .address),
//            ABI.Element.InOut(name: "_l2Token", type: .address),
//            ABI.Element.InOut(name: "_amount", type: .uint(bits: 256))
//        ]
//        
//        let function = ABI.Element.Function(name: "withdraw",
//                                            inputs: inputs,
//                                            outputs: [],
//                                            constant: false,
//                                            payable: false)
//        
//        let elementFunction: ABI.Element = .function(function)
//        
//        let parameters: [AnyObject] = [
//            ZkTransactionEncoderTests.Address as AnyObject,
//            Token.ETH.l2Address as AnyObject,
//            BigInt("1000000000000000000") as AnyObject
//        ]
//        
//        guard let calldata = elementFunction.encodeParameters(parameters) else {
//            XCTFail("Encoded function should be valid.")
//            return
//        }
//        
//        let expectedCalldata = "0xd9caed120000000000000000000000007e5f4552091a69125d5dfcb7b8c2659029395bdf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000de0b6b3a7640000"
//        XCTAssertEqual(calldata.toHexString(), expectedCalldata)
//        
//        var transactionOptions = TransactionOptions.defaultOptions
//        transactionOptions.type = .eip712
//        transactionOptions.chainID = ZkTransactionEncoderTests.ChainId
//        transactionOptions.nonce = .manual(BigUInt.zero)
//        transactionOptions.gasLimit = .manual(ZkTransactionEncoderTests.GasLimit)
//        transactionOptions.gasPrice = nil
//        transactionOptions.to = ZkTransactionEncoderTests.BridgeAddress
//        transactionOptions.value = BigUInt.zero
//        transactionOptions.maxPriorityFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
//        transactionOptions.maxFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
//        transactionOptions.callOnBlock = nil
//        transactionOptions.from = ZkTransactionEncoderTests.Address
//        
//        var ethereumParameters = EthereumParameters(from: transactionOptions)
//        
//        var EIP712Meta = EIP712Meta()
//        EIP712Meta.gasPerPubdata = BigUInt.zero
//        EIP712Meta.customSignature = Data()
//        ethereumParameters.eip712Meta = EIP712Meta
//        
//        let transaction = CodableTransaction(type: .eip712,
//                                              to: ZkTransactionEncoderTests.BridgeAddress,
//                                              nonce: BigUInt.zero,
//                                              chainID: ZkTransactionEncoderTests.ChainId,
//                                              value: BigUInt.zero,
//                                              data: calldata)
//        
//        guard let encodedTransaction = transaction.encode(for: .transaction)?.toHexString() else {
//            XCTFail("Encoded transaction should be valid.")
//            return
//        }
//        
//        let transactionAsDictionary = transaction.encodeAsDictionary()
//        print("Encoded transaction as dictionary \(String(describing: transactionAsDictionary))")
//        
//        let expectedEncodedTransaction = "0x71f8a1802b2b2a948c98381ffe6229ee9e53b6aab784e86863f6188580b864d9caed120000000000000000000000007e5f4552091a69125d5dfcb7b8c2659029395bdf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000de0b6b3a764000082010e808082010e947e5f4552091a69125d5dfcb7b8c2659029395bdf80c080c0"
//        XCTAssertEqual(encodedTransaction, expectedEncodedTransaction)
//    }
//    
//    func testEncodeDeploy() {
//        let bytecodeBytes = Data(from: CounterContract.Binary)!
//        let calldata = ContractDeployer.encodeCreate2(bytecodeBytes)
//        print("calldata: \(calldata)")
//        
//        let transaction = deployTransaction(calldata, bytecodeBytes: bytecodeBytes)
//        
//        guard let encodedTransaction = transaction.encode(for: .transaction) else {
//            fatalError("Failed to encode transaction.")
//        }
//        
//        print("Encoded transaction: \(encodedTransaction.toHexString().addHexPrefix())")
//        
//        XCTAssertEqual(encodedTransaction.toHexString().addHexPrefix(), "0x71f90ae6802b2b2a94000000000000000000000000000000000000800680b8843cda33510000000000000000000000000000000000000000000000000000000000000000010000517112c421df08d7b49e4dc1312f4ee62268ee4f5683b11d9e2d33525a0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000082010e808082010e947e5f4552091a69125d5dfcb7b8c2659029395bdf80f90a23b90a20000200000000000200010000000103550000006001100270000000410010019d000000010120018f000000000110004c000000080000c13d00fd00180000040f00fd00090000040f0000008001000039000000400200003900000000001204350000000001000416000000000110004c000000160000c13d000000200100003900000100020000390000000000120439000001200100003900000000000104390000004201000041000000fe0001042e0000000001000019000000ff0001043000040000000000020000000001000410000080020210008c000000330000613d0000000002000411000080010220008c000000330000613d0000004302000041000000000020043900000004020000390000000000120439000000440100004100008002020000390000000003000415000000040330008a00000020033000c900fd00e00000040f000000ff01000039000000030110024f000000000110004c000000560000613d000000040100035f000000000101043b000000000110004c000000330000c13d0000000001000019000000fe0001042e0000008001000039000000400600003900000000001604350000000001000031000000030210008c000000540000a13d0000000102000367000000000302043b000000e003300270000000450430009c0000006c0000613d000000460230009c000000580000613d000000470230009c000000540000c13d0000000002000416000000000220004c000000800000c13d000000040110008a00000048020000410000001f0310008c000000000300001900000000030220190000004801100197000000000410004c0000000002008019000000480110009c00000000010300190000000001026019000000000110004c0000008e0000c13d0000000001000019000000ff000104300000000001000019000000ff000104300000000001000019000000ff000104300000000002000416000000000220004c0000007e0000c13d000000040110008a000000010200008a0000004803000041000000000221004b000000000200001900000000020320190000004801100197000000480410009c00000000030080190000004801100167000000480110009c00000000010200190000000001036019000000000110004c000000840000c13d0000000001000019000000ff000104300000000003000416000000000330004c000000820000c13d000000040110008a00000048030000410000003f0410008c000000000400001900000000040320190000004801100197000000000510004c0000000003008019000000480110009c00000000010400190000000001036019000000000110004c000000a20000c13d0000000001000019000000ff000104300000000001000019000000ff000104300000000001000019000000ff000104300000000001000019000000ff000104300000000001000019000200000006001d00fd00fb0000040f000000020200002900000000020204330000000000120435000000400120021000000049011001970000004c011001c7000000fe0001042e000200000006001d000000000100001900fd00fb0000040f00000001020003670000000402200370000000000202043b0000000001120019000000000221004b00000000020000190000000102004039000000010220018f000000000220004c000000be0000613d0000004a0100004100000000001004350000001101000039000000040200003900000000001204350000004b01000041000000ff000104300000002401200370000000000201043b000000000120004c0000000001000019000000010100c039000000000112004b000000c50000c13d000100000002001d000200000006001d000000000100001900fd00fb0000040f00000001020003670000000402200370000000000202043b0000000001120019000000000221004b00000000020000190000000102004039000000010220018f000000000220004c000000c70000613d0000004a0100004100000000001004350000001101000039000000040200003900000000001204350000004b01000041000000ff00010430000000000200001900fd00f90000040f0000000201000029000000000101043300000040011002100000004901100197000000fe0001042e0000000001000019000000ff00010430000000000200001900fd00f90000040f000000020100002900000000010104330000000102000029000000000220004c000000d10000c13d00000040011002100000004901100197000000fe0001042e00000044021000390000004d03000041000000000032043500000024021000390000001a0300003900000000003204350000004e020000410000000000210435000000040210003900000020030000390000000000320435000000400110021000000049011001970000004f011001c7000000ff000104300002000000000002000200000003001d0000002003300039000100000003001d000000ef002104230000000203000029000000200230011a000000000201035500000048010000410000000102000029000000200220011a00000000021201bd00000000010300190000000200000005000000000001042d0000000203000029000000200230011a000000000201035500000050010000410000000102000029000000200220011a000000000212018d00000000010300190000000200000005000000000001042d000000000012041b000000000001042d000000000101041a000000000001042d000000fd00000432000000fe0001042e000000ff00010430000000000000000100000000000000010000000000000001000000000000000100000000000000000000000000000000000000000000000000000000ffffffff00000002000000000000000000000000000000400000010000000000000000001806aa1896bbf26568e884a7374b41e002500962caba6a15023a8d90e8508b830200020000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000436dad6000000000000000000000000000000000000000000000000000000006d4ce63c000000000000000000000000000000000000000000000000000000007cf5dab080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffff00000000000000004e487b71000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000002000000000000000000000000054686973206d6574686f6420616c77617973207265766572747300000000000008c379a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000640000000000000000000000007fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff80c0")
//    }
//    
//    func deployTransaction(_ data: Data, bytecodeBytes: Data) -> CodableTransaction {
//        print("Data: \(data.toHexString())")
//        print("Bytecode bytes: \(bytecodeBytes.toHexString())")
//        
//        var transactionOptions = TransactionOptions.defaultOptions
//        
////        let type: TransactionType = .eip712
////        transactionOptions.type = type
//        
//        let chainID = ZkTransactionEncoderTests.ChainId
//        transactionOptions.chainID = chainID
//        let nonce = BigUInt.zero
//        transactionOptions.nonce = .manual(nonce)
//        transactionOptions.gasLimit = .manual(ZkTransactionEncoderTests.GasLimit)
//        let to = EthereumAddress(ZkSyncAddresses.ContractDeployerAddress)!
//        transactionOptions.to = to
//        
//        let value = BigUInt.zero
//        transactionOptions.value = value
//        transactionOptions.maxPriorityFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
//        transactionOptions.maxFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
//        transactionOptions.from = credentials.ethereumAddress
//        var ethereumParameters = EthereumParameters(from: transactionOptions)
//        
//        var EIP712Meta = EIP712Meta()
//        EIP712Meta.gasPerPubdata = BigUInt.zero
//        EIP712Meta.customSignature = Data()
//        EIP712Meta.factoryDeps = [bytecodeBytes]
//        EIP712Meta.paymasterParams = nil
//        ethereumParameters.eip712Meta = EIP712Meta
//        
//        ethereumParameters.from = credentials.ethereumAddress
//        
//        let ethereumTransaction = CodableTransaction(type: type,
//                                                      to: to,
//                                                      nonce: nonce,
//                                                      chainID: chainID,
//                                                      value: value,
//                                                      data: data,
//                                                      parameters: ethereumParameters)
//        
//        return ethereumTransaction
//    }
//    
//    func testEncodeExecute() {
//        let encodedFunction = CounterContract.encodeIncrement(BigUInt(42))
//        XCTAssertEqual(encodedFunction.toHexString().addHexPrefix(), "0x7cf5dab0000000000000000000000000000000000000000000000000000000000000002a")
//        
//        let transaction = executeTransaction(encodedFunction)
//        
//        guard let encodedTransaction = transaction.encode(for: .transaction) else {
//            fatalError("Failed to encode transaction.")
//        }
//        
//        print("Encoded transaction: \(encodedTransaction.toHexString().addHexPrefix())")
//        
//        XCTAssertEqual(encodedTransaction.toHexString().addHexPrefix(), "0x71f860802b2b2a94e1fab3efd74a77c23b426c302d96372140ff7d0c80a47cf5dab0000000000000000000000000000000000000000000000000000000000000002a82010e808082010e947e5f4552091a69125d5dfcb7b8c2659029395bdf80c080c0")
//    }
//    
//    func executeTransaction(_ data: Data) -> EthereumTransaction {
//        var transactionOptions = TransactionOptions.defaultOptions
//        
//        let type: TransactionType = .eip712
//        transactionOptions.type = type
//        
//        let chainID = ZkTransactionEncoderTests.ChainId
//        transactionOptions.chainID = chainID
//        let nonce = BigUInt.zero
//        transactionOptions.nonce = .manual(nonce)
//        transactionOptions.gasLimit = .manual(ZkTransactionEncoderTests.GasLimit)
//        let to = EthereumAddress("0xe1fab3efd74a77c23b426c302d96372140ff7d0c")!
//        transactionOptions.to = to
//        
//        let value = BigUInt.zero
//        transactionOptions.value = value
//        transactionOptions.maxPriorityFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
//        transactionOptions.maxFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
//        transactionOptions.from = credentials.ethereumAddress
//        var ethereumParameters = EthereumParameters(from: transactionOptions)
//        
//        var EIP712Meta = EIP712Meta()
//        EIP712Meta.gasPerPubdata = BigUInt.zero
//        EIP712Meta.customSignature = Data()
//        EIP712Meta.factoryDeps = nil
//        EIP712Meta.paymasterParams = nil
//        ethereumParameters.EIP712Meta = EIP712Meta
//        
//        ethereumParameters.from = credentials.ethereumAddress
//        
//        let ethereumTransaction = EthereumTransaction(type: type,
//                                                      to: to,
//                                                      nonce: nonce,
//                                                      chainID: chainID,
//                                                      value: value,
//                                                      data: data,
//                                                      parameters: ethereumParameters)
//        
//        return ethereumTransaction
//    }
}
