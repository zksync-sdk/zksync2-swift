//
//  EthereumKeystoreV3.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 9/29/22.
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

public typealias Credentials = EthereumKeystoreV3

public extension EthereumKeystoreV3 {
    
    var ethereumAddress: EthereumAddress {
        guard let address = addresses?.first else {
            fatalError("Address should be valid.")
        }
        
        return address
    }
    
    var address: String {
        return ethereumAddress.address
    }
    
    var privateKey: Data {
        guard let privateKey = try? UNSAFE_getPrivateKeyData(password: "web3swift", account: ethereumAddress) else {
            fatalError("Private key was not found")
        }
        return privateKey
    }
    
    convenience init(_ privateKey: Data) {
        try! self.init(privateKey: privateKey, password: "web3swift")!
    }
    
    convenience init(_ privateKey: String) {
        let privatKeyData = Data(hex: privateKey)
        
        try! self.init(privateKey: privatKeyData, password: "web3swift")!
    }
    
    convenience init(_ privateKey: BigUInt) {
        self.init(privateKey.data32)
    }
}
