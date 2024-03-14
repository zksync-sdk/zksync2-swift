//
//  ZkSyncWeb3RpcIntegrationTests.swift
//  ZkSync2Tests
//
//  Created by Maxim Makhun on 7/26/22.
//

import XCTest
import web3swift
import BigInt
import PromiseKit
import Web3Core
@testable import ZkSync2

class ZKSyncWeb3RpcIntegrationTests: BaseIntegrationEnv {
    func testGetNonce() async{
        let nonce = try! await self.zkSync.web3.eth.getTransactionCount(for: self.credentials.ethereumAddress)
        XCTAssertGreaterThan(nonce, 0)
    }

    func testGetDeploymentNonce() async {
        let nonceHolder = NonceHolder(EthereumAddress(ZkSyncAddresses.NonceHolderAddress)!,
                                      zkSync: self.zkSync,
                                      credentials: self.credentials)
        
        let data = await nonceHolder.getDeploymentNonce(self.credentials.ethereumAddress)
        let nonce = BigUInt.init(data.toHexString())
        XCTAssertNotNil(nonce)
    }
    
    func testGetAllAccountBalances() async {
        let accountBalances = try! await self.zkSync.allAccountBalances(self.credentials.address)
        XCTAssertNotNil(accountBalances)
    }

    func testGetL1ChainId() async {
        let chainId = try! await self.zkSync.L1ChainId()
        XCTAssertEqual(chainId, 9)
    }
    
    func testGetBridgeContracts() async{
        let result = try! await self.zkSync.bridgeContracts()
        XCTAssertNotNil(result)
    }
    
    func testGetTestnetPaymaster() async {
        let result = try! await self.zkSync.getTestnetPaymaster()
        XCTAssertNotNil(result)
    }
    
    func testGetMainContract() async {
        let result = try! await self.zkSync.mainContract()
        XCTAssertNotNil(result)
    }
    
    func testEstimateGasWithdraw() async {
        let gas = try! await self.zkSync.estimateGasWithdraw(BigUInt(7_000_000_000), from: self.credentials.address, to: nil, token: nil, options: nil, paymasterParams: nil)
        XCTAssertGreaterThan(gas!, BigUInt.zero)
    }
    
    func testEstimateGasTransfer() async {
        let gas = await self.zkSync.estimateGasTransfer(BaseIntegrationEnv.RECEIVER, amount: BigUInt(7_000_000_000), from: self.credentials.address, token: nil, options: nil, paymasterParams: nil)
        XCTAssertGreaterThan(gas, BigUInt.zero)
    }
}
