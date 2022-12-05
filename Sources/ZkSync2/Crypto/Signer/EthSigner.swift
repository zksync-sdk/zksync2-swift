//
//  EthSigner.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/23/22.
//

import Foundation
import web3swift

public protocol EthSigner {
    
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
