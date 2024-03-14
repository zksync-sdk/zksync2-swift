//
//  Paymaster.swift
//  Maxim Makhun
//
//  Created by Maxim Makhun on 10/15/22.
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

public class Paymaster {
    public static let ApprovalBasedFunction = "approvalBased"
    public static let GeneralFunction = "general"
    
    public static func encodeApprovalBased(_ tokenAddress: EthereumAddress, minimalAllowance: BigUInt, paymasterInput: Data) -> Data {
        let inputs = [
            ABI.Element.InOut(name: "_token", type: .address),
            ABI.Element.InOut(name: "_minAllowance", type: .uint(bits: 256)),
            ABI.Element.InOut(name: "_innerInput", type: .dynamicBytes),
        ]
        
        let function = ABI.Element.Function(
            name: Paymaster.ApprovalBasedFunction,
            inputs: inputs,
            outputs: [],
            constant: false,
            payable: false
        )
        
        let elementFunction: ABI.Element = .function(function)
        
        let parameters: [AnyObject] = [
            tokenAddress as AnyObject,
            minimalAllowance as AnyObject,
            paymasterInput as AnyObject
        ]
        
        guard let encodedFunction = elementFunction.encodeParameters(parameters) else {
            fatalError("Failed to encode function.")
        }
        
        return encodedFunction
    }
    
    public static func encodeGeneral(_ paymasterInput: Data) -> Data {
        let inputs = [
            ABI.Element.InOut(name: "input", type: .dynamicBytes),
        ]
        
        let function = ABI.Element.Function(
            name: Paymaster.GeneralFunction,
            inputs: inputs,
            outputs: [],
            constant: false,
            payable: false
        )
        
        let elementFunction: ABI.Element = .function(function)
        
        let parameters: [AnyObject] = [
            paymasterInput as AnyObject
        ]
        
        guard let encodedFunction = elementFunction.encodeParameters(parameters) else {
            fatalError("Failed to encode function.")
        }
        
        return encodedFunction
    }
}
