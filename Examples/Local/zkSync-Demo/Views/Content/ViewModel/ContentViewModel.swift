//
//  ContentViewModel.swift
//  zkSync-Demo
//
//  Created by Bojan on 14.5.23..
//

import Foundation

class ContentViewModel: ObservableObject {
    let baseManager = BaseManager()
    let transferManager = TransferManager()
    let depositManager = DepositManager()
    let withdrawManager = WithdrawManager()
    
    @Published var balance: Decimal = 0
    
    func refreshBalance() {
        let balance = try! baseManager.wallet.getBalance().wait()
        
        let decimalBalance = Token.ETH.intoDecimal(balance)
        
        self.balance = decimalBalance
    }
    
    func transferViaWallet() {
        transferManager.transfer(callback: {
            refreshBalance()
        })
    }
}
