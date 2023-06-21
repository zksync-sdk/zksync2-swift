//
//  WithdrawManager.swift
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

class WithdrawManager: BaseManager {
    func withdrawViaWallet(callback: (() -> Void)) {
        let manager = KeystoreManager.init([credentials])
        self.eth.addKeystoreManager(manager)
        
        let gasPrice = try! zkSync.web3.eth.getGasPrice()
        
        print("gasPrice:", gasPrice)
        
        let wallet = ZkSyncWallet(zkSync, ethSigner: signer, feeToken: Token.ETH)
        
        let amount = BigUInt(1000000000000)
        
        // Also we can withdraw ERC20 token
        let token: Token = Token(l1Address: "0x36615Cf349d7F6344891B1e7CA7C72883F5dc049", l2Address: Token.DefaultAddress, symbol: "ETH", decimals: 18)
        
        let result = try! wallet.withdraw("0x000000000000000000000000000000000000800a", amount: amount, token: token).wait()
        
        let l1ERC20Bridge = zkSync.web3.contract(
            Web3.Utils.IL1Bridge,
            at: EthereumAddress("0x4ee775658259028d399f4cf9d637b14773472988")
        )!
        
        zkSync.zksMainContract { result in
            DispatchQueue.global().async {
                switch result {
                case .success(let address):
                    let zkSyncContract = self.eth.contract(
                        Web3.Utils.IZkSync,
                        at: EthereumAddress(address)
                    )!
                    
                    let defaultEthereumProvider = DefaultEthereumProvider(self.eth, l1ERC20Bridge: l1ERC20Bridge, zkSyncContract: zkSyncContract, gasProvider: DefaultGasProvider())
                    
                    let token = Token(l1Address: "0x36615Cf349d7F6344891B1e7CA7C72883F5dc049", l2Address: Token.DefaultAddress, symbol: "ETH", decimals: 18)
                    
                    let result = try! defaultEthereumProvider.deposit(with: token, amount: amount, operatorTips: BigUInt(0), to: "0x36615Cf349d7F6344891B1e7CA7C72883F5dc049").wait()
                    
                    print("hash:", result.hash)
                default: return
                }
            }
        }
        
        // finalize withdraw on l1
        // get l2 hash from priority op
        // wait for transaction to be finalized
        
        callback()
    }
}
