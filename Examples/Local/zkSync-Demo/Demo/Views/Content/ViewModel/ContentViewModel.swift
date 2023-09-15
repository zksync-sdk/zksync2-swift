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
    let baseManager = BaseManager()
    let smartContractManager = SmartContractManager()
    let smartAccountManager = SmartAccountManager()
    let paymasterManager = PaymasterManager()
    let transferManager = TransferManager()
    let depositManager = DepositManager()
    let withdrawManager = WithdrawManager()
    let tokenManager = TokenManager()
    
    @Published var balance: Decimal = 0
    
    var transferToAddress = "0x082b1BB53fE43810f646dDd71AA2AB201b4C6b04"
    var value = BigUInt(1_000_000_000_000)
    let smartContractAddress = "0xf3ea0f675900d6aa31b2a7a30612a70e83989052"
    let smartAccountAddress = "0x49720d21525025522040f73da5b3992112bbec00"
    let tokenAddress = "0xbc6b677377598a79fa1885e02df1894b05bc8b33"
    
    func refreshBalance() {
        let balance = try! baseManager.walletL2.getBalance().wait()
        
        let decimalBalance = Token.ETH.intoDecimal(balance)
        
        DispatchQueue.main.async {
            self.balance = decimalBalance
        }
    }
    
    func deploySmartAccount() {
        smartAccountManager.deploySmartAccount(tokenAddress: tokenAddress, callback: {
            
        })
    }
    
    func deploySmartContract() {
        smartContractManager.deploySmartContract(callback: {
            
        })
    }
    
    func deploySmartContractViaWallet() {
        smartContractManager.deploySmartContractViaWallet(callback: {
            
        })
    }
    
    func testSmartContract() {
        smartContractManager.testSmartContract(smartContractAddress: smartContractAddress, callback: {
            
        })
    }
    
    func transfer() {
        transferManager.transfer(toAddress: transferToAddress, value: value, callback: {
            refreshBalance()
        })
    }
    
    func transferViaWallet() {
        transferManager.transferViaWallet(toAddress: transferToAddress, value: value, callback: {
            refreshBalance()
        })
    }
    
    func depositViaWallet() {
        depositManager.depositViaWallet(callback: {
            self.refreshBalance()
        })
    }
    
    func withdraw() {
        withdrawManager.withdraw(callback: {
            self.refreshBalance()
        })
    }
    
    func withdrawViaWallet() {
        withdrawManager.withdrawViaWallet(callback: {
            self.refreshBalance()
        })
    }
    
    func deployToken() {
        tokenManager.deployToken(callback: {

        })
    }
    
    func mintToken() {
        tokenManager.mintToken(tokenAddress: tokenAddress, callback: {
            
        })
    }
    
    func getAllTokens() {
        tokenManager.getAllTokens(callback: {
            
        })
    }
    
    func tokenBalance() {
        tokenManager.tokenBalance(tokenAddress: tokenAddress, callback: {
            
        })
    }
}
