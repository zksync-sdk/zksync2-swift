//
//  Adapter.swift
//  zkSync-Demo
//
//  Created by Bojan on 1.9.23..
//

import Foundation
import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

// AdapterL1 is associated with an account and provides common operations on the
// L1 network for the associated account.
public protocol AdapterL1 {
    func deposit(_ to: String, amount: BigUInt) -> Promise<TransactionSendingResult>
    func deposit(_ to: String, amount: BigUInt, token: Token) -> Promise<TransactionSendingResult>
    func deposit(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
}

// AdapterL2 is associated with an account and provides common operations on the
// L2 network for the associated account.
public protocol AdapterL2 {
    func withdraw(_ to: String, amount: BigUInt) -> Promise<TransactionSendingResult>
    func withdraw(_ to: String, amount: BigUInt, token: Token) -> Promise<TransactionSendingResult>
    func withdraw(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
    
    func transfer(_ to: String, amount: BigUInt) -> Promise<TransactionSendingResult>
    func transfer(_ to: String, amount: BigUInt, token: Token) -> Promise<TransactionSendingResult>
    func transfer(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
}

// Deployer is associated with an account and provides deployment of smart contracts
// and smart accounts on L2 network for the associated account.
public protocol Deployer {
    func deploy(_ bytecode: Data) -> Promise<TransactionSendingResult>
    func deploy(_ bytecode: Data, calldata: Data?) -> Promise<TransactionSendingResult>
    func deploy(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) -> Promise<TransactionSendingResult>
}
