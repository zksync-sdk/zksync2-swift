//
//  Structurable.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 8/16/22.
//

import Foundation
import BigInt
import CryptoSwift
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

public protocol Structurable: EIP712Hashable {
    
}

public protocol EIP712Hashable {
    
    var typehash: Data { get }
    
    func hash() throws -> Data
    
    func getTypeName() -> String
    
    func eip712types() -> [EIP712.`Type`]
}

public class EIP712 {
    
    public typealias `Type` = (label: String, value: Any)
    public typealias Address = EthereumAddress
    public typealias UInt256 = BigUInt
    public typealias UInt = Swift.UInt
    public typealias UInt8 = Swift.UInt8
    public typealias Bytes = Data
    public typealias Bytes32Array = [Data]
    
    public static func keccak256(_ data: [UInt8]) -> Data {
        Data(SHA3(variant: .keccak256).calculate(for: data))
    }
    
    public static func keccak256(_ string: String) -> Data {
        keccak256(Array(string.utf8))
    }
    
    public static func keccak256(_ data: Data) -> Data {
        keccak256(data.bytes)
    }
}

public extension EIP712Hashable {
    
    func dependencies() -> [EIP712Hashable] {
        let dependencies = eip712types()
            .compactMap { $0.value as? EIP712Hashable }
            .flatMap { [$0] + $0.dependencies() }
        
        return dependencies
    }
    
    func encodePrimaryType() -> String {
        let parameters: [String] = eip712types().compactMap { key, value in
            
            func checkIfValueIsNil(value: Any) -> Bool {
                let mirror = Mirror(reflecting: value)
                if mirror.displayStyle == .optional {
                    if mirror.children.count == 0 {
                        return true
                    }
                }
                
                return false
            }
            
            guard !checkIfValueIsNil(value: value) else {
                fatalError("Value cannot be nil.")
            }
            
            let typeName: String
            switch value {
            case is EIP712.UInt8:
                typeName = "uint8"
            case is EIP712.UInt256:
                typeName = "uint256"
            case is EIP712.Address:
                typeName = "address"
            case is EIP712.Bytes:
                typeName = "bytes"
            case is EIP712.Bytes32Array:
                typeName = "bytes32[]"
            case let hashable as EIP712Hashable:
                typeName = hashable.getTypeName()
            default:
                typeName = "\(type(of: value))".lowercased()
            }
            
            return typeName + " " + key
        }
        
        return getTypeName() + "(" + parameters.joined(separator: ",") + ")"
    }
    
    func encodeType() -> String {
        let dependencies = self.dependencies().map { $0.encodePrimaryType() }
        let selfPrimaryType = self.encodePrimaryType()
        
        let result = Set(dependencies).filter { $0 != selfPrimaryType }
        return selfPrimaryType + result.sorted().joined()
    }
    
    var typehash: Data {
        EIP712.keccak256(encodeType())
    }
    
    func hash() throws -> Data {
        var parameters: [Data] = [self.typehash]
        for case let (_, field) in eip712types() {
            let result: Data
            
            switch field {
            case let string as String:
                result = EIP712.keccak256(string)
            case let data as EIP712.Bytes:
                result = EIP712.keccak256(data)
            case let data as EIP712.Bytes32Array:
                result = EIP712.keccak256(self.factoryDepsHashes(data: data))
            case is EIP712.UInt8:
                result = ABIEncoder.encodeSingleType(type: .uint(bits: 8), value: field as AnyObject)!
            case is EIP712.UInt256:
                result = ABIEncoder.encodeSingleType(type: .uint(bits: 256), value: field as AnyObject)!
            case is EIP712.Address:
                result = ABIEncoder.encodeSingleType(type: .address, value: field as AnyObject)!
            case let hashable as EIP712Hashable:
                result = try hashable.hash()
            default:
                if (field as AnyObject) is NSNull {
                    continue
                } else {
                    preconditionFailure("Not solidity type")
                }
            }
            
            guard result.count == 32 else {
                preconditionFailure("ABI encode error")
            }
            
            parameters.append(result)
        }
        
        let encoded = parameters.flatMap { $0.bytes }
        return EIP712.keccak256(encoded)
    }
    
    internal func factoryDepsHashes(data: EIP712.Bytes32Array) -> Data {
        let factoryDepsHashes = data.map({ ContractDeployer.hashBytecode($0) })
        
        var allData = Data()
        factoryDepsHashes.forEach {
            guard $0.count == 32 else {
                preconditionFailure("ABI encode error")
            }
            
            allData.append($0)
        }
        
        return allData
    }
}
