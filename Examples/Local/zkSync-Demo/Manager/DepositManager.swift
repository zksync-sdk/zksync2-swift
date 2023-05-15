//
//  DepositManager.swift
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

class DepositManager: BaseManager {
    public static func deposit() {
        let value: BigUInt = 1
        
        let credentials = Credentials("0x7726827caac94a7f9e1b160f7ea819f172f7b6f9d2a97f992c38edeab82d4110")
        
        let zkSync: ZkSync = JsonRpc2_0ZkSync(URL(string: "http://127.0.0.1:3050")!)
        
        //        self.aaaa = try! DefaultEthereumProvider.load(zkSync, web3: zkSync.web3, gasProvider: DefaultGasProvider()).wait()
        //
        //        print("dep", self.aaaa)
        
        //        zkSync.zksGetBridgeContracts { result in
        //            switch result {
        //            case .success(let bridgeAddresses):
        let l1ERC20Bridge = zkSync.web3.contract(Web3.Utils.IL1Bridge,
                                                 at: EthereumAddress("0x4ee775658259028d399f4cf9d637b14773472988"))!
        
        let l1EthBridge = zkSync.web3.contract(Web3.Utils.IL1Bridge,
                                               at: EthereumAddress("0x4ee775658259028d399f4cf9d637b14773472988"))!
        
        let defaultEthereumProvider = DefaultEthereumProvider(zkSync.web3, l1ERC20Bridge: l1ERC20Bridge, zkSyncContract: l1EthBridge, gasProvider: DefaultGasProvider())
        
        let token = Token(l1Address: "0x36615Cf349d7F6344891B1e7CA7C72883F5dc049", l2Address: Token.DefaultAddress, symbol: "ETH", decimals: 18)
        
        let result = try! defaultEthereumProvider.deposit(with: token, amount: value, operatorTips: BigUInt(0.0001), to: "0xa61464658AfeAf65CccaaFD3a512b69A83B77618").wait()
        
        print("1111", result)
        //            case .failure(let error):
        //                print("2222", error)
        //            }
        //        }
    }
}
