//
//  WalletL1.swift
//  zkSync-Demo
//
//  Created by Bojan on 1.9.23..
//

import Foundation
import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

enum EthereumProviderError: Error {
    case invalidAddress
    case invalidToken
    case invalidParameter
    case internalError
}

public class WalletL1: AdapterL1 {
    public let zkSync: ZkSyncClient
    public let ethClient: EthereumClient
    public let web: Web3
    
    fileprivate func l1ERC20BridgeAddress() async throws -> EthereumAddress? {
        let bridgeAddresses = try await zkSync.bridgeContracts()
        
        let erc20Bridge = web.contract(Web3.Utils.IL1Bridge, at: EthereumAddress(bridgeAddresses.l1Erc20DefaultBridge))
        
        return erc20Bridge?.contract.address
    }
    
    public let signer: ETHSigner
    
    public init(_ zkSync: ZkSyncClient, ethClient: EthereumClient, web3: Web3, ethSigner: ETHSigner) {
        self.zkSync = zkSync
        self.ethClient = ethClient
        self.web = web3
        self.signer = ethSigner
    }
}

extension WalletL1 {
    public func approveDeposit(with token: Token,
                               limit: BigUInt?) async throws -> TransactionSendingResult {
        guard let tokenAddress = EthereumAddress(token.l1Address),
              let spenderAddress = try await l1ERC20BridgeAddress() else {
            throw EthereumProviderError.invalidToken
        }
        
        let tokenContract = ERC20(web3: web,
                                  provider: web.provider,
                                  address: tokenAddress)
        
        let maxApproveAmount = BigUInt.two.power(256) - 1
        let amount = limit?.description ?? maxApproveAmount.description
        
        let transaction = try await tokenContract.approve(from: spenderAddress, spender: spenderAddress, amount: amount)
        return try await web.eth.send(transaction.transaction)
    }
    
    public func isDepositApproved(with token: Token,
                           to address: String,
                                  threshold: BigUInt?) async throws -> Bool {
        guard let tokenAddress = EthereumAddress(token.l1Address),
              let ownerAddress = EthereumAddress(address),
              let spenderAddress = try await l1ERC20BridgeAddress() else {
            throw EthereumProviderError.invalidToken
        }
        
        let tokenContract = ERC20(web3: web,
                                  provider: web.provider,
                                  address: tokenAddress)
        
        let allowance = try await tokenContract.getAllowance(originalOwner: ownerAddress, delegate: spenderAddress)
        
        return allowance > (threshold ?? BigUInt.two.power(255))
    }
    
    public func mainContract() async throws -> Web3.Contract {
        let address = try await self.zkSync.mainContract()
        
        let zkSyncContract = self.web.contract(
            Web3.Utils.IZkSync,
            at: EthereumAddress(address)
        )!
        
        return zkSyncContract
    }
    
    public func balanceL1(token: Token) async -> BigUInt {
        if token.symbol == Token.ETH.symbol {
            return try! await web.eth.getBalance(for: EthereumAddress(signer.address)!)
        } else {
            fatalError("Not supported")
        }
    }
    
    public func baseCost(_ gasLimit: BigUInt, gasPerPubdataByte: BigUInt = BigUInt(50000), gasPrice: BigUInt?) async throws -> [String: Any] {
        var gasPrice = gasPrice
        if gasPrice == nil {
            gasPrice = try! await web.eth.gasPrice()
        }
        
        let parameters = [
            gasPrice,
            gasLimit,
            gasPerPubdataByte
        ] as [AnyObject]
        
        guard let transaction = try await mainContract().createReadOperation("l2TransactionBaseCost", parameters: parameters) else {
            throw EthereumProviderError.invalidParameter
        }

        return try await transaction.callContractMethod()
    }
    
    public func claimFailedDeposit(_ l1BridgeAddress: String, depositSender: String, l1Token: String, l2TxHash: Data, l2BlockNumber: BigUInt, l2MessageIndex: BigUInt, l2TxNumberInBlock: UInt, proof: [Data]) async throws -> TransactionSendingResult {
        let l1Bridge = web.contract(Web3.Utils.IL1Bridge, at: EthereumAddress(l1BridgeAddress))!

        let parameters = [
            depositSender,
            l1Token,
            l2TxHash,
            l2BlockNumber,
            l2MessageIndex,
            l2TxNumberInBlock,
            proof
        ] as [AnyObject]

        guard let writeTransaction = l1Bridge.createWriteOperation("claimFailedDeposit",
                                                    parameters: parameters) else {
            throw EthereumProviderError.invalidParameter
        }

        guard let encodedTransaction = writeTransaction.transaction.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }

