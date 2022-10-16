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
    
    let credentials = Credentials(BigUInt.one)
    
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
        
        // FIXME: Transaction encoding should be used.
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
        
        guard let encodedTransaction = transaction.encode(for: .transaction)?.toHexString().addHexPrefix() else {
            XCTFail("Encoded transaction should be valid.")
            return
        }
        
        let transactionAsDictionary = transaction.encodeAsDictionary()
        print("Encoded transaction as dictionary \(String(describing: transactionAsDictionary))")
        
        let expectedEncodedTransaction = "0x71f8a1802b2b2a948c98381ffe6229ee9e53b6aab784e86863f6188580b864d9caed120000000000000000000000007e5f4552091a69125d5dfcb7b8c2659029395bdf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000de0b6b3a764000082010e808082010e947e5f4552091a69125d5dfcb7b8c2659029395bdf80c080c0"
        XCTAssertEqual(encodedTransaction, expectedEncodedTransaction)
    }
    
    func testEncodeDeploy() {
        let bytecodeBytes = Data(fromHex: CounterContract.Binary)!
        let calldata = ContractDeployer.encodeCreate2(bytecodeBytes)
        let transaction = deployTransaction(calldata, bytecodeBytes: bytecodeBytes)
        
        guard let encodedTransaction = transaction.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }
        
        print("Encoded transaction: \(encodedTransaction.toHexString().addHexPrefix())")
        
        // FIXME: Encoded transaction is not valid.
        XCTAssertEqual(encodedTransaction.toHexString().addHexPrefix(), "0x71f907c6802b2b2a94000000000000000000000000000000000000800680b8a41415dae2000000000000000000000000000000000000000000000000000000000000000000379c09b5568d43b0ac6533a2672ee836815530b412f082f0b2e69915aa50fc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000082010e808082010e947e5f4552091a69125d5dfcb7b8c2659029395bdf80f906e3b906e00000002b04000041000000000141016f0000002c0400004100000000001403760000002d010000410000000000210376000000000130004c000000090000613d00a5000a0000034f00a5001f0000034f0000008001000039000000400200003900000000001203760000000001000357000000000110004c0000001d0000c13d0000002d010000410000000001010375000000000110004c000000180000c13d00000080010000390000000002000019000000000300001900a500960000034f0000002001000039000000000010037600000000000103760000002e01000041000000a6000103700000000001000019000000a70001037200010000000000020000008006000039000000400500003900000000006503760000002d010000410000000001010375000000040110008c0000005a0000413d0000002c01000041000000000101037500000000010103770000002f02000041000000000121016f000000300210009c000000440000c13d0000000001000357000000000110004c0000005c0000c13d0000002d010000410000000001010375000000040110008a000000010200008a0000003203000041000000000221004b00000000020000190000000002032019000000000131016f000000000431013f000000320110009c00000000010000190000000001034019000000320340009c000000000102c019000000000110004c0000005e0000c13d0000000001000019000000a700010372000000310110009c0000005a0000c13d0000000001000357000000000110004c000000650000c13d0000002d010000410000000001010375000000040110008a00000032020000410000001f0310008c00000000030000190000000003022019000000000121016f000000000410004c0000000002008019000000320110009c00000000010300190000000001026019000000000110004c000000670000c13d0000000001000019000000a7000103720000000001000019000000a7000103720000000001000019000000a7000103720000000001000019000100000006001d00a5008b0000034f000000010200002900000000001203760000003401000041000000a6000103700000000001000019000000a7000103720000002c01000041000000000101037500000004011000390000000001010377000100000005001d00a500720000034f000000010100002900000000010103750000003302000041000000000121016f000000a6000103700002000000000002000000010200008a000100000001001d000000000121013f000200000001001d000000000100001900a5008b0000034f0000000202000029000000000221004b000000820000213d00000001020000290000000001210019000000000200001900a500890000034f0000000200000005000000000001036f000000350100004100000000001003760000001101000039000000040200003900000000001203760000003601000041000000a700010372000000000012035b000000000001036f0000000001010359000000000001036f000000000401037500000000043401cf000000000434022f0000010003300089000000000232022f00000000023201cf000000000242019f0000000000210376000000000001036f0000000504300270000000000540004c0000009e0000613d00000000002103760000002001100039000000010440008a000000000540004c000000990000c13d0000001f0330018f000000000430004c000000a40000613d000000030330021000a5008d0000034f000000000001036f000000000001036f000000a500000374000000a600010370000000a700010372000000000000e001000000000000e001000000000000e001000000000000e0010000000000000000000000000000000000000000000000000000000000ffffff0000000000000000000000000000000000000000000000000000000000ffffe00000000000000000000000000000000000000000000000000000000000ffffc00000000000000000000000000000000000000000000000400000000000000000ffffffff000000000000000000000000000000000000000000000000000000006d4ce63c000000000000000000000000000000000000000000000000000000007cf5dab0000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffff00000000000000000000000000000000000000000000002000000000000000804e487b7100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024000000000000000080c0")
    }
    
    func deployTransaction(_ data: Data, bytecodeBytes: Data) -> EthereumTransaction {
        print("Data: \(data.toHexString().addHexPrefix())")
        print("Bytecode bytes: \(bytecodeBytes.toHexString().addHexPrefix())")
        
        XCTAssertEqual(data.toHexString().addHexPrefix(), "0x1415dae2000000000000000000000000000000000000000000000000000000000000000000379c09b5568d43b0ac6533a2672ee836815530b412f082f0b2e69915aa50fc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000")
        XCTAssertEqual(bytecodeBytes.toHexString().addHexPrefix(), "0x0000002b04000041000000000141016f0000002c0400004100000000001403760000002d010000410000000000210376000000000130004c000000090000613d00a5000a0000034f00a5001f0000034f0000008001000039000000400200003900000000001203760000000001000357000000000110004c0000001d0000c13d0000002d010000410000000001010375000000000110004c000000180000c13d00000080010000390000000002000019000000000300001900a500960000034f0000002001000039000000000010037600000000000103760000002e01000041000000a6000103700000000001000019000000a70001037200010000000000020000008006000039000000400500003900000000006503760000002d010000410000000001010375000000040110008c0000005a0000413d0000002c01000041000000000101037500000000010103770000002f02000041000000000121016f000000300210009c000000440000c13d0000000001000357000000000110004c0000005c0000c13d0000002d010000410000000001010375000000040110008a000000010200008a0000003203000041000000000221004b00000000020000190000000002032019000000000131016f000000000431013f000000320110009c00000000010000190000000001034019000000320340009c000000000102c019000000000110004c0000005e0000c13d0000000001000019000000a700010372000000310110009c0000005a0000c13d0000000001000357000000000110004c000000650000c13d0000002d010000410000000001010375000000040110008a00000032020000410000001f0310008c00000000030000190000000003022019000000000121016f000000000410004c0000000002008019000000320110009c00000000010300190000000001026019000000000110004c000000670000c13d0000000001000019000000a7000103720000000001000019000000a7000103720000000001000019000000a7000103720000000001000019000100000006001d00a5008b0000034f000000010200002900000000001203760000003401000041000000a6000103700000000001000019000000a7000103720000002c01000041000000000101037500000004011000390000000001010377000100000005001d00a500720000034f000000010100002900000000010103750000003302000041000000000121016f000000a6000103700002000000000002000000010200008a000100000001001d000000000121013f000200000001001d000000000100001900a5008b0000034f0000000202000029000000000221004b000000820000213d00000001020000290000000001210019000000000200001900a500890000034f0000000200000005000000000001036f000000350100004100000000001003760000001101000039000000040200003900000000001203760000003601000041000000a700010372000000000012035b000000000001036f0000000001010359000000000001036f000000000401037500000000043401cf000000000434022f0000010003300089000000000232022f00000000023201cf000000000242019f0000000000210376000000000001036f0000000504300270000000000540004c0000009e0000613d00000000002103760000002001100039000000010440008a000000000540004c000000990000c13d0000001f0330018f000000000430004c000000a40000613d000000030330021000a5008d0000034f000000000001036f000000000001036f000000a500000374000000a600010370000000a700010372000000000000e001000000000000e001000000000000e001000000000000e0010000000000000000000000000000000000000000000000000000000000ffffff0000000000000000000000000000000000000000000000000000000000ffffe00000000000000000000000000000000000000000000000000000000000ffffc00000000000000000000000000000000000000000000000400000000000000000ffffffff000000000000000000000000000000000000000000000000000000006d4ce63c000000000000000000000000000000000000000000000000000000007cf5dab0000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffff00000000000000000000000000000000000000000000002000000000000000804e487b71000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000240000000000000000")
        
        var transactionOptions = TransactionOptions.defaultOptions
        
        let type: TransactionType = .eip712
        transactionOptions.type = type
        
        let chainID = ZkTransactionEncoderTests.ChainId
        transactionOptions.chainID = chainID
        let nonce = BigUInt.zero
        transactionOptions.nonce = .manual(nonce)
        transactionOptions.gasLimit = .manual(ZkTransactionEncoderTests.GasLimit)
        let to = EthereumAddress(ZkSyncAddresses.ContractDeployerAddress)!
        transactionOptions.to = to
        
        let value = BigUInt.zero
        transactionOptions.value = value
        transactionOptions.maxPriorityFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
        transactionOptions.maxFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
        transactionOptions.from = credentials.ethereumAddress
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.ergsPerPubdata = BigUInt.zero
        EIP712Meta.customSignature = Data()
        EIP712Meta.factoryDeps = [bytecodeBytes]
        EIP712Meta.paymasterParams = nil
        ethereumParameters.EIP712Meta = EIP712Meta
        
        ethereumParameters.from = credentials.ethereumAddress
        
        let ethereumTransaction = EthereumTransaction(type: type,
                                                      to: to,
                                                      nonce: nonce,
                                                      chainID: chainID,
                                                      value: value,
                                                      data: data,
                                                      parameters: ethereumParameters)
        
        return ethereumTransaction
    }
    
    func testEncodeExecute() {
        let encodedFunction = CounterContract.encodeIncrement(BigUInt(42))
        XCTAssertEqual(encodedFunction.toHexString().addHexPrefix(), "0x7cf5dab0000000000000000000000000000000000000000000000000000000000000002a")
        
        let transaction = executeTransaction(encodedFunction)
        
        guard let encodedTransaction = transaction.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }
        
        print("Encoded transaction: \(encodedTransaction.toHexString().addHexPrefix())")
        
        XCTAssertEqual(encodedTransaction.toHexString().addHexPrefix(), "0x71f860802b2b2a94e1fab3efd74a77c23b426c302d96372140ff7d0c80a47cf5dab0000000000000000000000000000000000000000000000000000000000000002a82010e808082010e947e5f4552091a69125d5dfcb7b8c2659029395bdf80c080c0")
    }
    
    func executeTransaction(_ data: Data) -> EthereumTransaction {
        var transactionOptions = TransactionOptions.defaultOptions
        
        let type: TransactionType = .eip712
        transactionOptions.type = type
        
        let chainID = ZkTransactionEncoderTests.ChainId
        transactionOptions.chainID = chainID
        let nonce = BigUInt.zero
        transactionOptions.nonce = .manual(nonce)
        transactionOptions.gasLimit = .manual(ZkTransactionEncoderTests.GasLimit)
        let to = EthereumAddress("0xe1fab3efd74a77c23b426c302d96372140ff7d0c")!
        transactionOptions.to = to
        
        let value = BigUInt.zero
        transactionOptions.value = value
        transactionOptions.maxPriorityFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
        transactionOptions.maxFeePerGas = .manual(ZkTransactionEncoderTests.GasPrice)
        transactionOptions.from = credentials.ethereumAddress
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.ergsPerPubdata = BigUInt.zero
        EIP712Meta.customSignature = Data()
        EIP712Meta.factoryDeps = nil
        EIP712Meta.paymasterParams = nil
        ethereumParameters.EIP712Meta = EIP712Meta
        
        ethereumParameters.from = credentials.ethereumAddress
        
        let ethereumTransaction = EthereumTransaction(type: type,
                                                      to: to,
                                                      nonce: nonce,
                                                      chainID: chainID,
                                                      value: value,
                                                      data: data,
                                                      parameters: ethereumParameters)
        
        return ethereumTransaction
    }
}
