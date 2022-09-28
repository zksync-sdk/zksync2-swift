//
//  PrivateKeyEthSigner.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/23/22.
//

import Foundation
import BigInt
import web3swift

// ZkSync2 (Java): PrivateKeyEthSigner.java
class PrivateKeyEthSigner: EthSigner {
    
    var address: String {
        return ethereumAddress.address.lowercased()
    }
    
    var domain: EIP712Domain
    
    let keystore: EthereumKeystoreV3
    
    var ethereumAddress: EthereumAddress {
        return keystore.addresses!.first!
    }
    
    init(_ privateKey: String, chainId: BigUInt) {
        let privatKeyData = Data(hex: privateKey)
        guard let keystore = try? EthereumKeystoreV3(privateKey: privatKeyData) else {
            preconditionFailure("Keystore is not valid.")
        }
        
        self.keystore = keystore
        domain = EIP712Domain(chainId)
    }
    
    func signTypedData<S>(_ domain: EIP712Domain,
                          typedData: S) -> String where S : Structurable {
        return signMessage(EIP712Encoder.typedDataToSignedBytes(domain, typedData: typedData),
                           addPrefix: false)
    }
    
    func verifyTypedData<S>(_ domain: EIP712Domain,
                            typedData: S,
                            signature: String) -> Bool where S : Structurable {
        return verifySignature(signature,
                               message: EIP712Encoder.typedDataToSignedBytes(domain, typedData: typedData),
                               prefixed: false)
    }
    
    func signMessage(_ message: Data) -> String {
        return signMessage(message, addPrefix: true)
    }
    
    // TODO: Implement signing with no prefix.
    func signMessage(_ message: Data, addPrefix: Bool) -> String {
        let messageToSign: Data
        let needToHash: Bool
        if addPrefix {
            let prefix = "\u{19}Ethereum Signed Message:\n" + String(message.count)
            let data = prefix.data(using: .ascii)! + message
            
            messageToSign = data
            needToHash = true
        } else {
            messageToSign = message
            needToHash = false
        }
        
        guard let signatureData = try? signMessage(messageToSign,
                                                   keystore: keystore,
                                                   account: ethereumAddress,
                                                   needToHash: needToHash) else {
            preconditionFailure("Failed to sign.")
        }
        
        return signatureData.toHexString().addHexPrefix()
    }
    
    func verifySignature(_ signature: String,
                         message: Data) -> Bool {
        return verifySignature(signature,
                               message: message,
                               prefixed: true)
    }
    
    // TODO: Implement verification with no prefix.
    func verifySignature(_ signature: String,
                         message: Data,
                         prefixed: Bool) -> Bool {
        let messageHash: Data
        if prefixed {
            guard let personalMessageHash = Web3.Utils.hashPersonalMessage(message) else {
                fatalError("Unable to hash message.")
            }
            
            messageHash = personalMessageHash
        } else {
            messageHash = message
        }
        
        guard let signatureData = Data.fromHex(signature) else {
            fatalError("Invalid signature.")
        }
        
        let address = Web3.Utils.hashECRecover(hash: messageHash, signature: signatureData)
        
#if DEBUG
        print("EthereumAddress: \(ethereumAddress)")
        print("Address: \(String(describing: address))")
#endif
        
        return ethereumAddress == address
    }
    
    func signMessage(_ message: Data,
                     keystore: EthereumKeystoreV3,
                     account: EthereumAddress,
                     password: String = "web3swift",
                     needToHash: Bool = true,
                     useExtraEntropy: Bool = false) throws -> Data? {
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer { Data.zero(&privateKey) }
        
#if DEBUG
        print("Message hash: \(message.sha3(.keccak256).toHexString().addHexPrefix())")
#endif
        
        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: needToHash ? message.sha3(.keccak256) : message,
                                                                 privateKey: privateKey,
                                                                 useExtraEntropy: useExtraEntropy)
        
        return compressedSignature
    }
}
