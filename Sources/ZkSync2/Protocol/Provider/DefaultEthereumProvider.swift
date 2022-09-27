//
//  DefaultEthereumProvider.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
import web3swift
import PromiseKit

extension DefaultEthereumProvider {
    
    enum EthereumProviderError: Error {
        case invalidAddress
        case invalidToken
        case invalidParameter
        case internalError
    }
}

// ZkSync (Java): DefaultEthereumProvider.java
// ZkSync2 (Java): DefaultEthereumProvider.java
// ZkSync (Swift): EthereumProvider.swift
class DefaultEthereumProvider: EthereumProvider {
    
    static let MaxApproveAmount = BigUInt.two.power(256).subtracting(BigUInt.one)
    static let DefaultThreshold = BigUInt.two.power(255)
    
    let web3: web3
    
    var l1ERC20Bridge: web3.web3contract!
    
    var l1ERC20BridgeAddress: String {
        return l1ERC20Bridge.contract.address!.address
    }
    
    var l1EthBridge: web3.web3contract!
    
    var l1EthBridgeAddress: String {
        return l1EthBridge.contract.address!.address
    }
    
    init(_ web3: web3,
         l1ERC20Bridge: web3.web3contract,
         l1EthBridge: web3.web3contract) {
        self.web3 = web3
        self.l1ERC20Bridge = l1ERC20Bridge
        self.l1EthBridge = l1EthBridge
    }
    
    func gasPrice() throws -> BigUInt {
        return try web3.eth.getGasPrice()
    }
    
    func approveDeposits(with token: Token,
                         limit: BigUInt?) throws -> Promise<TransactionSendingResult> {
        guard let tokenAddress = EthereumAddress(token.l1Address),
              let spenderAddress = EthereumAddress(l1ERC20BridgeAddress) else {
            throw EthereumProviderError.invalidToken
        }
        
        let tokenContract = ERC20(web3: web3,
                                  provider: web3.provider,
                                  address: tokenAddress)
        
        let maxApproveAmount = BigUInt.two.power(256) - 1
        let amount = limit?.description ?? maxApproveAmount.description
        
        do {
            let transaction = try tokenContract.approve(from: spenderAddress,
                                                        spender: spenderAddress,
                                                        amount: amount)
            return transaction.sendPromise()
        } catch {
            return .init(error: error)
        }
    }
    
    func transfer(with token: Token,
                  amount: BigUInt,
                  to address: String) throws -> Promise<TransactionSendingResult> {
        let transaction: WriteTransaction
        do {
            if token.isETH {
                transaction = try transferEth(amount: amount,
                                              to: address)
            } else {
                transaction = try transferERC20(token: token,
                                                amount: amount,
                                                to: address)
            }
            
            return transaction.sendPromise()
        } catch {
            return .init(error: error)
        }
    }
    
    func transferEth(amount: BigUInt,
                     to address: String) throws -> WriteTransaction {
        guard let fromAddress = EthereumAddress(l1ERC20BridgeAddress),
              let toAddress = EthereumAddress(address) else {
            throw EthereumProviderError.invalidAddress
        }
        
        guard let transaction = web3.eth.sendETH(from: fromAddress,
                                                 to: toAddress,
                                                 amount: amount.description,
                                                 units: .wei) else {
            throw EthereumProviderError.internalError
        }
        
        return transaction
    }
    
    func transferERC20(token: Token,
                       amount: BigUInt,
                       to address: String) throws -> WriteTransaction {
        guard let fromAddress = EthereumAddress(l1ERC20BridgeAddress),
              let toAddress = EthereumAddress(address),
              let erc20ContractAddress = EthereumAddress(token.l1Address) else {
            throw EthereumProviderError.invalidToken
        }
        
        guard let transaction = web3.eth.sendERC20tokensWithKnownDecimals(tokenAddress: erc20ContractAddress,
                                                                          from: fromAddress,
                                                                          to: toAddress,
                                                                          amount: amount) else {
            throw EthereumProviderError.internalError
        }
        
        return transaction
    }
    
    func deposit(with token: Token,
                 amount: BigUInt,
                 to userAddress: String) throws -> Promise<TransactionSendingResult> {
        guard let userAddress = EthereumAddress(userAddress) else {
            return .init(error: EthereumProviderError.invalidAddress)
        }
        
        if token.isETH {
            let parameters = [
                userAddress,
                EthereumAddress.Default,
                amount
            ] as [AnyObject]
            
            guard let transaction = l1EthBridge.write("deposit",
                                                      parameters: parameters,
                                                      transactionOptions: transactionWriteOptions()) else {
                return Promise(error: EthereumProviderError.invalidParameter)
            }
            
            return transaction.sendPromise()
        } else {
            let parameters = [
                userAddress,
                token.l1Address,
                amount
            ] as [AnyObject]
            
            guard let transaction = l1ERC20Bridge.write("deposit",
                                                        parameters: parameters,
                                                        transactionOptions: transactionWriteOptions()) else {
                return Promise(error: EthereumProviderError.invalidParameter)
            }
            
            return transaction.sendPromise()
        }
    }
    
    func withdraw(with token: Token,
                  amount: BigUInt,
                  from userAddress: String) throws -> Promise<TransactionSendingResult> {
        throw EthereumProviderError.internalError
    }
    
    func isDepositApproved(with token: Token,
                           address: String,
                           threshold: BigUInt?) throws -> Bool {
        guard let tokenAddress = EthereumAddress(token.l1Address),
              let ownerAddress = EthereumAddress(address),
              let spenderAddress = EthereumAddress(l1ERC20BridgeAddress) else {
            throw EthereumProviderError.invalidToken
        }
        
        let tokenContract = ERC20(web3: web3,
                                  provider: web3.provider,
                                  address: tokenAddress)
        
        let allowance = try tokenContract.getAllowance(originalOwner: ownerAddress,
                                                       delegate: spenderAddress)
        
        return allowance > (threshold ?? DefaultEthereumProvider.DefaultThreshold)
    }
    
    static func load(_ zkSync: ZkSync,
                     web3: web3,
                     completion: @escaping (_ defaultEthereumProvider: DefaultEthereumProvider) -> Void) {
        zkSync.zksGetBridgeContracts { result in
            switch result {
            case .success(let bridgeAddresses):
                let l1ERC20Bridge = web3.contract(Web3.Utils.IL1Bridge,
                                                  at: EthereumAddress(bridgeAddresses.l1Erc20DefaultBridge))!
                
                let l1EthBridge = web3.contract(Web3.Utils.IL1Bridge,
                                                at: EthereumAddress(bridgeAddresses.l1EthDefaultBridge))!
                
                let defaultEthereumProvider = DefaultEthereumProvider(web3,
                                                                      l1ERC20Bridge: l1ERC20Bridge,
                                                                      l1EthBridge: l1EthBridge)
                
                completion(defaultEthereumProvider)
            case .failure(let error):
                fatalError("Error occured while getting bridge contracts: \(error.localizedDescription)")
            }
        }
    }
    
    private func transactionWriteOptions() -> TransactionOptions {
        var transactionOptions = TransactionOptions.defaultOptions

        return transactionOptions
    }
    
    private func transactionReadOptions() -> TransactionOptions {
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.callOnBlock = .latest
        
        return transactionOptions
    }
}
