//
//  Wallet.swift
//  zkSync-Demo
//
//  Created by Bojan on 26.9.23..
//

import Foundation

public class Wallet {
    public var walletL1: WalletL1
    public var walletL2: WalletL2
    public var deployer: BaseDeployer
    
    public init(walletL1: WalletL1, walletL2: WalletL2, deployer: BaseDeployer) {
        self.walletL1 = walletL1
        self.walletL2 = walletL2
        self.deployer = deployer
    }
}
