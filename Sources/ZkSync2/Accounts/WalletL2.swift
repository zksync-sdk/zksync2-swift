//
//  WalletL2.swift
//  zkSync-Demo
//
//  Created by Bojan on 1.9.23..
//

import Foundation
import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

public class WalletL2: AdapterL2 {
    public let zkSync: ZkSyncClient
    public let web: web3
    
    public let signer: ETHSigner
    
    public init(_ zkSync: ZkSyncClient, web3: web3, ethSigner: ETHSigner) {
        self.zkSync = zkSync
        self.web = web3
        self.signer = ethSigner
    }
}

extension WalletL2 {
    public func withdraw(_ to: String, amount: BigUInt) -> Promise<TransactionSendingResult> {
        withdraw(to, amount: amount, token: nil, nonce: nil)
    }
    
    public func withdraw(_ to: String, amount: BigUInt, token: Token) -> Promise<TransactionSendingResult> {
        withdraw(to, amount: amount, token: token, nonce: nil)
    }
    
    public func withdraw(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) -> Promise<TransactionSendingResult> {
        let tokenToUse: Token
        if let token = token {
            tokenToUse = token
        } else {
            tokenToUse = Token.ETH
        }
        
        let nonceToUse: BigUInt
        if let nonce = nonce {
            nonceToUse = nonce
        } else {
            nonceToUse = try! getNonce()
        }
        
        if tokenToUse.isETH {
            let inputs = [
                ABI.Element.InOut(name: "_l1Receiver", type: .address)
            ]
            
            let function = ABI.Element.Function(name: "withdraw",
                                                inputs: inputs,
                                                outputs: [],
                                                constant: false,
                                                payable: true)
            
            let withdrawFunction: ABI.Element = .function(function)
            
            let parameters: [AnyObject] = [
                EthereumAddress(to) as AnyObject,
            ]
            
            // TODO: Verify calldata.
            let calldata = withdrawFunction.encodeParameters(parameters)!
            
            var estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: EthereumAddress.L2EthTokenAddress, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, value: amount, data: calldata)
            
            // TODO: Verify chainID value.
            estimate.envelope.parameters.chainID = signer.domain.chainId
            
            return AccountsUtil.estimateAndSend(zkSync: zkSync, signer: signer, estimate, nonce: nonceToUse)
        } else {
            let inputs = [
                ABI.Element.InOut(name: "_l1Receiver", type: .address),
                ABI.Element.InOut(name: "_l2Token", type: .address),
                ABI.Element.InOut(name: "_amount", type: .uint(bits: 256))
            ]
            
            let function = ABI.Element.Function(name: "withdraw",
                                                inputs: inputs,
                                                outputs: [],
                                                constant: false,
                                                payable: true)
            
            let withdrawFunction: ABI.Element = .function(function)
            
            let parameters: [AnyObject] = [
                EthereumAddress(to) as AnyObject,
                EthereumAddress(tokenToUse.l2Address) as AnyObject,
                amount as AnyObject
            ]
            
            // TODO: Verify calldata.
            let calldata = withdrawFunction.encodeParameters(parameters)!
            
            var l2Bridge: String = ""
            
            let semaphore = DispatchSemaphore(value: 0)
            
            zkSync.getBridgeContracts { result in
                switch result {
                case .success(let bridgeAddresses):
                    l2Bridge = bridgeAddresses.l2Erc20DefaultBridge
                case .failure(let error):
                    fatalError("Failed with error: \(error.localizedDescription)")
                }
                
                semaphore.signal()
            }
            
            semaphore.wait()
            
            var estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: EthereumAddress(l2Bridge)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: calldata)
            
            // TODO: Verify chainID value.
            estimate.envelope.parameters.chainID = signer.domain.chainId
            
            return AccountsUtil.estimateAndSend(zkSync: zkSync, signer: signer, estimate, nonce: nonceToUse)
        }
    }
}

extension WalletL2 {
    public func transfer(_ to: String, amount: BigUInt) -> Promise<TransactionSendingResult> {
        transfer(to, amount: amount, token: nil, nonce: nil)
    }
    
    public func transfer(_ to: String, amount: BigUInt, token: Token) -> Promise<TransactionSendingResult> {
        transfer(to, amount: amount, token: token, nonce: nil)
    }
    
