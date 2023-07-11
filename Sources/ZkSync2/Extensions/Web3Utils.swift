//
//  Web3Util.swift
//  zkSync-Demo
//
//  Created by Bojan on 11.7.23..
//

import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

public extension Web3.Utils {
    /// Hashes a personal message by first padding it with the "\u{19}Ethereum Signed Message:\n" string and message length string.
    /// Should be used if some arbitrary information should be hashed and signed to prevent signing an Ethereum transaction
    /// by accident.
    static func hashPersonalMessage(_ personalMessage: Data) -> Data? {
        var prefix = "\u{19}Ethereum Signed Message:\n"
        prefix += String(personalMessage.count)
        guard let prefixData = prefix.data(using: .ascii) else {return nil}
        var data = Data()
        if personalMessage.count >= prefixData.count && prefixData == personalMessage[0 ..< prefixData.count] {
            data.append(personalMessage)
        } else {
            data.append(prefixData)
            data.append(personalMessage)
        }
        let hash = data.sha3(.keccak256)
        return hash
    }
    
    /// Recover the Ethereum address from recoverable secp256k1 signature.
    /// Takes a hash of some message. What message is hashed should be checked by user separately.
    ///
    /// Input parameters should be Data objects.
    static func hashECRecover(hash: Data, signature: Data) -> EthereumAddress? {
        if signature.count != 65 { return nil}
        let rData = signature[0..<32].bytes
        let sData = signature[32..<64].bytes
        var vData = signature[64]
        if vData >= 27 && vData <= 30 {
            vData -= 27
        } else if vData >= 31 && vData <= 34 {
            vData -= 31
        } else if vData >= 35 && vData <= 38 {
            vData -= 35
        }
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else {return nil}
        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else {return nil}
        return Web3.Utils.publicToAddress(publicKey)
    }
    
    /// Convert a public key to the corresponding EthereumAddress. Accepts public keys in compressed (33 bytes), non-compressed (65 bytes)
    /// or raw concat(X, Y) (64 bytes) format.
    ///
    /// Returns the EthereumAddress object.
    static func publicToAddress(_ publicKey: Data) -> EthereumAddress? {
        guard let addressData = Web3.Utils.publicToAddressData(publicKey) else {return nil}
        let address = addressData.toHexString().addHexPrefix().lowercased()
        return EthereumAddress(address)
    }
    
    /// Convert a public key to the corresponding EthereumAddress. Accepts public keys in compressed (33 bytes), non-compressed (65 bytes)
    /// or raw concat(X, Y) (64 bytes) format.
    ///
    /// Returns 20 bytes of address data.
    static func publicToAddressData(_ publicKey: Data) -> Data? {
        if publicKey.count == 33 {
            guard let decompressedKey = SECP256K1.combineSerializedPublicKeys(keys: [publicKey], outputCompressed: false) else {return nil}
            return publicToAddressData(decompressedKey)
        }
        var stipped = publicKey
        if (stipped.count == 65) {
            if (stipped[0] != 4) {
                return nil
            }
            stipped = stipped[1...64]
        }
        if (stipped.count != 64) {
            return nil
        }
        let sha3 = stipped.sha3(.keccak256)
        let addressData = sha3[12...31]
        return addressData
    }
}
