//
//  ZkSyncWallet.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
import web3swift
import PromiseKit

public class ZKSyncWallet {
    
    let zkSync: ZkSync
    
    let signer: EthSigner
    
    let feeProvider: ZkTransactionFeeProvider
    
    init(_ zkSync: ZkSync, ethSigner: EthSigner, feeProvider: ZkTransactionFeeProvider) {
        self.zkSync = zkSync
        self.signer = ethSigner
        self.feeProvider = DefaultTransactionFeeProvider(zkSync: zkSync, feeToken: Token.ETH)
    }
    
    init(_ zkSync: ZkSync, ethSigner: EthSigner, feeToken: Token) {
        self.zkSync = zkSync
        self.signer = ethSigner
        self.feeProvider = DefaultTransactionFeeProvider(zkSync: zkSync, feeToken: feeToken)
    }
    
    func transfer(_ to: String,
                  amount: BigUInt) -> Promise<TransactionSendingResult> {
        transfer(to,
                 amount: amount,
                 token: nil,
                 nonce: nil)
    }
    
    func transfer(_ to: String,
                  amount: BigUInt,
                  token: Token) -> Promise<TransactionSendingResult> {
        transfer(to,
                 amount: amount,
                 token: token,
                 nonce: nil)
    }
    
    func transfer(_ to: String,
                  amount: BigUInt,
                  token: Token?,
                  nonce: BigUInt?) -> Promise<TransactionSendingResult> {
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
            print("Calldata: \(calldata.toHexString().addHexPrefix())")
            
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
        
        var estimate = EthereumTransaction.createFunctionCallTransaction(from: from,
                                                                         to: to,
                                                                         ergsPrice: BigUInt.zero,
                                                                         ergsLimit: BigUInt.zero,
                                                                         value: txAmount,
                                                                         data: calldata)
        
        // TODO: Verify chainID value.
        estimate.envelope.parameters.chainID = signer.domain.chainId
        
        return estimateAndSend(estimate, nonce: nonceToUse)
    }
    
    func withdraw(_ to: String,
                  amount: BigUInt) -> Promise<TransactionSendingResult> {
        withdraw(to,
                 amount: amount,
                 token: nil,
                 nonce: nil)
    }
    
    func withdraw(_ to: String,
                  amount: BigUInt,
                  token: Token) -> Promise<TransactionSendingResult> {
        withdraw(to,
                 amount: amount,
                 token: token,
                 nonce: nil)
    }
    
    func withdraw(_ to: String,
                  amount: BigUInt,
                  token: Token?,
                  nonce: BigUInt?) -> Promise<TransactionSendingResult> {
        let tokenToUse: Token
        if let token = token {
            tokenToUse = token
        } else {
            tokenToUse = Token.ETH
        }
        
        let inputs = [
            ABI.Element.InOut(name: "_l1Receiver", type: .address),
            ABI.Element.InOut(name: "_l2Token", type: .address),
            ABI.Element.InOut(name: "_amount", type: .uint(bits: 256))
        ]
        
        let function = ABI.Element.Function(name: "withdraw",
                                            inputs: inputs,
                                            outputs: [],
                                            constant: false,
                                            payable: false)
        
        let elementFunction: ABI.Element = .function(function)
        
        let parameters: [AnyObject] = [
            EthereumAddress(to) as AnyObject,
            EthereumAddress(tokenToUse.l2Address) as AnyObject,
            amount as AnyObject
        ]
        
        // TODO: Verify calldata.
        let calldata = elementFunction.encodeParameters(parameters)!
        
        let nonceToUse: BigUInt
        if let nonce = nonce {
            nonceToUse = nonce
        } else {
            nonceToUse = try! getNonce()
        }
        
        var l2Bridge: String = ""
        
        let semaphore = DispatchSemaphore(value: 0)
        
        if tokenToUse.isETH {
            zkSync.zksGetBridgeContracts { result in
                switch result {
                case .success(let bridgeAddresses):
                    l2Bridge = bridgeAddresses.l2EthDefaultBridge
                case .failure(let error):
                    fatalError("Failed with error: \(error.localizedDescription)")
                }
                
                semaphore.signal()
            }
        } else {
            zkSync.zksGetBridgeContracts { result in
                switch result {
                case .success(let bridgeAddresses):
                    l2Bridge = bridgeAddresses.l2Erc20DefaultBridge
                case .failure(let error):
                    fatalError("Failed with error: \(error.localizedDescription)")
                }
                
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        
        var estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!,
                                                                         to: EthereumAddress(l2Bridge)!,
                                                                         ergsPrice: BigUInt.zero,
                                                                         ergsLimit: BigUInt.zero,
                                                                         data: calldata)
        
        // TODO: Verify chainID value.
        estimate.envelope.parameters.chainID = signer.domain.chainId
        
        return estimateAndSend(estimate, nonce: nonceToUse)
    }
    
    func deploy(_ bytecode: Data) -> Promise<TransactionSendingResult> {
        deploy(bytecode,
               calldata: nil,
               nonce: nil)
    }
    
    func deploy(_ bytecode: Data,
                calldata: Data?) -> Promise<TransactionSendingResult> {
        deploy(bytecode,
               calldata: calldata,
               nonce: nil)
    }
    
    func deploy(_ bytecode: Data,
                calldata: Data?,
                nonce: BigUInt?) -> Promise<TransactionSendingResult> {
        let nonceToUse: BigUInt
        if let nonce = nonce {
            nonceToUse = nonce
        } else {
            nonceToUse = try! getNonce()
        }
        
        let validCalldata: Data
        if let calldata = calldata {
            validCalldata = calldata
        } else {
            validCalldata = Data(hex: "0x")
        }
        
        let estimate = EthereumTransaction.create2ContractTransaction(from: EthereumAddress(signer.address)!,
                                                                      ergsPrice: BigUInt.zero,
                                                                      ergsLimit: BigUInt.zero,
                                                                      bytecode: bytecode,
                                                                      calldata: validCalldata)
        
        return estimateAndSend(estimate, nonce: nonceToUse)
    }
    
    func execute(_ contractAddress: String,
                 functionElement: ABI.Element,
                 parameters: [AnyObject]) -> Promise<TransactionSendingResult> {
        execute(contractAddress,
                function: functionElement,
                parameters: parameters,
                nonce: nil)
    }
    
    func execute(_ contractAddress: String,
                 `function`: ABI.Element,
                 parameters: [AnyObject],
                 nonce: BigUInt?) -> Promise<TransactionSendingResult> {
        guard case .function(_) = function else {
            fatalError("Element should have function type.")
        }
        
        let nonceToUse: BigUInt
        if let nonce = nonce {
            nonceToUse = nonce
        } else {
            nonceToUse = try! getNonce()
        }
        
        guard let calldata = function.encodeParameters(parameters) else {
            fatalError("Failed to encode parameters.")
        }
        
        // TODO: Validate calldata.
        
        let estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!,
                                                                         to: EthereumAddress(contractAddress)!,
                                                                         ergsPrice: BigUInt.zero,
                                                                         ergsLimit: BigUInt.zero,
                                                                         data: calldata)
        
        return estimateAndSend(estimate, nonce: nonceToUse)
    }
    
