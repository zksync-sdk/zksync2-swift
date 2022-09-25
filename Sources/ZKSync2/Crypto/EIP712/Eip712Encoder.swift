//
//  Eip712Encoder.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 8/16/22.
//

import Foundation
import BigInt
import web3swift
import CryptoSwift

// ZKSync2 (Java): Eip712Encoder.java
class EIP712Encoder {
    
    static func encodeValue(_ value: Any) -> Data {
        if let stringValue = value as? String {
            return EIP712.keccak256(stringValue)
        } else if let numericValue = value as? any Numeric {
            guard let numericValueData = numericValue.data.setLengthLeft(32) else {
                fatalError("Unable to encode Numeric value.")
            }
            
            return numericValueData
        } else if let ethereumAddressValue = value as? EthereumAddress {
            guard let paddedEthereumAddressValue = ethereumAddressValue.addressData.setLengthLeft(32) else {
                fatalError("Unable to EthereumAddress value.")
            }
            
            return paddedEthereumAddressValue
        } else if let EIP712HashableValue = value as? EIP712Hashable {
            guard let valueHash = try? EIP712HashableValue.hash() else {
                fatalError("Unable to encode EIP712Hashable value.")
            }
            
            return valueHash
        }
        
        fatalError("Unsupported type.")
    }
    
    static func typedDataToSignedBytes(_ domain: EIP712Domain, typedData: Structurable) -> Data {
        var outputData = Data()
        let messageEIP712Prefix = "\u{19}\u{01}"
        outputData.append(messageEIP712Prefix.data(using: .ascii)!)
        outputData.append(EIP712Encoder.encodeValue(domain))
        outputData.append(EIP712Encoder.encodeValue(typedData))
        
        return Data(SHA3(variant: .keccak256).calculate(for: outputData.bytes))
    }
}
