//
//  Deployer.swift
//  zkSync-Demo
//
//  Created by Bojan on 1.9.23..
//

import Foundation
import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

public class BaseDeployer: Deployer {
    public let zkSync: ZkSyncClient
    public let web: Web3
    
    public let signer: ETHSigner
    
    public init(_ zkSync: ZkSyncClient, web3: Web3, ethSigner: ETHSigner) {
        self.zkSync = zkSync
        self.web = web3
        self.signer = ethSigner
    }
}

extension BaseDeployer {
    public func deploy(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) async -> TransactionSendingResult {
        let nonceToUse: BigUInt
        if let nonce = nonce {
            nonceToUse = nonce
        } else {
            nonceToUse = try! await getNonce()
        }
        
        let validCalldata: Data
        if let calldata = calldata {
            validCalldata = calldata
        } else {
            validCalldata = Data(hex: "0x")
        }
        
        let estimate = CodableTransaction.create2ContractTransaction(from: EthereumAddress(signer.address)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, bytecode: bytecode, deps: [bytecode], calldata: validCalldata, salt: Data(), chainId: signer.domain.chainId)
        
        return await AccountsUtil.estimateAndSend(zkSync: zkSync, signer: signer, estimate, nonce: nonceToUse)
    }
    
    public func deployWithCreate(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) async -> TransactionSendingResult {
        let nonceToUse: BigUInt
        if let nonce = nonce {
            nonceToUse = nonce
        } else {
            nonceToUse = try! await getNonce()
        }
        
        let validCalldata: Data
        if let calldata = calldata {
            validCalldata = calldata
        } else {
            validCalldata = Data(hex: "0x")
        }
        
        let estimate = CodableTransaction.createContractTransaction(from: EthereumAddress(signer.address)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, bytecode: bytecode, calldata: validCalldata)
        
        return await AccountsUtil.estimateAndSend(zkSync: zkSync, signer: signer, estimate, nonce: nonceToUse)
    }
    
    public func deployAccount(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) async -> TransactionSendingResult {
        let nonceToUse: BigUInt
        if let nonce = nonce {
            nonceToUse = nonce
        } else {
            nonceToUse = try! await getNonce()
        }
        
        let validCalldata: Data
        if let calldata = calldata {
            validCalldata = calldata
        } else {
            validCalldata = Data(hex: "0x")
        }
        
        let estimate = CodableTransaction.create2AccountTransaction(from: EthereumAddress(signer.address)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, bytecode: bytecode, deps: [bytecode], calldata: validCalldata, salt: Data(), chainId: signer.domain.chainId)
        
        return await AccountsUtil.estimateAndSend(zkSync: zkSync, signer: signer, estimate, nonce: nonceToUse)
    }
    
    public func deployAccountWithCreate(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) async -> TransactionSendingResult {
        let nonceToUse: BigUInt
        if let nonce = nonce {
            nonceToUse = nonce
        } else {
            nonceToUse = try! await getNonce()
        }
        
        let validCalldata: Data
        if let calldata = calldata {
            validCalldata = calldata
        } else {
            validCalldata = Data(hex: "0x")
        }
        
        let estimate = CodableTransaction.createAccountTransaction(from: EthereumAddress(signer.address)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, bytecode: bytecode, calldata: validCalldata)
        
        return await AccountsUtil.estimateAndSend(zkSync: zkSync, signer: signer, estimate, nonce: nonceToUse)
    }
}

extension BaseDeployer {
    public func getNonce(at block: BlockNumber = .latest) async throws -> BigUInt {
        try await web.eth.getTransactionCount(for: EthereumAddress(signer.address)!, onBlock: block)
    }
    
    public func getNonce() async throws -> BigUInt {
        try await getNonce(at: .latest)
    }
}
