//
//  BaseIntegrationEnv.swift
//  ZkSync2Tests
//
//  Created by Maxim Makhun on 1/2/23.
//

import XCTest
@testable import ZkSync2
import BigInt
import web3swift
import Web3Core
import Foundation

class BaseIntegrationEnv: XCTestCase {
    
    static let L1NodeUrl = URL(string: "http://127.0.0.1:8545")!
    static let L2NodeUrl = URL(string: "http://127.0.0.1:3050")!
    static let RECEIVER = "0xa61464658AfeAf65CccaaFD3a512b69A83B77618"
    
    let ethToken = Token.ETH
    
    var l1Web3: EthereumClient!
    
    var zkSync: ZkSyncClient!
    
    let credentials = Credentials("0x7726827caac94a7f9e1b160f7ea819f172f7b6f9d2a97f992c38edeab82d4110")
    
    var signer: ETHSigner!
    
    var signerL2: ETHSigner!
        
    var chainId: BigUInt!
    
    var wallet: Wallet!
    
    override func setUpWithError() throws {
        let expectation = expectation(description: "Expectation.")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            self.l1Web3 = EthereumClientImpl(ZKSyncWeb3RpcIntegrationTests.L1NodeUrl)
            
            self.zkSync = BaseClient(BaseIntegrationEnv.L2NodeUrl)
            
            let chainId = BigUInt(9)
            
            self.signer = BaseSigner(self.credentials,
                                    chainId: chainId)
            self.signerL2 = BaseSigner(self.credentials,
                                      chainId: BigUInt(270))
            let walletL1 = WalletL1(zkSync, ethClient: l1Web3, web3: l1Web3.web3, ethSigner: signer)
            let walletL2 = WalletL2(zkSync, ethClient: l1Web3, web3: zkSync.web3, ethSigner: signerL2)
            let baseDeployer = BaseDeployer(adapterL2: walletL2, signer: signerL2)
            self.wallet = Wallet(walletL1: walletL1, walletL2: walletL2, deployer: baseDeployer)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
