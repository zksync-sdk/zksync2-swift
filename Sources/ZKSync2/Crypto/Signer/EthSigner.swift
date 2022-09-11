//
//  EthSigner.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/23/22.
//

import Foundation
import web3swift

// ZKSync2 (Java): EthSigner.java
// ZKSync (Swift): EthSigner.swift
protocol EthSigner {
    
    var address: String { get }
    
    // TODO: Consider using `EIP712Domain`.
    var domain: Eip712Domain { get }
    
    func signTypedData<S: Structurable>(_ domain: Eip712Domain,
                                        typedData: S,
                                        completion: @escaping (Swift.Result<String, Error>) -> Void)
    
    func verifyTypedData<S: Structurable>(_ domain: Eip712Domain,
                                          typedData: S,
                                          signature: String,
                                          completion: @escaping (Swift.Result<Bool, Error>) -> Void)
    
    func signMessage(_ message: Data,
                     completion: @escaping (Swift.Result<String, Error>) -> Void)
    
    func signMessage(_ message: Data,
                     addPrefix: Bool,
                     completion: @escaping (Swift.Result<String, Error>) -> Void)
    
    func verifySignature(_ signature: String,
                         message: Data,
                         completion: @escaping (Swift.Result<Bool, Error>) -> Void)
    
    func verifySignature(_ signature: String,
                         message: Data,
                         prefixed: Bool,
                         completion: @escaping (Swift.Result<Bool, Error>) -> Void)
}
