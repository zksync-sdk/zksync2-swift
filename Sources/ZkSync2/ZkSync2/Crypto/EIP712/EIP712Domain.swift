//
//  Eip712Domain.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 8/14/22.
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync
#endif

public class EIP712Domain: Structurable {
    
    static let name = "zkSync"
    
    static let version = "2"
    
    let name: String
    
    let version: String
    
    public let chainId: EIP712.UInt256
    
    var verifyingContract: EIP712.Address? = nil
    
    init(_ chainId: ZkSyncNetwork) {
        self.name = EIP712Domain.name
        self.version = EIP712Domain.version
        self.chainId = EIP712.UInt256(chainId.rawValue)
    }
    
    init(_ chainId: EIP712.UInt256) {
        self.name = EIP712Domain.name
        self.version = EIP712Domain.version
        self.chainId = chainId
    }
    
    init(_ name: String, version: String, chainId: EIP712.UInt256) {
        self.name = name
        self.version = version
        self.chainId = chainId
    }
    
    init(_ name: String, version: String, chainId: ZkSyncNetwork, address: String) {
        self.name = name
        self.version = version
        self.chainId = EIP712.UInt256(chainId.rawValue)
        
        guard let ethereumAddress = EthereumAddress(address) else {
            fatalError("Invalid address.")
        }
        
        self.verifyingContract = ethereumAddress
    }
    
    init(_ name: String, version: String, chainId: EIP712.UInt256, address: String) {
        self.name = name
        self.version = version
        self.chainId = chainId
        
        guard let ethereumAddress = EthereumAddress(address) else {
            fatalError("Invalid address.")
        }
        
        self.verifyingContract = ethereumAddress
    }
    
    public func getTypeName() -> String {
        return "EIP712Domain"
    }
    
    public func eip712types() -> [EIP712.`Type`] {
        var eip712types: [EIP712.`Type`] = [
            ("name", value: name),
            ("version", value: version),
            ("chainId", value: chainId)
        ]
        
        if let verifyingContract = verifyingContract {
            eip712types.append(("verifyingContract", value: verifyingContract))
        }
        
        return eip712types
    }
}
