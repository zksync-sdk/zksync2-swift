//
//  ContentViewModel.swift
//  zkSync-Demo
//
//  Created by Bojan on 14.5.23..
//

import Foundation

class ContentViewModel: ObservableObject {
    let baseManager = BaseManager()
    let smartContractManager = SmartContractManager()
    let transferManager = TransferManager()
    let depositManager = DepositManager()
    let withdrawManager = WithdrawManager()
    
    @Published var balance: Decimal = 0
    
    func check() {
        smartContractManager.check(callback: {
            
        })
    }
    
    func refreshBalance() {
        let balance = try! baseManager.wallet.getBalance().wait()
        
        let decimalBalance = Token.ETH.intoDecimal(balance)
        
        DispatchQueue.main.async {
            self.balance = decimalBalance
        }
    }
    
    func accountAbstraction() {
        smartContractManager.accountAbstraction(callback: {
            
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
    
    func transferViaWallet() {
        transferManager.transferViaWallet(callback: {
            refreshBalance()
        })
    }
    
    func transfer() {
        transferManager.transfer(callback: {
            refreshBalance()
        })
    }
    
    func deposit() {
        depositManager.deposit(callback: {
            self.refreshBalance()
        })
    }
    
    func withdrawViaWallet() {
        withdrawManager.withdrawViaWallet(callback: {
            refreshBalance()
        })
    }
}
