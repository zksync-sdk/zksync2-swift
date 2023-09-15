//
//  ContractDeployer.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/8/22.
//

import Foundation
import CryptoKit
import BigInt
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }
    
    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}

public class ContractDeployer {
    
    static let CreatePrefix = "zksyncCreate".data(using: .ascii)!.sha3(.keccak256)
    static let Create2Prefix = "zksyncCreate2".data(using: .ascii)!.sha3(.keccak256)
    static let MaxBytecodeSize = BigUInt.two.power(16)
    
    public static func computeL2Create2Address(_ sender: EthereumAddress, bytecode: Data, constructor: Data, salt: Data) -> EthereumAddress {
        let senderBytes = sender.addressData.setLengthLeft(32)
        let bytecodeHash = hashBytecode(bytecode)
        let constructorHash = constructor.sha3(.keccak256)
        
        var output = Data()
        output.append(ContractDeployer.Create2Prefix)
        output.append(senderBytes)
        output.append(salt.setLengthLeft(32))
        output.append(bytecodeHash)
        output.append(constructorHash)
        
        let result = output.sha3(.keccak256)
        
        return EthereumAddress(result.subdata(in: 12..<result.count).toHexString().addHexPrefix())!
    }
    
    public static func computeL2CreateAddress(_ sender: EthereumAddress, nonce: BigUInt) -> EthereumAddress {
        let senderBytes = sender.addressData.setLengthLeft(32)
        let nonceBytes = nonce.data32
        
        var output = Data()
        output.append(ContractDeployer.CreatePrefix)
        output.append(senderBytes)
        output.append(nonceBytes)
        
        let result = output.sha3(.keccak256)
        
        return EthereumAddress(result.subdata(in: 12..<result.count).toHexString().addHexPrefix())!
    }
    
    public static func encodeCreate(_ bytecode: Data, calldata: Data = Data()) -> Data {
        let inputs = [
            ABI.Element.InOut(name: "salt", type: .bytes(length: 32)),
            ABI.Element.InOut(name: "bytecodeHash", type: .bytes(length: 32)),
            ABI.Element.InOut(name: "calldata", type: .dynamicBytes)
        ]
        
        let function = ABI.Element.Function(name: "create",
                                            inputs: inputs,
                                            outputs: [],
                                            constant: false,
                                            payable: false)
        
        let elementFunction: ABI.Element = .function(function)
        
        let salt = Data(capacity: 32)
        
        let bytecodeHash = ContractDeployer.hashBytecode(bytecode)
        
        let parameters: [AnyObject] = [
            salt as AnyObject,
            bytecodeHash as AnyObject,
            calldata as AnyObject
        ]
        
        guard let encodedCallData = elementFunction.encodeParameters(parameters) else {
            fatalError("Failed to encode function.")
        }
        
#if DEBUG
        print("bytecode: \(bytecode.toHexString().addHexPrefix())")
        print("bytecodeHash: \(bytecodeHash.toHexString().addHexPrefix())")
        print("calldata: \(calldata.toHexString().addHexPrefix())")
        print("encodedCallData: \(encodedCallData.toHexString().addHexPrefix())")
#endif
        
        return encodedCallData
    }
    
    public static func encodeCreate2(_ bytecode: Data, calldata: Data = Data(), salt: Data = Data(capacity: 32)) -> Data {
        let inputs = [
            ABI.Element.InOut(name: "salt", type: .bytes(length: 32)),
            ABI.Element.InOut(name: "bytecodeHash", type: .bytes(length: 32)),
            ABI.Element.InOut(name: "input", type: .dynamicBytes)//calldata
        ]
        
        let function = ABI.Element.Function(name: "create2",
                                            inputs: inputs,
                                            outputs: [],
                                            constant: false,
                                            payable: false)
        
        let elementFunction: ABI.Element = .function(function)
        
        let bytecodeHash = ContractDeployer.hashBytecode(bytecode)
        
        let parameters: [AnyObject] = [
            salt as AnyObject,
            bytecodeHash as AnyObject,
            calldata as AnyObject
        ]
        
        guard let encodedCallData = elementFunction.encodeParameters(parameters) else {
            fatalError("Failed to encode function.")
        }
        
#if DEBUG
        print("salt: \(salt.toHexString().addHexPrefix())")
        print("bytecode: \(bytecode.toHexString().addHexPrefix())")
        print("bytecodeHash: \(bytecodeHash.toHexString().addHexPrefix())")
        print("calldata: \(calldata.toHexString().addHexPrefix())")
        print("encodedCallData: \(encodedCallData.toHexString().addHexPrefix())")
#endif
        
        return encodedCallData
    }
    
