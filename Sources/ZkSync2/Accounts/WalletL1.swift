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
    var zkSyncContract: Web3.Contract!//111
    var l1ERC20BridgeAddress: String!//111
    
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
              let spenderAddress = EthereumAddress(l1ERC20BridgeAddress) else {
            throw EthereumProviderError.invalidToken
        }
        
        let tokenContract = ERC20(web3: web,
                                  provider: web.provider,
                                  address: tokenAddress)
        
        let maxApproveAmount = BigUInt.two.power(256) - 1
        let amount = limit?.description ?? maxApproveAmount.description
        
        let transaction = try await tokenContract.approve(from: spenderAddress, spender: spenderAddress, amount: amount)
        return try await transaction.writeToChain(password: "")//444
    }
    
    public func isDepositApproved(with token: Token,
                           to address: String,
                                  threshold: BigUInt?) async throws -> Bool {
        guard let tokenAddress = EthereumAddress(token.l1Address),
              let ownerAddress = EthereumAddress(address),
              let spenderAddress = EthereumAddress(l1ERC20BridgeAddress) else {
            throw EthereumProviderError.invalidToken
        }
        
        let tokenContract = ERC20(web3: web,
                                  provider: web.provider,
                                  address: tokenAddress)
        
        let allowance = try await tokenContract.getAllowance(originalOwner: ownerAddress, delegate: spenderAddress)
        
        return allowance > (threshold ?? BigUInt.two.power(255))
    }
    
    public func mainContract(callback: @escaping ((Web3.Contract) -> Void)) {
        zkSync.mainContract { result in
            switch result {
            case .success(let address):
                let zkSyncContract = self.web.contract(
                    Web3.Utils.IZkSync,
                    at: EthereumAddress(address)
                )!
                
                callback(zkSyncContract)
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    public func balanceL1(token: Token) -> Promise<BigUInt> {
//444        if token.symbol == Token.ETH.symbol {
//            return web.eth.getBalancePromise(address: EthereumAddress(signer.address)!)
//        } else {
//            fatalError("Not supported")
//        }
        Promise<BigUInt> { result in
            result.fulfill(.zero)
        }//444
    }
    
    public func allowanceL1() {
        //111
    }
    
    public func l2TokenAddress() {
        //111
    }
    
    public func approveERC20() {
        //111
    }
    
    public func baseCost(_ gasLimit: BigUInt,
                  gasPerPubdataByte: BigUInt = BigUInt(50000),
                         gasPrice: BigUInt?) async -> Promise<[String: Any]> {
        var gasPrice = gasPrice
        if gasPrice == nil {
            gasPrice = try! await web.eth.gasPrice()
        }
        
        let parameters = [
            gasPrice,
            gasLimit,
            gasPerPubdataByte
        ] as [AnyObject]
        
//444        guard let transaction = zkSyncContract.read("l2TransactionBaseCost",
//                                                    parameters: parameters,
//                                                    transactionOptions: nil) else {
//            return Promise(error: EthereumProviderError.invalidParameter)
//        }
//
//        return transaction.callPromise()
        return Promise<[String: Any]> { result in
            result.fulfill([:])
        }
    }
    
    public func estimateGasDeposit() {
        //111
    }
    
    public func fullRequiredDepositFee() {
        //111
    }
    
    public func finalizeWithdraw() {
        //111
    }
    
    public func isWithdrawFinalized() {
        //111
    }
    
    public func claimFailedDeposit(_ l1BridgeAddress: String,
                            depositSender: String,
                            l1Token: String,
                            l2TxHash: Data,
                            l2BlockNumber: BigUInt,
                            l2MessageIndex: BigUInt,
                            l2TxNumberInBlock: UInt,
                            proof: [Data]) async throws -> TransactionSendingResult {
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

        return try await writeTransaction.writeToChain(password: "")//444
    }

    public func requestExecute(_ contractAddress: String,
                        l2Value: BigUInt,
                        calldata: Data,
                        gasLimit: BigUInt,
                        factoryDeps: [Data]?,
                        operatorTips: BigUInt?,
                        gasPrice: BigUInt?,
                               refundRecipient: String) async throws -> TransactionSendingResult {
        var gasPrice = gasPrice
        if gasPrice == nil {
            gasPrice = try! await web.eth.gasPrice()
        }

        guard let baseCost = try await baseCost(gasLimit, gasPrice: gasPrice).wait()["0"] as? BigUInt else {
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

        guard let writeTransaction = zkSyncContract.createWriteOperation("requestL2Transaction",
                                                     parameters: parameters) else {
            throw EthereumProviderError.invalidParameter
        }
        writeTransaction.transaction.from = EthereumAddress(l1ERC20BridgeAddress)!
        writeTransaction.transaction.to = zkSyncContract.contract.address!
        writeTransaction.transaction.nonce = nonce
        writeTransaction.transaction.gasLimit = gasLimit
        writeTransaction.transaction.gasPrice = gasPrice
        writeTransaction.transaction.maxPriorityFeePerGas = BigUInt(100000000)
        writeTransaction.transaction.value = totalValue
        writeTransaction.transaction.chainID = self.web.provider.network?.chainID

        return try await web.eth.send(writeTransaction.transaction)
    }
    
    public func estimateGasRequestExecute() {
        //111
    }
    
    public func L1BridgeContracts(callback: @escaping ((Result<BridgeAddresses>) -> Void)) {
        zkSync.bridgeContracts { result in
            callback(result)
        }
    }
    
    public func deposit(_ to: String, amount: BigUInt) async throws -> TransactionSendingResult {
        try await deposit(to, amount: amount, token: nil, nonce: nil)
    }

    public func deposit(_ to: String, amount: BigUInt, token: Token) async throws -> TransactionSendingResult {
        try await deposit(to, amount: amount, token: token, nonce: nil)
    }
    
    public func deposit(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) async throws -> TransactionSendingResult {
        let semaphore = DispatchSemaphore(value: 0)

        var zkSyncAddress: String = ""

        zkSync.mainContract { result in
            switch result {
            case .success(let address):
                zkSyncAddress = address
            case .failure(let error):
                fatalError("Failed with error: \(error.localizedDescription)")
            }

            semaphore.signal()
        }

        semaphore.wait()//444

        let zkSyncContract = web.contract(
            Web3.Utils.IZkSync,
            at: EthereumAddress(zkSyncAddress)
        )!

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

//            var transactionOptions = TransactionOptions.defaultOptions
//            transactionOptions.to = EthereumAddress(to)!

            guard let transaction = l1ERC20Bridge.createWriteOperation("deposit",
                                                        parameters: parameters) else {//444 , transactionOptions: transactionOptions
                throw EthereumProviderError.invalidParameter
            }

            return try await transaction.writeToChain(password: "")//444
        }
//444 remove?        let defaultEthereumProvider = DefaultEthereumProvider(
//            web,
//            l1ERC20Bridge: l1ERC20Bridge,
//            zkSyncContract: zkSyncContract
//        )
//
//        return try! defaultEthereumProvider.deposit(
//            with: token ?? Token.ETH,
//            amount: amount,
//            address: to,
//            operatorTips: BigUInt(0)
//        )
    }
}
