//
//  ContentViewModel.swift
//  zkSync-Demo
//
//  Created by Bojan on 14.5.23..
//

import Foundation
import BigInt
#if canImport(zkSync2_swift)
import zkSync2_swift
#endif

class ContentViewModel: ObservableObject {
//222    let baseManager = BaseManager()
//    let smartContractManager = SmartContractManager()
//    let smartAccountManager = SmartAccountManager()
//    let paymasterManager = PaymasterManager()
//    let transferManager = TransferManager()
//    let depositManager = DepositManager()
//    let withdrawManager = WithdrawManager()
//    let tokenManager = TokenManager()
    
    @Published var balance: Decimal = 0
    
    var transferToAddress = "0x082b1BB53fE43810f646dDd71AA2AB201b4C6b04"
    var value = BigUInt(1_000_000_000_000)
    let smartContractAddress = "0xf3ea0f675900d6aa31b2a7a30612a70e83989052"
    let smartAccountAddress = "0x49720d21525025522040f73da5b3992112bbec00"
    let tokenAddress = "0xbc6b677377598a79fa1885e02df1894b05bc8b33"
    
    func refreshBalance() {
//222        let balance = try! baseManager.wallet.getBalance().wait()
//
//        let decimalBalance = Token.ETH.intoDecimal(balance)
//
//        DispatchQueue.main.async {
//            self.balance = decimalBalance
//        }
    }
    
    func deploySmartAccount() {
//222        smartAccountManager.deploySmartAccount(tokenAddress: tokenAddress, callback: {
//
//        })
    }
    
    func deploySmartContract() {
//222        smartContractManager.deploySmartContract(callback: {
//
//        })
    }
    
    func deploySmartContractViaWallet() {
//222        smartContractManager.deploySmartContractViaWallet(callback: {
//
//        })
    }
    
    func testSmartContract() {
//222        smartContractManager.testSmartContract(smartContractAddress: smartContractAddress, callback: {
//
//        })
    }
    
    func transfer() {
//222        transferManager.transfer(toAddress: transferToAddress, value: value, callback: {
//            refreshBalance()
//        })
    }
    
    func transferViaWallet() {
//222        transferManager.transferViaWallet(toAddress: transferToAddress, value: value, callback: {
//            refreshBalance()
//        })
    }
    
    func deposit() {
//222        depositManager.deposit(callback: {
//            self.refreshBalance()
//        })
    }
    
    func depositViaWallet() {
//222        depositManager.depositViaWallet(callback: {
//            self.refreshBalance()
//        })
    }
    
    func withdraw() {
//222        withdrawManager.withdraw(callback: {
//            self.refreshBalance()
//        })
    }
    
    func withdrawViaWallet() {
//222        withdrawManager.withdrawViaWallet(callback: {
//            self.refreshBalance()
//        })
    }
    
    func deployToken() {
//222        tokenManager.deployToken(callback: {
//
//        })
    }
    
    func mintToken() {
//222        tokenManager.mintToken(tokenAddress: tokenAddress, callback: {
//
//        })
    }
    
    func getAllTokens() {
//222        tokenManager.getAllTokens(callback: {
//
//        })
    }
    
    func tokenBalance() {
//222        tokenManager.tokenBalance(tokenAddress: tokenAddress, callback: {
//
//        })
    }
}
