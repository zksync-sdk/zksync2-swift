//
//  PrivateKeyEthSigner.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/23/22.
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

public class PrivateKeyEthSigner: EthSigner {
    public var address: String {
        return credentials.address
    }
    
    var ethereumAddress: EthereumAddress {
        return credentials.ethereumAddress
    }
    
    public var domain: EIP712Domain
    
    let credentials: Credentials
    
    public init(_ credentials: Credentials, chainId: BigUInt) {
        self.credentials = credentials
        domain = EIP712Domain(chainId)
    }
    
    init(_ credentials: Credentials, zkSyncNetwork: ZkSyncNetwork) {
        self.credentials = credentials
        domain = EIP712Domain(zkSyncNetwork)
    }
    
    init(_ privateKey: String, chainId: BigUInt) {
        credentials = Credentials(privateKey)
        domain = EIP712Domain(chainId)
    }
    
    init(_ privateKey: String, zkSyncNetwork: ZkSyncNetwork) {
        credentials = Credentials(privateKey)
        domain = EIP712Domain(zkSyncNetwork)
    }
    
    public func signTypedData<S>(_ domain: EIP712Domain,
                          typedData: S) -> String where S : Structurable {
        return signMessage(EIP712Encoder.typedDataToSignedBytes(domain, typedData: typedData),
                           addPrefix: false)
    }
    
    public func verifyTypedData<S>(_ domain: EIP712Domain,
                            typedData: S,
                            signature: String) -> Bool where S : Structurable {
        return verifySignature(signature,
                               message: EIP712Encoder.typedDataToSignedBytes(domain, typedData: typedData),
                               prefixed: false)
    }
    
    public func signMessage(_ message: Data) -> String {
        return signMessage(message, addPrefix: true)
    }
    
    // TODO: Implement signing with no prefix.
    public func signMessage(_ message: Data, addPrefix: Bool) -> String {
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
                                                   keystore: credentials,
                                                   account: ethereumAddress,
                                                   needToHash: needToHash) else {
            preconditionFailure("Failed to sign.")
        }
        
        return signatureData.toHexString().addHexPrefix()
    }
    
    public func verifySignature(_ signature: String,
                         message: Data) -> Bool {
        return verifySignature(signature,
                               message: message,
                               prefixed: true)
    }
    
    // TODO: Implement verification with no prefix.
    public func verifySignature(_ signature: String,
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