    public static func encodeCreateAccount(_ bytecode: Data, calldata: Data = Data(), version: AccountAbstractionVersion) -> Data {
        let inputs = [
            ABI.Element.InOut(name: "", type: .bytes(length: 32)),
            ABI.Element.InOut(name: "bytecodeHash", type: .bytes(length: 32)),
            ABI.Element.InOut(name: "input", type: .dynamicBytes),
            ABI.Element.InOut(name: "aaVersion", type: .uint(bits: 8))
        ]
        
        let function = ABI.Element.Function(name: "createAccount",
                                            inputs: inputs,
                                            outputs: [],
                                            constant: false,
                                            payable: false)
        
        let elementFunction: ABI.Element = .function(function)
        
        let salt = Data(capacity: 32)
        
        let bytecodeHash = ContractDeployer.hashBytecode(bytecode)
        
        let parameters: [AnyObject] = [
            salt as AnyObject,
            bytecodeHash as AnyObject,
            calldata as AnyObject,
            version.rawValue as AnyObject,
        ]
        
        guard let encodedCallData = elementFunction.encodeParameters(parameters) else {
            fatalError("Failed to encode function.")
        }
        
#if DEBUG
        print("bytecode: \(bytecode.toHexString().addHexPrefix())")
        print("bytecodeHash: \(bytecodeHash.toHexString().addHexPrefix())")
        print("calldata: \(calldata.toHexString().addHexPrefix())")
        print("version: \(version)")
        print("encodedCallData: \(encodedCallData.toHexString().addHexPrefix())")
#endif
        
        return encodedCallData
    }
    
    public static func encodeCreate2Account(_ bytecode: Data, calldata: Data = Data(), salt: Data, version: AccountAbstractionVersion) -> Data {
        let inputs = [
            ABI.Element.InOut(name: "salt", type: .bytes(length: 32)),
            ABI.Element.InOut(name: "bytecodeHash", type: .bytes(length: 32)),
            ABI.Element.InOut(name: "input", type: .dynamicBytes),
            ABI.Element.InOut(name: "aaVersion", type: .uint(bits: 8))
        ]
        
        let function = ABI.Element.Function(name: "create2Account",
                                            inputs: inputs,
                                            outputs: [],
                                            constant: false,
                                            payable: false)
        
        let elementFunction: ABI.Element = .function(function)
        
        var salt = salt
        if salt.isEmpty {
            salt = Data(capacity: 32)
        }
        
        let bytecodeHash = ContractDeployer.hashBytecode(bytecode)
        
        let parameters: [AnyObject] = [
            salt as AnyObject,
            bytecodeHash as AnyObject,
            calldata as AnyObject,
            version.rawValue as AnyObject,
        ]
        
        guard let encodedCallData = elementFunction.encodeParameters(parameters) else {
            fatalError("Failed to encode function.")
        }
        
#if DEBUG
        print("bytecode: \(bytecode.toHexString().addHexPrefix())")
        print("bytecodeHash: \(bytecodeHash.toHexString().addHexPrefix())")
        print("calldata: \(calldata.toHexString().addHexPrefix())")
        print("salt: \(salt.toHexString().addHexPrefix())")
        print("version: \(version)")
        print("encodedCallData: \(encodedCallData.toHexString().addHexPrefix())")
#endif
        
        return encodedCallData
    }
    
    public static func hashBytecode(_ bytecode: Data) -> Data {
        return bytecode//444
//444        var bytecodeHash = Web3.Utils.sha256(bytecode)
//
//        let function = ABI.Element.Function(name: "createAccount",
//                                            inputs: inputs,
//                                            outputs: [],
//                                            constant: false,
//                                            payable: false)
//
//        let elementFunction: ABI.Element = .function(function)
//
//        let salt = Data(capacity: 32)
//
//        let bytecodeHash = ContractDeployer.hashBytecode(bytecode)
//
//        let parameters: [AnyObject] = [
//            salt as AnyObject,
//            bytecodeHash as AnyObject,
//            calldata as AnyObject,
//            version.rawValue as AnyObject,
//        ]
//
//        guard let encodedCallData = elementFunction.encodeParameters(parameters) else {
//            fatalError("Failed to encode function.")
//        }
//
//#if DEBUG
//        print("bytecode: \(bytecode.toHexString().addHexPrefix())")
//        print("bytecodeHash: \(bytecodeHash.toHexString().addHexPrefix())")
//        print("calldata: \(calldata.toHexString().addHexPrefix())")
//        print("version: \(version)")
//        print("encodedCallData: \(encodedCallData.toHexString().addHexPrefix())")
//#endif
//
//        return encodedCallData
    }
}
