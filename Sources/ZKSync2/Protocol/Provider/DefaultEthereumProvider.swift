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
public class DefaultEthereumProvider: EthereumProvider {
    
    public static let DefaultThreshold = BigUInt.two.power(255)
    
    let web3: web3
    
    public var contractAddress: EthereumAddress? {
        // FIXME: `web3contract.contract` was modified.
//        contract.contract.address
        nil
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
    
//    public func approveDeposits(with token: Token,
//                                limit: BigUInt?) throws -> Promise<TransactionSendingResult> {
////        let tokenContract = ERC20(web3: web3,
////                                  provider: contract.web3.provider,
////                                  address: token.address)
////
////        tokenContract.approve(from: contract.contract.address,
////                              spender: <#T##EthereumAddress#>,
////                              amount: <#T##String#>)
//
////        guard let tokenAddress = EthereumAddress(token.address) else {
////            throw EthereumProviderError.invalidToken
////        }
////
////        let tokenContract = ERC20(web3: web3,
////                                  provider: web3.provider,
////                                  address: tokenAddress)
////
////        tokenContract.approve(from: <#T##EthereumAddress#>,
////                              spender: <#T##EthereumAddress#>,
////                              amount: <#T##String#>)
//    }
    
//    public func transfer(with token: Token,
//                         amount: BigUInt,
//                         to address: String) throws -> Promise<TransactionSendingResult> {
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
////            tokenContract.transfer(from: <#T##EthereumAddress#>, to: <#T##EthereumAddress#>, amount: <#T##String#>)
//
////            guard let intermediateTransaction = web3.eth.sendERC20tokensWithKnownDecimals(tokenAddress: erc20ContractAddress,
////                                                                                          from: ethereumAddress,
////                                                                                          to: toAddress,
////                                                                                          amount: amount) else {
////                throw EthereumProviderError.internalError
////            }
//
////            writeTransaction = intermediateTransaction
//        }
//    }
    
    public func deposit(with token: Token,
                        amount: BigUInt,
                        to userAddress: String,
                        completion: @escaping (Swift.Result<TransactionReceipt, Error>) -> Void) {
        
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
    }
    
    public func withdraw(with token: Token,
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
        
        guard let tokenAddress = EthereumAddress(token.address),
              let userAddress = EthereumAddress(userAddress) else {
            throw EthereumProviderError.invalidToken
        }
        
        guard let intermediateTransaction = contract.write("requestWithdraw",
                                                           parameters: [tokenAddress, amount, userAddress] as [AnyObject],
                                                           transactionOptions: nil /* ? */) else {
            return Promise(error: EthereumProviderError.invalidParameter)
        }
        
        return intermediateTransaction.sendPromise()
    }
    
    public func isDepositApproved(with token: Token,
                                  address: String,
                                  threshold: BigUInt?) throws -> Bool {
        guard let tokenAddress = EthereumAddress(token.address),
              let toAddress = EthereumAddress(address),
              let contractAddress = contractAddress else {
            throw EthereumProviderError.invalidToken
        }
        
        let tokenContract = ERC20(web3: web3,
                                  provider: web3.provider,
                                  address: tokenAddress)
        
        let allowance = try tokenContract.getAllowance(originalOwner: toAddress,
                                                       delegate: contractAddress)
        
        return allowance > (threshold ?? DefaultEthereumProvider.DefaultThreshold)
    }
}