        print("Encoded transaction: \(encodedTransaction.toHexString().addHexPrefix())")

        return try await web.eth.send(writeTransaction.transaction)
    }

    public func requestExecute(_ contractAddress: String, l2Value: BigUInt, calldata: Data, gasLimit: BigUInt, factoryDeps: [Data]?, operatorTips: BigUInt?, gasPrice: BigUInt?, refundRecipient: String) async throws -> TransactionSendingResult {
        var gasPrice = gasPrice
        if gasPrice == nil {
            gasPrice = try! await web.eth.gasPrice()
        }

        guard let baseCost = try await baseCost(gasLimit, gasPrice: gasPrice)["0"] as? BigUInt else {
            throw EthereumProviderError.invalidParameter
        }

        let l1ToL2GasPerPubData = BigUInt(800)

        var parameters = [
            EthereumAddress(contractAddress)!,
            l2Value,
            calldata,
            gasLimit,
            l1ToL2GasPerPubData
        ] as [AnyObject]

        let bytesArr: [Data] = factoryDeps?.compactMap({ $0 }) ?? []
        parameters.append(bytesArr as AnyObject)

        parameters.append(EthereumAddress(contractAddress)! as AnyObject)

        let operatorTipsValue: BigUInt
        if let operatorTips = operatorTips {
            operatorTipsValue = operatorTips
        } else {
            operatorTipsValue = BigUInt.zero
        }

        let totalValue = l2Value + baseCost + operatorTipsValue

        let nonce = try! await self.web.eth.getTransactionCount(for: EthereumAddress(contractAddress)!)

        guard let writeTransaction = try await mainContract().createWriteOperation("requestL2Transaction",
                                                     parameters: parameters) else {
            throw EthereumProviderError.invalidParameter
        }
        writeTransaction.transaction.from = try await l1ERC20BridgeAddress()
        writeTransaction.transaction.to = try await mainContract().contract.address!
        writeTransaction.transaction.nonce = nonce
        writeTransaction.transaction.gasLimit = gasLimit
        writeTransaction.transaction.gasPrice = gasPrice
        writeTransaction.transaction.maxPriorityFeePerGas = BigUInt(100000000)
        writeTransaction.transaction.value = totalValue
        writeTransaction.transaction.chainID = self.web.provider.network?.chainID

        return try await web.eth.send(writeTransaction.transaction)
    }
    
    public func L1BridgeContracts() async throws -> BridgeAddresses {
        try await self.zkSync.bridgeContracts()
    }
    
    public func deposit(_ to: String, amount: BigUInt, token: Token? = nil, nonce: BigUInt? = nil) async throws -> TransactionSendingResult {
        let l1ERC20Bridge = zkSync.web3.contract(
            Web3.Utils.IL1Bridge,
            at: EthereumAddress(signer.address)
        )!

        let operatorTips = BigUInt.zero

        if token?.isETH == true {
            let gasLimit = BigUInt(10000000)

            return try await requestExecute(to,
                                      l2Value: amount,
                                      calldata: Data(),
                                      gasLimit: gasLimit,
                                      factoryDeps: nil,
                                      operatorTips: operatorTips,
                                      gasPrice: nil,
                                      refundRecipient: to)
        } else {
            let baseCost = BigUInt.zero
            let gasLimit = BigUInt(300000)
            let totalAmount = operatorTips + baseCost

            let l1ToL2GasPerPubData = BigUInt(800)

            let parameters = [
                to,
                token?.l1Address as Any,
                gasLimit,
                l1ToL2GasPerPubData,
                amount,
                totalAmount
            ] as [AnyObject]

            guard let writeTransaction = l1ERC20Bridge.createWriteOperation("deposit",
                                                        parameters: parameters) else {
                throw EthereumProviderError.invalidParameter
            }
            writeTransaction.transaction.to = EthereumAddress(to)!

            return try await web.eth.send(writeTransaction.transaction)
        }
    }
}