    func getBalance() -> Promise<BigUInt> {
        getBalance(signer.address,
                   token: Token.ETH,
                   at: .committed)
    }
    
    func getBalance(_ token: Token) -> Promise<BigUInt> {
        getBalance(signer.address,
                   token: token,
                   at: .committed)
    }
    
    func getBalance(_ address: String) -> Promise<BigUInt> {
        getBalance(address,
                   token: Token.ETH,
                   at: .committed)
    }
    
    func getBalance(_ address: String,
                    token: Token) -> Promise<BigUInt> {
        getBalance(address,
                   token: token,
                   at: .committed)
    }
    
    func getBalance(_ address: String,
                    token: Token,
                    at: ZkBlockParameterName) -> Promise<BigUInt> {
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
    
    func getNonce(_ at: ZkBlockParameterName) -> Promise<BigUInt> {
        zkSync.web3.eth.getTransactionCountPromise(address: signer.address,
                                                   onBlock: at.rawValue)
    }
    
    func getNonce() throws -> BigUInt {
        try getNonce(.committed).wait()
    }
    
    func getNonce() -> Promise<BigUInt> {
        getNonce(.committed)
    }
    
    func estimateAndSend(_ transaction: EthereumTransaction, nonce: BigUInt) -> Promise<TransactionSendingResult> {
        let chainID = signer.domain.chainId
        let gas = try! feeProvider.getGasLimit(for: transaction).wait()
        let gasPrice = feeProvider.gasPrice
    
#if DEBUG
        print("chainID: \(chainID)")
        print("gas: \(gas)")
        print("gasPrice: \(gasPrice)")
#endif
    
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.chainID = chainID
        transactionOptions.nonce = .manual(nonce)
        transactionOptions.gasLimit = .manual(gas)
        transactionOptions.to = transaction.to
        transactionOptions.value = transaction.value
        transactionOptions.maxPriorityFeePerGas = .manual(BigUInt(100000000))
        transactionOptions.maxFeePerGas = .manual(gasPrice)
        transactionOptions.from = transaction.parameters.from
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        ethereumParameters.EIP712Meta = (transaction.envelope as! EIP712Envelope).EIP712Meta
        ethereumParameters.from = transaction.parameters.from
        
        var prepared = EthereumTransaction(type: .eip712,
                                           to: transaction.to,
                                           nonce: nonce,
                                           chainID: chainID,
                                           value: transaction.value,
                                           data: transaction.data,
                                           parameters: ethereumParameters)
        
        print("Transaction hash: \(String(describing: prepared.hash?.toHexString().addHexPrefix()))")
        
        let domain = signer.domain
        let signature = signer.signTypedData(domain, typedData: prepared)
        
        print("Signature: \(signature))")
        
        let unmarshalledSignature: SECP256K1.UnmarshaledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
        prepared.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
        prepared.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
        prepared.envelope.v = BigUInt(unmarshalledSignature.v)
        
        guard let message = transaction.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }
        
        print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
        
        return zkSync.web3.eth.sendRawTransactionPromise(transaction)
    }
}
