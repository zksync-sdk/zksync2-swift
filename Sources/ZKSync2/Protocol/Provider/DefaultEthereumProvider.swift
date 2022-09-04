//
//  DefaultEthereumProvider.swift
//  ZKSync2
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

// ZKSync (Java): DefaultEthereumProvider.java
// ZKSync2 (Java): DefaultEthereumProvider.java
// ZKSync (Swift): EthereumProvider.swift
class DefaultEthereumProvider: EthereumProvider {
    
    static let DefaultThreshold = BigUInt.two.power(255)
    
    let web3: web3
    
    lazy var l1ERC20Bridge: web3.web3contract = {
        let contract = web3.contract(Web3.Utils.IL1Bridge)
        precondition(contract != nil)
        return contract!
    }()
    
    var l1ERC20BridgeAddress: String {
        // FIXME: `web3contract.contract` was modified.
        return l1ERC20Bridge.contract.address!.address
    }
    
    lazy var l1EthBridge: web3.web3contract = {
        let contract = web3.contract(Web3.Utils.IL1Bridge)
        precondition(contract != nil)
        return contract!
    }()
    
    var l1EthBridgeAddress: String {
        // FIXME: `web3contract.contract` was modified.
        return l1EthBridge.contract.address!.address
    }
    
    lazy var contract: web3.web3contract = {
        let contract = web3.contract(Web3.Utils.ZKSyncABI)
        precondition(contract != nil)
        return contract!
    }()
    
    init(_ web3: web3) {
        self.web3 = web3
    }
    
    func gasPrice() throws -> BigUInt {
        return try web3.eth.getGasPrice()
    }
    
    func approveDeposits(with token: Token,
                         limit: BigUInt?) throws -> Promise<TransactionSendingResult> {
        guard let tokenAddress = EthereumAddress(token.l1Address) else {
            throw EthereumProviderError.invalidToken
        }
        
        let tokenContract = ERC20(web3: web3,
                                  provider: web3.provider,
                                  address: tokenAddress)
        
        guard let spenderAddress = EthereumAddress(l1ERC20BridgeAddress) else {
            throw EthereumProviderError.invalidToken
        }
        
        let maxApproveAmount = BigUInt.two.power(256) - 1
        let amount = limit?.description ?? maxApproveAmount.description
        
        do {
            let tx = try tokenContract.approve(from: spenderAddress,
                                               spender: spenderAddress,
                                               amount: amount)
            return tx.sendPromise()
        } catch {
            return .init(error: error)
        }
    }
    
    func transfer(with token: Token,
                  amount: BigUInt,
                  to address: String) throws -> Promise<TransactionSendingResult> {
        //        guard let toAddress = EthereumAddress(address) else {
        //            throw EthereumProviderError.invalidAddress
        //        }
        //
        //        let writeTransaction: WriteTransaction
        //
        //        if token.isETH {
        //            guard let intermediateTransaction = web3.eth.sendETH(to: toAddress,
        //                                                                 amount: amount.description,
        //                                                                 units: .wei) else {
        //                throw EthereumProviderError.internalError
        //            }
        //
        //            writeTransaction = intermediateTransaction
        //        } else {
        //            guard let tokenAddress = EthereumAddress(token.address) else {
        //                throw EthereumProviderError.invalidToken
        //            }
        //
        //            let tokenContract = ERC20(web3: web3,
        //                                      provider: web3.provider,
        //                                      address: tokenAddress)
        //
        //            //            tokenContract.transfer(from: <#T##EthereumAddress#>, to: <#T##EthereumAddress#>, amount: <#T##String#>)
        //
        //            //            guard let intermediateTransaction = web3.eth.sendERC20tokensWithKnownDecimals(tokenAddress: erc20ContractAddress,
        //            //                                                                                          from: ethereumAddress,
        //            //                                                                                          to: toAddress,
        //            //                                                                                          amount: amount) else {
        //            //                throw EthereumProviderError.internalError
        //            //            }
        //
        //            //            writeTransaction = intermediateTransaction
        //        }
        
        throw EthereumProviderError.internalError
    }
    
    func deposit(with token: Token,
                 amount: BigUInt,
                 to userAddress: String) throws -> Promise<TransactionSendingResult> {
        
        //        {
        //            "inputs": [
        //                {
        //                    "internalType": "uint256",
        //                    "name": "_gasPrice",
        //                    "type": "uint256"
        //                },
        //                {
        //                    "internalType": "enum Operations.QueueType",
        //                    "name": "_queueType",
        //                    "type": "uint8"
        //                },
        //                {
        //                    "internalType": "enum Operations.OpTree",
        //                    "name": "_opTree",
        //                    "type": "uint8"
        //                }
        //            ],
        //            "name": "depositBaseCost",
        //            "outputs": [
        //                {
        //                    "internalType": "uint256",
        //                    "name": "",
        //                    "type": "uint256"
        //                }
        //            ],
        //            "stateMutability": "view",
        //            "type": "function"
        //        }
        
        // gasPrice()
        
        
        
        //        guard let userAddress = EthereumAddress(userAddress) else {
        //            return .init(error: EthereumProviderError.invalidAddress)
        //        }
        //
        //        if token.isETH {
        //            return zkSync.depositETH(address: userAddress, value: amount)
        //        } else {
        //            guard let tokenAddress = EthereumAddress(token.address) else {
        //                return .init(error: EthereumProviderError.invalidTokenAddress)
        //            }
        //            return zkSync.depositERC20(tokenAddress: tokenAddress, amount: amount, userAddress: userAddress)
        //        }
        
        throw EthereumProviderError.internalError
    }
    
    func withdraw(with token: Token,
                  amount: BigUInt,
                  from userAddress: String) throws -> Promise<TransactionSendingResult> {
        //        {
        //            "inputs": [
        //                {
        //                    "internalType": "address",
        //                    "name": "_token",
        //                    "type": "address"
        //                },
        //                {
        //                    "internalType": "uint256",
        //                    "name": "_amount",
        //                    "type": "uint256"
        //                },
        //                {
        //                    "internalType": "address",
        //                    "name": "_to",
        //                    "type": "address"
        //                },
        //                {
        //                    "internalType": "enum Operations.QueueType",
        //                    "name": "_queueType",
        //                    "type": "uint8"
        //                },
        //                {
        //                    "internalType": "enum Operations.OpTree",
        //                    "name": "_opTree",
        //                    "type": "uint8"
        //                }
        //            ],
        //            "name": "requestWithdraw",
        //            "outputs": [],
        //            "stateMutability": "payable",
        //            "type": "function"
        //        }
        
        //        guard let tokenAddress = EthereumAddress(token.address),
        //              let userAddress = EthereumAddress(userAddress) else {
        //            throw EthereumProviderError.invalidToken
        //        }
        //
        //        guard let intermediateTransaction = contract.write("requestWithdraw",
        //                                                           parameters: [tokenAddress, amount, userAddress] as [AnyObject],
        //                                                           transactionOptions: nil /* ? */) else {
        //            return Promise(error: EthereumProviderError.invalidParameter)
        //        }
        //
        //        return intermediateTransaction.sendPromise()
        
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
}
