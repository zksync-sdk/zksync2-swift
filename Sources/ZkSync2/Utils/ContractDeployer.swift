//
//  ContractDeployer.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/8/22.
//

import Foundation
import web3swift
import BigInt

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
    
    public static func encodeCreate2(_ bytecode: Data, calldata: Data = Data()) -> Data {
        let inputs = [
            ABI.Element.InOut(name: "salt", type: .bytes(length: 32)),
            ABI.Element.InOut(name: "bytecodeHash", type: .bytes(length: 32)),
            ABI.Element.InOut(name: "calldata", type: .dynamicBytes)
        ]
        
        let function = ABI.Element.Function(name: "create2",
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
        print("salt: \(salt.toHexString().addHexPrefix())")
        print("bytecode: \(bytecode.toHexString().addHexPrefix())")
        print("bytecodeHash: \(bytecodeHash.toHexString().addHexPrefix())")
        print("calldata: \(calldata.toHexString().addHexPrefix())")
        print("encodedCallData: \(encodedCallData.toHexString().addHexPrefix())")
#endif
        
        return encodedCallData
    }
    
    public static func hashBytecode(_ bytecode: Data) -> Data {
        var bytecodeHash = Web3.Utils.sha256(bytecode)
        
        if bytecode.count % 32 != 0 {
            fatalError("Bytecode length in bytes must be divisible by 32")
        }
        
        let length = BigUInt(bytecode.count / 32)
        if length > ContractDeployer.MaxBytecodeSize {
            fatalError("Bytecode length must be less than 2^16 bytes")
        }
        
        let codeHashVersion = Data(fromHex: "0x0100")!
        let bytecodeLength = length.data2
        
        bytecodeHash?.replaceSubrange(0...3, with: Data(codeHashVersion + bytecodeLength))
        
        guard let bytecodeHash = bytecodeHash else {
            fatalError("Bytecode hash should be valid.")
        }
        
        return bytecodeHash
    }
}
