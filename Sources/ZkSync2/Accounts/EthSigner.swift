//
//  EthSignerImpl.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/23/22.
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

public protocol ETHSigner {
    
    /// Address of the wallet.
    var address: String { get }
    
    /// EIP712 domain.
    var domain: EIP712Domain { get }
    
    /// Signs typed struct using ethereum private key by EIP-712 signature standard.
    ///
    /// - Parameters:
    ///   - domain: EIP712 domain.
    ///   - typedData: Object implementing EIP712 structure standard.
    /// - Returns: Signature object.
    func signTypedData<S: Structurable>(_ domain: EIP712Domain,
                                        typedData: S) -> String
    
    /// Verify typed EIP-712 struct standard.
    ///
    /// - Parameters:
    ///   - domain: EIP712 domain.
    ///   - typedData: Object implementing EIP712 structure standard.
    ///   - signature: Signature of the EIP-712 structures.
    /// - Returns: `true` on verification success.
    func verifyTypedData<S: Structurable>(_ domain: EIP712Domain,
                                          typedData: S,
                                          signature: String) -> Bool
    
    /// Sign raw message.
    ///
    /// - Parameter message: Message to sign.
    /// - Returns: Signature object.
    func signMessage(_ message: Data) -> String
    
    /// Sign raw message.
    ///
    /// - Parameters:
    ///   - message: Message to sign.
    ///   - addPrefix: If `true` then add secure prefix [EIP-712](https://eips.ethereum.org/EIPS/eip-712).
    /// - Returns: Signature object.
    func signMessage(_ message: Data, addPrefix: Bool) -> String
    
    /// Verify signature with raw message.
    ///
    /// - Parameters:
    ///   - signature: Signature object.
    ///   - message: Message to verify.
    /// - Returns: `true` on verification success.
    func verifySignature(_ signature: String, message: Data) -> Bool
    
    /// Verify signature with raw message.
    ///
    /// - Parameters:
    ///   - signature: Signature object.
    ///   - message: Message to verify.
    ///   - prefixed: If `true` then add secure prefix [EIP-712](https://eips.ethereum.org/EIPS/eip-712).
    /// - Returns: `true` on verification success.
    func verifySignature(_ signature: String,
                         message: Data,
                         prefixed: Bool) -> Bool
}

public class BaseSigner: ETHSigner {
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
    
    public func signTransaction(){
        
    }
    
    public func signTypedData<S>(_ domain: EIP712Domain,
                          typedData: S) -> String where S : Structurable {
        let a = EIP712Encoder.typedDataToSignedBytes(domain, typedData: typedData)
        return signMessage(a,
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
            guard let personalMessageHash = Utilities.hashPersonalMessage(message) else {
                fatalError("Unable to hash message.")
            }

            messageHash = personalMessageHash
        } else {
            messageHash = message
        }

        guard let signatureData = Data.fromHex(signature) else {
            fatalError("Invalid signature.")
        }

        let address = Utilities.hashECRecover(hash: messageHash, signature: signatureData)

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
        print(privateKey.toHexString())
#if DEBUG
        print("Message hash: \(message.sha3(.keccak256).toHexString().addHexPrefix())")
#endif
        let (compressedSignature, a) = SECP256K1.signForRecovery(hash: needToHash ? message.sha3(.keccak256) : message,
                                                                 privateKey: privateKey,
                                                                 useExtraEntropy: useExtraEntropy)

        return compressedSignature
    }
}
