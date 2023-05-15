//
//  BaseManager.swift
//  zkSync-Demo
//
//  Created by Bojan on 14.5.23..
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync
#endif

class BaseManager {
    let credentials = Credentials("0x7726827caac94a7f9e1b160f7ea819f172f7b6f9d2a97f992c38edeab82d4110")
    
    let zkSync: ZkSync = JsonRpc2_0ZkSync(URL(string: "http://127.0.0.1:3050")!)
    
    var chainId: BigUInt {
        try! zkSync.web3.eth.getChainIdPromise().wait()
    }
    
    var signer: EthSigner {
        PrivateKeyEthSigner(credentials, chainId: chainId)
    }
    
    var wallet: ZkSyncWallet {
        ZkSyncWallet(zkSync, ethSigner: signer, feeToken: Token.ETH)
    }
}
