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
import Web3Core
#else
import web3swift_zksync2
#endif

public class WalletL2: AdapterL2 {
    public let zkSync: ZkSyncClient
    public let ethClient: EthereumClient
    public let web: Web3
    
    public let signer: ETHSigner
    
    public init(_ zkSync: ZkSyncClient, ethClient: EthereumClient, web3: Web3, ethSigner: ETHSigner) {
        self.zkSync = zkSync
        self.ethClient = ethClient
        self.web = web3
        self.signer = ethSigner
    }
}

extension WalletL2 {
    public func balance() {
        //111
    }
    
    public func allBalances() {
        //111
    }
    
    public func l2BridgeContracts() {
        //111
    }
    
    public func withdraw(_ to: String, amount: BigUInt) async -> TransactionSendingResult {
        await withdraw(to, amount: amount, token: nil, nonce: nil)
    }
    
    public func withdraw(_ to: String, amount: BigUInt, token: Token) async -> TransactionSendingResult {
        await withdraw(to, amount: amount, token: token, nonce: nil)
    }
    
    public func withdraw(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) async -> TransactionSendingResult {
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
            nonceToUse = try! await getNonce()
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
            
            var estimate = CodableTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: EthereumAddress.L2EthTokenAddress, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, value: amount, data: calldata)
            
            // TODO: Verify chainID value.
            //444estimate.envelope.parameters.chainID = signer.domain.chainId
            
            return await AccountsUtil.estimateAndSend(zkSync: zkSync, signer: signer, estimate, nonce: nonceToUse)
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
            
            zkSync.bridgeContracts { result in
                switch result {
                case .success(let bridgeAddresses):
                    l2Bridge = bridgeAddresses.l2Erc20DefaultBridge
                case .failure(let error):
                    fatalError("Failed with error: \(error.localizedDescription)")
                }
                
                semaphore.signal()
            }
            
            semaphore.wait()
            
            var estimate = CodableTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: EthereumAddress(l2Bridge)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: calldata)
            
            // TODO: Verify chainID value.
            //444estimate.envelope.parameters.chainID = signer.domain.chainId
            
            return await AccountsUtil.estimateAndSend(zkSync: zkSync, signer: signer, estimate, nonce: nonceToUse)
        }
    }
    
    public func callContract(_ transaction: CodableTransaction, blockNumber: BigUInt?, completion: @escaping (Result<Data>) -> Void) async {
        await ethClient.callContract(transaction, blockNumber: blockNumber, completion: completion)
    }
    
    public func populateTransaction(_ transaction: inout CodableTransaction) {
        //111
    }
    
    public func sendTransaction(_ transaction: CodableTransaction, completion: @escaping (Result<TransactionSendingResult>) -> Void) {
        ethClient.sendTransaction(transaction, completion: completion)
    }
    
    public func signTransaction(_ transaction: inout CodableTransaction) {
//444        let signature = signer.signTypedData(signer.domain, typedData: transaction).addHexPrefix()
//
//        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
//        transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
//        transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
//        transaction.envelope.v = BigUInt(unmarshalledSignature.v)
    }
    
    public func estimateGasWithdraw(_ transaction: CodableTransaction) -> Promise<BigUInt> {
        return zkSync.estimateGasTransfer(transaction)
    }
    
    public func estimateGasTransfer(_ transaction: CodableTransaction) -> Promise<BigUInt> {
        return zkSync.estimateGasTransfer(transaction)
    }
}

extension WalletL2 {
    public func transfer(_ to: String, amount: BigUInt) async -> TransactionSendingResult {
        await transfer(to, amount: amount, token: nil, nonce: nil)
    }
    
    public func transfer(_ to: String, amount: BigUInt, token: Token) async -> TransactionSendingResult {
        await transfer(to, amount: amount, token: token, nonce: nil)
    }
    
    public func transfer(_ to: String, amount: BigUInt, token: Token?, nonce: BigUInt?) async -> TransactionSendingResult {
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
            nonceToUse = try! await getNonce()
        }
        
        var estimate = CodableTransaction.createFunctionCallTransaction(from: from, to: to, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, value: txAmount, data: calldata)
        
        // TODO: Verify chainID value.
        //444estimate.envelope.parameters.chainID = signer.domain.chainId
        
        return await AccountsUtil.estimateAndSend(zkSync: zkSync, signer: signer, estimate, nonce: nonceToUse)
    }
}

extension WalletL2 {
    public func execute(_ contractAddress: String, encodedFunction: Data) async -> TransactionSendingResult {
        await execute(contractAddress, encodedFunction: encodedFunction, nonce: nil)
    }
    
    public func execute(_ contractAddress: String, encodedFunction: Data, nonce: BigUInt?) async -> TransactionSendingResult {
        let nonceToUse: BigUInt
        if let nonce = nonce {
            nonceToUse = nonce
        } else {
            nonceToUse = try! await getNonce()
        }
        
        // TODO: Validate calldata.
        
        let estimate = CodableTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: EthereumAddress(contractAddress)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: encodedFunction)
        
        return await AccountsUtil.estimateAndSend(zkSync: zkSync, signer: signer, estimate, nonce: nonceToUse)
    }
    
    public func getBalance() async throws -> BigUInt {
        try await getBalance(signer.address, token: Token.ETH, at: .latest)
    }
    
    public func getBalance(_ token: Token) async throws -> BigUInt {
        try await getBalance(signer.address, token: token, at: .latest)
    }
    
    public func getBalance(_ address: String) async throws -> BigUInt {
        try await getBalance(address, token: Token.ETH, at: .latest)
    }
    
    public func getBalance(_ address: String, token: Token) async throws -> BigUInt {
        try await getBalance(address, token: token, at: .latest)
    }
    
    public func getBalance(_ address: String, token: Token, at block: BlockNumber) async throws -> BigUInt {
        guard let ethereumAddress = EthereumAddress(address),
              let l2EthereumAddress = EthereumAddress(token.l2Address) else {
            fatalError("Tokens are not valid.")
        }

        if token.isETH {
            return try await zkSync.web3.eth.getBalance(for: ethereumAddress, onBlock: block)
        } else {
            let erc20 = ERC20(web3: zkSync.web3,
                              provider: zkSync.web3.provider,
                              address: l2EthereumAddress)

            return try await erc20.getBalance(account: ethereumAddress)
        }
    }
    
    public func getNonce(at block: BlockNumber) async throws -> BigUInt {
        try await zkSync.web3.eth.getTransactionCount(for: EthereumAddress(signer.address)!, onBlock: block)
    }
    
    public func getNonce() async throws -> BigUInt {
        try await getNonce(at: .latest)
    }
}
