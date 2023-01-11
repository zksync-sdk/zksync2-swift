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

class BaseIntegrationEnv: XCTestCase {
    
    static let L1NodeUrl = URL(string: "https://goerli.infura.io/v3/fc6f2c1e05b447969453c194a0326020")!
    static let L2NodeUrl = URL(string: "https://zksync2-testnet.zksync.dev")!
    
    let ethToken = Token.ETH
    
    var l1Web3: web3!
    
    var zkSync: JsonRpc2_0ZkSync!
    
    let credentials = Credentials(BigUInt.one)
    
    var signer: EthSigner!
    
    var feeProvider: ZkTransactionFeeProvider!
    
    var chainId: BigUInt!
    
    override func setUpWithError() throws {
        let expectation = expectation(description: "Expectation.")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            self.l1Web3 = try! Web3.new(ZKSyncWeb3RpcIntegrationTests.L1NodeUrl)
            
            self.zkSync = JsonRpc2_0ZkSync(BaseIntegrationEnv.L2NodeUrl)
            
            self.chainId = try! self.zkSync.web3.eth.getChainIdPromise().wait()
            
            self.signer = PrivateKeyEthSigner(self.credentials,
                                              chainId: self.chainId)
            
            self.feeProvider = DefaultTransactionFeeProvider(zkSync: self.zkSync,
                                                             feeToken: self.ethToken)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
