//
//  Eip712Encoder.swift
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
import web3swift_zksync
#endif

class EIP712Encoder {
    
    static func encodeValue(_ value: Any) -> Data {
        if let stringValue = value as? String {
            return EIP712.keccak256(stringValue)
        } else if let numericValue = value as? any Numeric {
            let numericValueData = numericValue.data.setLengthLeft(32)
            
            return numericValueData
        } else if let ethereumAddressValue = value as? EthereumAddress {
            let paddedEthereumAddressValue = ethereumAddressValue.addressData.setLengthLeft(32)
            
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
        
        let data = Data(SHA3(variant: .keccak256).calculate(for: outputData.bytes))
        
        return data
    }
}
