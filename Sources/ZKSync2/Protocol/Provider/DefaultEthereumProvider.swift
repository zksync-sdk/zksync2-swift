//
//  DefaultEthereumProvider.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
import web3swift

public class DefaultEthereumProvider: EthereumProvider {
    
    public func approveDeposits(with token: Token,
                                limit: BigUInt?,
                                completion: @escaping (Result<TransactionReceipt, Error>) -> Void) {
        
    }
    
    public func transfer(with token: Token,
                         amount: BigUInt,
                         to address: String,
                         completion: @escaping (Result<TransactionReceipt, Error>) -> Void) {
        
    }
    
    public func deposit(with token: Token,
                        amount: BigUInt,
                        to userAddress: String,
                        completion: @escaping (Result<TransactionReceipt, Error>) -> Void) {
        
    }
    
    public func withdraw(with token: Token,
                         amount: BigUInt,
                         from userAddress: String,
                         completion: @escaping (Result<TransactionReceipt, Error>) -> Void) {
        
    }
    
    public func isDepositApproved(with token: Token,
                                  address: String,
                                  threshold: BigUInt?,
                                  completion: @escaping (Result<Bool, Error>) -> Void) {
        
    }
    
    public var contractAddress: String = ""
    
    let web3: web3
    
    init(_ web3: web3) {
        self.web3 = web3
    }
}
