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
        let gasPrice = try! zkSync.web3.eth.getGasPrice()
        
        print("gasPrice:", gasPrice)
        
        let wallet = ZkSyncWallet(zkSync, ethSigner: signer, feeToken: Token.ETH)
        
        let balance = try! wallet.getBalance().wait()
        
        print("balance before:", balance)
        
        let amount = BigUInt(1000000000000)
        
        // Also we can withdraw ERC20 token
        let token: Token = Token(l1Address: "0x36615Cf349d7F6344891B1e7CA7C72883F5dc049", l2Address: Token.DefaultAddress, symbol: "ETH", decimals: 18)
        
        let transactionSendingResult = try! wallet.withdraw("0x000000000000000000000000000000000000800a", amount: amount, token: token).wait()
        
        let balance2 = try! wallet.getBalance().wait()
        
        print("balance after:", balance2)
        
        // finalize withdraw on l1
        // get l2 hash from priority op
        // wait for transaction to be finalized
        
        callback()
    }
}
