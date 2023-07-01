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
    let smartAccountManager = SmartAccountManager()
    let paymasterManager = PaymasterManager()
    let transferManager = TransferManager()
    let depositManager = DepositManager()
    let withdrawManager = WithdrawManager()
    let tokenManager = TokenManager()
    
    @Published var balance: Decimal = 0
    
    func refreshBalance() {
        let balance = try! baseManager.wallet.getBalance().wait()
        
        let decimalBalance = Token.ETH.intoDecimal(balance)
        
        DispatchQueue.main.async {
            self.balance = decimalBalance
        }
        
        baseManager.zkSync.zksGetAllAccountBalances(baseManager.signer.address) { result in
            print("result:", result)
        }
    }
    
    func deployPaymaster() {
        paymasterManager.deployPaymaster(callback: {
            
        })
    }
    
    func deploySmartAccount() {
        smartAccountManager.deploySmartAccount(callback: {
            
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
        tokenManager.mintToken(callback: {
            
        })
    }
    
    func tokenBalance() {
        tokenManager.tokenBalance(callback: {
            
        })
    }
}
