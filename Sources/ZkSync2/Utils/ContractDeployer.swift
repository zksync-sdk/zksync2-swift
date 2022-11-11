//
//  ContractDeployer.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/8/22.
//

import Foundation
import web3swift
import BigInt

class ContractDeployer {
    
    static let MaxBytecodeSize = BigUInt.two.power(16)
    
    static func computeL2CreateAddress(_ sender: EthereumAddress, nonce: BigUInt) -> EthereumAddress {
        fatalError("Implement")
    }
    
    static func encodeCreate2(_ bytecode: Data, calldata: Data = Data()) -> Data {
        let inputs = [
            ABI.Element.InOut(name: "salt", type: .bytes(length: 32)),
            ABI.Element.InOut(name: "bytecodeHash", type: .bytes(length: 32)),
            ABI.Element.InOut(name: "", type: .uint(bits: 256)),
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
        
        // assert(bytecodeHash.toHexString().addHexPrefix() == "0x00379c09b5568d43b0ac6533a2672ee836815530b412f082f0b2e69915aa50fc")
        
        let parameters: [AnyObject] = [
            salt as AnyObject,
            bytecodeHash as AnyObject,
            0 as AnyObject,
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
    
    static func hashBytecode(_ bytecode: Data) -> Data {
        var bytecodeHash = Web3.Utils.sha256(bytecode)
        
        let length = BigUInt(bytecode.count / 32)
        if length > ContractDeployer.MaxBytecodeSize {
            fatalError("Bytecode length must be less than 2^16 bytes")
        }
        
        let bytecodeLength = length.data2
        
        bytecodeHash?.replaceSubrange(0...1, with: bytecodeLength)
        
        guard let bytecodeHash = bytecodeHash else {
            fatalError("Bytecode hash should be valid.")
        }
        
        return bytecodeHash
    }
}
