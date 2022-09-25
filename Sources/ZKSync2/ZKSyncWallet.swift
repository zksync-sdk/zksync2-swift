//
//  ZKSyncWallet.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
import web3swift
import PromiseKit

class ZKSyncWallet {
    
    let web3: web3
    
    let zkSync: ZKSync
    
    let signer: EthSigner
    
    init(_ web3: web3, zkSync: ZKSync, ethSigner: EthSigner) {
        self.web3 = web3
        self.zkSync = zkSync
        self.signer = ethSigner
    }
    
    func transfer(_ to: String,
                  amount: BigUInt,
                  completion: @escaping (Swift.Result<String, Error>) -> Void) {
        transfer(to,
                 amount: amount,
                 token: nil,
                 nonce: nil,
                 completion: completion)
    }
    
    func transfer(_ to: String,
                  amount: BigUInt,
                  token: Token,
                  completion: @escaping (Swift.Result<String, Error>) -> Void) {
        transfer(to,
                 amount: amount,
                 token: token,
                 nonce: nil,
                 completion: completion)
    }
    
    func transfer(_ to: String,
                  amount: BigUInt,
                  token: Token?,
                  nonce: UInt32?,
                  completion: @escaping (Swift.Result<String, Error>) -> Void) {
        let tokenToUse = token == nil ? Token.ETH : token
        let calldata: String
        let txTo: String
        let txAmount: BigUInt?
        
        guard let tokenToUse = tokenToUse else {
            fatalError("Token should be valid.")
        }
        
        if tokenToUse.isETH {
            calldata = "0x"
            txTo = to
            txAmount = amount
        } else {
            
            txTo = tokenToUse.l2Address
            txAmount = nil
        }
        
        // ABI.Element.Function
    }
    
    func withdraw(_ to: String,
                  amount: BigUInt,
                  completion: @escaping (Swift.Result<String, Error>) -> Void) {
        withdraw(to,
                 amount: amount,
                 token: nil,
                 nonce: nil,
                 completion: completion)
    }
    
    func withdraw(_ to: String,
                  amount: BigUInt,
                  token: Token,
                  completion: @escaping (Swift.Result<String, Error>) -> Void) {
        withdraw(to,
                 amount: amount,
                 token: token,
                 nonce: nil,
                 completion: completion)
    }
    
    func withdraw(_ to: String,
                  amount: BigUInt,
                  token: Token?,
                  nonce: UInt32?,
                  completion: @escaping (Swift.Result<String, Error>) -> Void) {
        let tokenToUse = token == nil ? Token.ETH : token
        let inputs: [ABI.Element.InOut] = [
            ABI.Element.InOut(name: "", type: .address)
        ]
        
        let function = ABI.Element.Function(name: "withdraw",
                                            inputs: inputs,
                                            outputs: [],
                                            constant: false, // Parameter is not present in zksync2-java
                                            payable: false) // Parameter is not present in zksync2-java
        
        let t = ABIEncoder.encodeSingleType(type: .function, value: function as AnyObject)
    }
    
    func deploy(_ bytecode: Data,
                completion: @escaping (Swift.Result<String, Error>) -> Void) {
        deploy(bytecode,
               calldata: nil,
               nonce: nil,
               completion: completion)
    }
    
    func deploy(_ bytecode: Data,
                calldata: Data?,
                completion: @escaping (Swift.Result<String, Error>) -> Void) {
        deploy(bytecode,
               calldata: calldata,
               nonce: nil,
               completion: completion)
    }
    
    func deploy(_ bytecode: Data,
                calldata: Data?,
                nonce: UInt32?,
                completion: @escaping (Swift.Result<String, Error>) -> Void) {
        
    }
    
    func execute(_ contractAddress: String,
                 function: ABI.Element.Function,
                 completion: @escaping (Swift.Result<String, Error>) -> Void) {
        execute(contractAddress,
                function: function,
                nonce: nil,
                completion: completion)
    }
    
    func execute(_ contractAddress: String,
                 function: ABI.Element.Function,
                 nonce: UInt32?,
                 completion: @escaping (Swift.Result<String, Error>) -> Void) {
        
    }
    
    func getBalance() -> BigUInt {
        getBalance(signer.address,
                   token: Token.ETH,
                   at: .committed)
    }
    
    func getBalance(_ token: Token) -> BigUInt {
        getBalance(signer.address,
                   token: token,
                   at: .committed)
    }
    
    func getBalance(_ address: String) -> BigUInt {
        getBalance(address,
                   token: Token.ETH,
                   at: .committed)
    }
    
    func getBalance(_ address: String,
                    token: Token) -> BigUInt {
        getBalance(address,
                   token: token,
                   at: .committed)
    }
    
    func getBalance(_ address: String,
                    token: Token,
                    at: ZkBlockParameterName) -> BigUInt {
        guard let ethereumAddress = EthereumAddress(address),
              let l2EthereumAddress = EthereumAddress(token.l2Address) else {
            fatalError("Tokens are not valid.")
        }
        
        if token.isETH {
            do {
                return try web3.eth.getBalance(address: ethereumAddress,
                                               onBlock: at.rawValue)
            } catch {
                fatalError("Failed to get balance with error: \(error.localizedDescription)")
            }
        } else {
            let erc20 = ERC20(web3: web3,
                              provider: web3.provider,
                              address: l2EthereumAddress)
            
            do {
                return try erc20.getBalance(account: ethereumAddress)
            } catch {
                fatalError("Failed to get ERC20 balance with error: \(error.localizedDescription)")
            }
        }
    }
    
    func getNonce(_ at: ZkBlockParameterName) -> Promise<BigUInt> {
        web3.eth.getTransactionCountPromise(address: signer.address,
                                            onBlock: at.rawValue)
    }
    
    func getNonce() -> Promise<BigUInt> {
        getNonce(.committed)
    }
    
    func estimateAndSend(_ transaction: Transaction, nonce: BigUInt) {
        let chainId = signer.domain.chainId
    }
}
