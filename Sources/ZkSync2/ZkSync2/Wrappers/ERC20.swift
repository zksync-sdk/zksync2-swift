//
//  ERC20.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 11/23/22.
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync
#endif

class ZkERC20 {
    
    static func encodeTransfer(_ to: EthereumAddress,
                               value: BigUInt) -> Data {
        let inputs = [
            ABI.Element.InOut(name: "_to", type: .address),
            ABI.Element.InOut(name: "_value", type: .uint(bits: 256))
        ]
        
        let function = ABI.Element.Function(name: "transfer",
                                            inputs: inputs,
                                            outputs: [],
                                            constant: false,
                                            payable: false)
        
        let elementFunction: ABI.Element = .function(function)
        
        let parameters: [AnyObject] = [
            to as AnyObject,
            value as AnyObject
        ]
        
        guard let encodedFunction = elementFunction.encodeParameters(parameters) else {
            fatalError("Failed to encode function.")
        }
        
        return encodedFunction
    }
}
