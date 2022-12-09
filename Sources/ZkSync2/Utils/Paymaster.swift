//
//  Paymaster.swift
//  Maxim Makhun
//
//  Created by Maxim Makhun on 10/15/22.
//

import Foundation
import web3swift
import BigInt

class Paymaster {
    
    static let GeneralFunction = "general"
    static let ApprovalBasedFunction = "approvalBased"
    
    static func encodeApprovalBased(_ tokenAddress: EthereumAddress,
                                    minimalAllowance: BigUInt,
                                    input: Data) -> Data {
        let inputs = [
            ABI.Element.InOut(name: "tokenAddress", type: .address),
            ABI.Element.InOut(name: "minimalAllowance", type: .uint(bits: 256)),
            ABI.Element.InOut(name: "input", type: .bytes(length: 32)),
        ]
        
        let function = ABI.Element.Function(name: Paymaster.ApprovalBasedFunction,
                                            inputs: inputs,
                                            outputs: [],
                                            constant: false,
                                            payable: false)
        
        let elementFunction: ABI.Element = .function(function)
        
        let parameters: [AnyObject] = [
            tokenAddress as AnyObject,
            minimalAllowance as AnyObject,
            input as AnyObject
        ]
        
        guard let encodedFunction = elementFunction.encodeParameters(parameters) else {
            fatalError("Failed to encode function.")
        }
        
        return encodedFunction
    }
}
