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
#else
import web3swift_zksync2
#endif

public class DeployerImpl: Deployer {
    public let zkSync: ZkSyncClient
    public let web: web3
    
    public let signer: ETHSigner
    
    public init(_ zkSync: ZkSyncClient, web3: web3, ethSigner: ETHSigner) {
        self.zkSync = zkSync
        self.web = web3
        self.signer = ethSigner
    }
}

extension DeployerImpl {
    public func deploy(_ bytecode: Data) -> Promise<TransactionSendingResult> {
        deploy(bytecode, calldata: nil, nonce: nil)
    }
    
    public func deploy(_ bytecode: Data, calldata: Data?) -> Promise<TransactionSendingResult> {
        deploy(bytecode, calldata: calldata, nonce: nil)
    }
    
    public func deploy(_ bytecode: Data, calldata: Data?, nonce: BigUInt?) -> Promise<TransactionSendingResult> {
        let nonceToUse: BigUInt
        if let nonce = nonce {
            nonceToUse = nonce
        } else {
            nonceToUse = try! getNonce()
        }
        
        let validCalldata: Data
        if let calldata = calldata {
            validCalldata = calldata
        } else {
            validCalldata = Data(hex: "0x")
        }
        
        let estimate = EthereumTransaction.create2ContractTransaction(from: EthereumAddress(signer.address)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, bytecode: bytecode, deps: [bytecode], calldata: validCalldata, salt: Data(), chainId: signer.domain.chainId)
        
        return AccountsUtil.estimateAndSend(zkSync: zkSync, signer: signer, estimate, nonce: nonceToUse)
    }
}

extension DeployerImpl {
    public func getNonce(_ at: ZkBlockParameterName) -> Promise<BigUInt> {
        zkSync.web3.eth.getTransactionCountPromise(address: signer.address, onBlock: at.rawValue)
    }
    
    public func getNonce() throws -> BigUInt {
        try getNonce(.committed).wait()
    }
    
    public func getNonce() -> Promise<BigUInt> {
        getNonce(.committed)
    }
}
