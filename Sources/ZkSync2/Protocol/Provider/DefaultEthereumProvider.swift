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
    
    let gasProvider: ContractGasProvider
    
    init(_ web3: web3,
         l1ERC20Bridge: web3.web3contract,
         l1EthBridge: web3.web3contract,
         gasProvider: ContractGasProvider) {
        self.web3 = web3
        self.l1ERC20Bridge = l1ERC20Bridge
        self.l1EthBridge = l1EthBridge
        self.gasProvider = gasProvider
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
            let depositInputs = [
                ABI.Element.InOut(name: "_l2Receiver", type: .address),
                ABI.Element.InOut(name: "_l1Token", type: .address),
                ABI.Element.InOut(name: "_amount", type: .uint(bits: 256))
            ]
            
            let depositFunction: ABI.Element = .function(ABI.Element.Function(name: "deposit",
                                                                              inputs: depositInputs,
                                                                              outputs: [],
                                                                              constant: false,
                                                                              payable: false))
            
            let depositParameters: [AnyObject] = [
                userAddress,
                EthereumAddress.Default,
                amount
            ] as [AnyObject]
            
            guard let encodedFunction = depositFunction.encodeParameters(depositParameters) else {
                fatalError("Encoded deposit function should be valid")
            }
            
#if DEBUG
            print("Encoded deposit function: \(encodedFunction.toHexString().addHexPrefix())")
#endif
            
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.type = .eip1559
            
            let chainID = BigUInt(9) // 9 or 5?
            transactionOptions.chainID = chainID
            let nonce = try! web3.eth.getTransactionCount(address: EthereumAddress("0x7e5f4552091a69125d5dfcb7b8c2659029395bdf")!)
            let noncePolicy: TransactionOptions.NoncePolicy = .manual(nonce)
            transactionOptions.nonce = noncePolicy
            transactionOptions.gasPrice = .manual(gasProvider.gasPrice)
            transactionOptions.gasLimit = .manual(gasProvider.gasLimit)
            transactionOptions.to = userAddress
            
            let value = BigUInt.zero
            transactionOptions.value = value
            transactionOptions.from = EthereumAddress("0x7e5f4552091a69125d5dfcb7b8c2659029395bdf")!
            
            let ethereumParameters = EthereumParameters(from: transactionOptions)
            var ethereumTransaction = EthereumTransaction(type: .eip1559,
                                                          to: userAddress,
                                                          nonce: nonce,
                                                          chainID: chainID,
                                                          value: value,
                                                          data: encodedFunction,
                                                          parameters: ethereumParameters)
            
            print("Transaction hash: \(String(describing: ethereumTransaction.hash?.toHexString().addHexPrefix()))")
            
            let privateKey = Data.fromHex("0x0000000000000000000000000000000000000000000000000000000000000001")!
            try! ethereumTransaction.sign(privateKey: privateKey)
            
            guard let encodedAndSignedTransaction = ethereumTransaction.encode(for: .transaction) else {
                fatalError("Failed to encode transaction.")
            }
            
            print("Encoded and signed transaction: \(encodedAndSignedTransaction.toHexString().addHexPrefix())")
            
            return l1EthBridge.web3.eth.sendRawTransactionPromise(encodedAndSignedTransaction)
        } else {
            let parameters = [
                userAddress,
                token.l1Address,
                amount
            ] as [AnyObject]
            
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.to = userAddress
            
            guard let transaction = l1ERC20Bridge.write("deposit",
                                                        parameters: parameters,
                                                        transactionOptions: transactionOptions) else {
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
}

extension DefaultEthereumProvider {
    
    static func load(_ zkSync: ZkSync,
                     web3: web3,
                     gasProvider: ContractGasProvider) -> Promise<DefaultEthereumProvider> {
        Promise { seal in
            zkSync.zksGetBridgeContracts { result in
                switch result {
                case .success(let bridgeAddresses):
                    let l1ERC20Bridge = web3.contract(Web3.Utils.IL1Bridge,
                                                      at: EthereumAddress(bridgeAddresses.l1Erc20DefaultBridge))!
                    
                    let l1EthBridge = web3.contract(Web3.Utils.IL1Bridge,
                                                    at: EthereumAddress(bridgeAddresses.l1EthDefaultBridge))!
                    
                    let defaultEthereumProvider = DefaultEthereumProvider(web3,
                                                                          l1ERC20Bridge: l1ERC20Bridge,
                                                                          l1EthBridge: l1EthBridge,
                                                                          gasProvider: gasProvider)
                    
                    return seal.resolve(.fulfilled(defaultEthereumProvider))
                case .failure(let error):
                    return seal.resolve(.rejected(error))
                }
            }
        }
    }
}