    public func transfer(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) -> Promise<TransactionSendingResult> {
        let tokenToUse: Token
        if let token = token {
            tokenToUse = token
        } else {
            tokenToUse = Token.ETH
        }
        
        let calldata: Data
        let txTo: String
        let txAmount: BigUInt?
        
        if tokenToUse.isETH {
            calldata = Data(hex: "0x")
            txTo = to
            txAmount = amount
        } else {
            let inputs = [
                ABI.Element.InOut(name: "_to", type: .address),
                ABI.Element.InOut(name: "_amount", type: .uint(bits: 256))
            ]
            
            let function = ABI.Element.Function(name: "transfer",
                                                inputs: inputs,
                                                outputs: [],
                                                constant: false,
                                                payable: false)
            
            let elementFunction: ABI.Element = .function(function)
            
            let parameters: [AnyObject] = [
                EthereumAddress(to) as AnyObject,
                amount as AnyObject
            ]
            
            guard let encodedCallData = elementFunction.encodeParameters(parameters) else {
                fatalError("Failed to encode function.")
            }
            
            // TODO: Verify calldata.
            calldata = encodedCallData
            
#if DEBUG
            print("Calldata: \(calldata.toHexString().addHexPrefix())")
#endif
            
            txTo = tokenToUse.l2Address
            txAmount = nil
        }
        
        let from = EthereumAddress(signer.address)!
        let to = EthereumAddress(txTo)!
        
        let nonceToUse: BigUInt
        if let nonce = nonce {
            nonceToUse = nonce
        } else {
            nonceToUse = try! getNonce()
        }
        
        var estimate = EthereumTransaction.createFunctionCallTransaction(from: from, to: to, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, value: txAmount, data: calldata)
        
        // TODO: Verify chainID value.
        estimate.envelope.parameters.chainID = signer.domain.chainId
        
        return AccountsUtil.estimateAndSend(zkSync: zkSync, signer: signer, estimate, nonce: nonceToUse)
    }
}

extension WalletL2 {
    public func execute(_ contractAddress: String, encodedFunction: Data) -> Promise<TransactionSendingResult> {
        execute(contractAddress, encodedFunction: encodedFunction, nonce: nil)
    }
    
    public func execute(_ contractAddress: String, encodedFunction: Data, nonce: BigUInt?) -> Promise<TransactionSendingResult> {
        let nonceToUse: BigUInt
        if let nonce = nonce {
            nonceToUse = nonce
        } else {
            nonceToUse = try! getNonce()
        }
        
        // TODO: Validate calldata.
        
        let estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: EthereumAddress(contractAddress)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: encodedFunction)
        
        return AccountsUtil.estimateAndSend(zkSync: zkSync, signer: signer, estimate, nonce: nonceToUse)
    }
    
    public func getBalance() -> Promise<BigUInt> {
        getBalance(signer.address, token: Token.ETH, at: .committed)
    }
    
    public func getBalance(_ token: Token) -> Promise<BigUInt> {
        getBalance(signer.address, token: token, at: .committed)
    }
    
    public func getBalance(_ address: String) -> Promise<BigUInt> {
        getBalance(address, token: Token.ETH, at: .committed)
    }
    
    public func getBalance(_ address: String, token: Token) -> Promise<BigUInt> {
        getBalance(address, token: token, at: .committed)
    }
    
    public func getBalance(_ address: String, token: Token, at: ZkBlockParameterName) -> Promise<BigUInt> {
        guard let ethereumAddress = EthereumAddress(address),
              let l2EthereumAddress = EthereumAddress(token.l2Address) else {
            fatalError("Tokens are not valid.")
        }
        
        if token.isETH {
            return zkSync.web3.eth.getBalancePromise(address: ethereumAddress,
                                                     onBlock: at.rawValue)
        } else {
            let erc20 = ERC20(web3: zkSync.web3,
                              provider: zkSync.web3.provider,
                              address: l2EthereumAddress)
            
            let balance = try! erc20.getBalance(account: ethereumAddress)
            
            return Promise {
                $0.fulfill(balance)
            }
        }
    }
    
    public func getNonce(_ at: ZkBlockParameterName) -> Promise<BigUInt> {
        zkSync.web3.eth.getTransactionCountPromise(address: signer.address, onBlock: at.rawValue)
    }
    
    public func getNonce() throws -> BigUInt {
        try getNonce(.committed).wait()
    }
    
    public func getNonce() -> Promise<BigUInt> {
        getNonce(.committed)
    }
}
