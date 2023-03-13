//
//  ContractUtils.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/1/22.
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

class ContractUtils {
    
    static func generateContractAddress(address: String, nonce: BigUInt) -> Data {
        let fields: [AnyObject] = [
            address,
            nonce
        ] as [AnyObject]
        
        let encoded = RLP.encode(fields)!
        let hashed = encoded.sha3(.keccak256)
        
        return hashed.subdata(in: 12..<hashed.count)
    }
}
