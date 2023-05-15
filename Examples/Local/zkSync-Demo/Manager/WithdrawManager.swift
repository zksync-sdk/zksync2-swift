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
    func withdrawViaWallet() {
        let gasPrice = try! zkSync.web3.eth.getGasPrice()
        
        print("gasPrice:", gasPrice)
        
        let wallet = ZkSyncWallet(zkSync, ethSigner: signer, feeToken: Token.ETH)
        
        let balance = try! wallet.getBalance().wait()
        
        print("balance before:", balance)
        
        let amount = BigUInt(1000000000000)
        
        // Also we can withdraw ERC20 token
        let token: Token = Token(l1Address: "0x36615Cf349d7F6344891B1e7CA7C72883F5dc049", l2Address: Token.DefaultAddress, symbol: "ETH", decimals: 18)
        
        let transactionSendingResult = try! wallet.withdraw("0xa61464658AfeAf65CccaaFD3a512b69A83B77618", amount: amount, token: token).wait()
        
        print(transactionSendingResult)
        
        let balance2 = try! wallet.getBalance().wait()
        
        print("balance after:", balance2)
    }
}
