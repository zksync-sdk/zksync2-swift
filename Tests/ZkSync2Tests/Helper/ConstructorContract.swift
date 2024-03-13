//
//  ConstructorContract.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/14/22.
//

import Foundation
import web3swift
import Web3Core
import BigInt

class ConstructorContract {
    
    static func encodeConstructor(a: BigUInt, b: BigUInt, shouldRevert: Bool) -> Data {
        let inputs = [
            ABI.Element.InOut(name: "a", type: .uint(bits: 256)),
            ABI.Element.InOut(name: "b", type: .uint(bits: 256)),
            ABI.Element.InOut(name: "shouldRevert", type: .bool)
        ]
        
        let constructor = ABI.Element.Constructor(inputs: inputs,
                                                  constant: false,
                                                  payable: false)
        
        let elementConstructor: ABI.Element = .constructor(constructor)
        
        let parameters: [AnyObject] = [
            a as AnyObject,
            b as AnyObject,
            shouldRevert as AnyObject
        ]
        
        guard let encodedConstructor = elementConstructor.encodeParameters(parameters) else {
            fatalError("Failed to encode function.")
        }
        
#if DEBUG
        print("encodedConstructor: \(encodedConstructor.toHexString().addHexPrefix())")
#endif
        
        return encodedConstructor
    }
}
