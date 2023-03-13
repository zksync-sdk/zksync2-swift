//
//  ZkSyncWallet.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

public class ZkSyncWallet {
    
    public let zkSync: ZkSync
    public let ethereum: web3
    
    public let signer: EthSigner
    
    // FIXME: Is fee provider still needed?
    let feeProvider: ZkTransactionFeeProvider
    
    public init(_ zkSync: ZkSync, ethereum: web3, ethSigner: EthSigner, feeToken: Token) {
        self.zkSync = zkSync
        self.ethereum = ethereum
        self.signer = ethSigner
        self.feeProvider = DefaultTransactionFeeProvider(zkSync: zkSync, feeToken: feeToken)
    }
    
    public init(_ zkSync: ZkSync, ethereum: web3, ethSigner: EthSigner, feeProvider: ZkTransactionFeeProvider) {
        self.zkSync = zkSync
        self.ethereum = ethereum
        self.signer = ethSigner
        self.feeProvider = DefaultTransactionFeeProvider(zkSync: zkSync, feeToken: Token.ETH)
    }
    
    /// Transfer coins.
    ///
    /// - Parameters:
    ///   - to: Receiver address.
    ///   - amount: Amount of funds to be transferred in minimal denomination (in Wei).
    /// - Returns: Prepared remote call of transaction.
    public func transfer(_ to: String,
                         amount: BigUInt) -> Promise<TransactionSendingResult> {
        transfer(to,
                 amount: amount,
                 token: nil,
                 nonce: nil)
    }
    
    /// Transfer coins or tokens.
    ///
    /// - Parameters:
    ///   - to: Receiver address.
    ///   - amount: Amount of funds to be transferred in minimal denomination.
    ///   - token: Token object supported by ZkSync.
    /// - Returns: Prepared remote call of transaction.
    public func transfer(_ to: String,
                         amount: BigUInt,
                         token: Token) -> Promise<TransactionSendingResult> {
        transfer(to,
                 amount: amount,
                 token: token,
                 nonce: nil)
    }
    
    /// Transfer coins or tokens.
    ///
    /// - Parameters:
    ///   - to: Receiver address.
    ///   - amount: Amount of funds to be transferred in minimal denomination.
    ///   - token: Token object supported by ZkSync.
    ///   - nonce: Custom nonce value of the wallet.
    /// - Returns: Prepared remote call of transaction.
    public func transfer(_ to: String,
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
        
        return estimateAndSend(estimate, nonce: nonceToUse)
    }
    
    public func deposit(_ to: String,
                         amount: BigUInt) -> Promise<TransactionSendingResult> {
        deposit(to,
                 amount: amount,
                 token: nil,
                 nonce: nil)
    }
    
    public func deposit(_ to: String,
                         amount: BigUInt,
                         token: Token) -> Promise<TransactionSendingResult> {
        deposit(to,
                 amount: amount,
                 token: token,
                 nonce: nil)
    }
    
    public func deposit(_ to: String,
                         amount: BigUInt,
                         token: Token?,
                         nonce: BigUInt?) -> Promise<TransactionSendingResult> {
        let semaphore = DispatchSemaphore(value: 0)
        
        var zkSyncAddress: String = ""
        
        zkSync.zksMainContract { result in
            switch result {
            case .success(let address):
                zkSyncAddress = address
            case .failure(let error):
                fatalError("Failed with error: \(error.localizedDescription)")
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        let zkSyncContract = ethereum.contract(
            Web3.Utils.IZkSync,
            at: EthereumAddress(zkSyncAddress)
        )!
        
        let l1ERC20Bridge = zkSync.web3.contract(
            Web3.Utils.IL1Bridge,
            at: EthereumAddress(signer.address)
        )!
        
        let defaultEthereumProvider = DefaultEthereumProvider(
            ethereum,
            l1ERC20Bridge: l1ERC20Bridge,
            zkSyncContract: zkSyncContract,
            gasProvider: DefaultGasProvider()
        )
        
        return try! defaultEthereumProvider.deposit(
            with: token ?? Token.ETH,
            amount: amount,
            operatorTips: BigUInt(0),
            to: to
        )
    }
    
    /// Withdraw native coins to L1 chain.
    ///
    /// - Parameters:
    ///   - to: Address of the wallet in L1 to that funds will be withdrawn.
    ///   - amount: Amount of the funds to be withdrawn.
    /// - Returns: Prepared remote call of transaction.
    public func withdraw(_ to: String,
                         amount: BigUInt) -> Promise<TransactionSendingResult> {
        withdraw(to,
                 amount: amount,
                 token: nil,
                 nonce: nil)
    }
    
    /// Withdraw native coins or tokens to L1 chain.
    ///
    /// - Parameters:
    ///   - to: Address of the wallet in L1 to that funds will be withdrawn.
    ///   - amount: Amount of the funds to be withdrawn.
    ///   - token: Token object supported by ZkSync.
    /// - Returns: Prepared remote call of transaction.
    public func withdraw(_ to: String,
                         amount: BigUInt,
                         token: Token) -> Promise<TransactionSendingResult> {
        withdraw(to,
                 amount: amount,
                 token: token,
                 nonce: nil)
    }
    
    /// Withdraw native coins to L1 chain.
    ///
    /// - Parameters:
    ///   - to: Address of the wallet in L1 to that funds will be withdrawn.
    ///   - amount: Amount of the funds to be withdrawn.
    ///   - token: Token object supported by ZkSync.
    ///   - nonce: Custom nonce value of the wallet.
    /// - Returns: Prepared remote call of transaction.
    public func withdraw(_ to: String,
                         amount: BigUInt,
                         token: Token?,
                         nonce: BigUInt?) -> Promise<TransactionSendingResult> {
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
            
            return estimateAndSend(estimate, nonce: nonceToUse)
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
            
            zkSync.zksGetBridgeContracts { result in
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
            
            return estimateAndSend(estimate, nonce: nonceToUse)
        }
    }
    
    /// Deploy new smart-contract into chain (this method uses create2, see [EIP-1014](https://eips.ethereum.org/EIPS/eip-1014)).
    ///
    /// - Parameter bytecode: Compiled bytecode of the contract.
    /// - Returns: Prepared remote call of transaction.
    public func deploy(_ bytecode: Data) -> Promise<TransactionSendingResult> {
        deploy(bytecode,
               calldata: nil,
               nonce: nil)
    }
    
    /// Deploy new smart-contract into chain (this method uses create2, see [EIP-1014](https://eips.ethereum.org/EIPS/eip-1014)).
    ///
    /// - Parameters:
    ///   - bytecode: Compiled bytecode of the contract.
    ///   - calldata: Encoded constructor parameter of contract.
    /// - Returns: Prepared remote call of transaction.
    public func deploy(_ bytecode: Data,
                       calldata: Data?) -> Promise<TransactionSendingResult> {
        deploy(bytecode,
               calldata: calldata,
               nonce: nil)
    }
    
    /// Deploy new smart-contract into chain (this method uses create2, see [EIP-1014](https://eips.ethereum.org/EIPS/eip-1014)).
    ///
    /// - Parameters:
    ///   - bytecode: Compiled bytecode of the contract.
    ///   - calldata: Encoded constructor parameter of contract.
    ///   - nonce: Custom nonce value of the wallet.
    /// - Returns: Prepared remote call of transaction.
    public func deploy(_ bytecode: Data,
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
        
        let estimate = EthereumTransaction.create2ContractTransaction(from: EthereumAddress(signer.address)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, bytecode: bytecode, deps: [bytecode], calldata: validCalldata, salt: Data(), chainId: signer.domain.chainId)
        
        return estimateAndSend(estimate, nonce: nonceToUse)
    }
    
    /// Execute function of deployed contract.
    ///
    /// - Parameters:
    ///   - contractAddress: Address of deployed contract.
    ///   - encodedFunction: Prepared function call with or without parameters.
    /// - Returns: Prepared remote call of transaction.
    public func execute(_ contractAddress: String,
                        encodedFunction: Data) -> Promise<TransactionSendingResult> {
        execute(contractAddress,
                encodedFunction: encodedFunction,
                nonce: nil)
    }
    
    /// Execute function of deployed contract.
    ///
    /// - Parameters:
    ///   - contractAddress: Address of deployed contract.
    ///   - encodedFunction: Prepared function call with or without parameters.
    ///   - nonce: Custom nonce value of the wallet.
    /// - Returns: Prepared remote call of transaction.
    public func execute(_ contractAddress: String,
                        encodedFunction: Data,
                        nonce: BigUInt?) -> Promise<TransactionSendingResult> {
        let nonceToUse: BigUInt
        if let nonce = nonce {
            nonceToUse = nonce
        } else {
            nonceToUse = try! getNonce()
        }
        
        // TODO: Validate calldata.
        
        let estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: EthereumAddress(contractAddress)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: encodedFunction)
        
        return estimateAndSend(estimate, nonce: nonceToUse)
    }
    
    /// Get balance of wallet in native coin (wallet address gets from `EthSigner`).
    ///
    /// - Returns: Prepared get balance call.
    public func getBalance() -> Promise<BigUInt> {
        getBalance(signer.address,
                   token: Token.ETH,
                   at: .committed)
    }
    
    /// Get balance of wallet in `Token` (wallet address gets from `EthSigner`).
    ///
    /// - Parameter token: Token object supported by ZkSync.
    /// - Returns: Prepared get balance call.
    public func getBalance(_ token: Token) -> Promise<BigUInt> {
        getBalance(signer.address,
                   token: token,
                   at: .committed)
    }
    
    /// Get balance of wallet in native coin.
    ///
    /// - Parameter address: Address of the wallet.
    /// - Returns: Prepared get balance call.
    public func getBalance(_ address: String) -> Promise<BigUInt> {
        getBalance(address,
                   token: Token.ETH,
                   at: .committed)
    }
    
    /// Get balance of wallet in `Token`.
    ///
    /// - Parameters:
    ///   - address: Address of the wallet.
    ///   - token: Token object supported by ZkSync.
    /// - Returns: Prepared get balance call.
    public func getBalance(_ address: String,
                           token: Token) -> Promise<BigUInt> {
        getBalance(address,
                   token: token,
                   at: .committed)
    }
    
    /// Get balance of wallet by address in `Token` at block `DefaultBlockParameter`.
    /// - Parameters:
    ///   - address: Wallet address.
    ///   - token: Token object supported by ZkSync.
    ///   - at: Block variant.
    /// - Returns: Prepared get balance call.
    public func getBalance(_ address: String,
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
    
    /// Get nonce for wallet at block `DefaultBlockParameter` (wallet address gets from `EthSigner`).
    /// - Parameter at: Block variant.
    /// - Returns: Prepared get nonce call.
    public func getNonce(_ at: ZkBlockParameterName) -> Promise<BigUInt> {
        zkSync.web3.eth.getTransactionCountPromise(address: signer.address,
                                                   onBlock: at.rawValue)
    }
    
    /// Get nonce for wallet at block `.committed`.
    /// - Returns: Nonce for wallet.
    public func getNonce() throws -> BigUInt {
        try getNonce(.committed).wait()
    }
    
    /// Get nonce for wallet at block `.committed`.
    /// - Returns: Prepared get nonce call.
    public func getNonce() -> Promise<BigUInt> {
        getNonce(.committed)
    }
    
    func estimateAndSend(_ transaction: EthereumTransaction, nonce: BigUInt) -> Promise<TransactionSendingResult> {
        let chainID = signer.domain.chainId
        let gasPrice = try! zkSync.web3.eth.getGasPrice()
        
        let estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: transaction.to, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: transaction.data)
        
        let fee = try! zkSync.zksEstimateFee(estimate).wait()
        
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.chainID = chainID
        transactionOptions.nonce = .manual(nonce)
        transactionOptions.from = transaction.parameters.from
        transactionOptions.to = transaction.to
        transactionOptions.value = transaction.value
        transactionOptions.gasLimit = .manual(fee.gasLimit)
        transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
        transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
        
        let gas = try! zkSync.web3.eth.estimateGas(transaction, transactionOptions: transactionOptions)
        transactionOptions.gasLimit = .manual(gas)
        
#if DEBUG
        print("chainID: \(chainID)")
        print("gas: \(gas)")
        print("gasPrice: \(gasPrice)")
#endif
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        
        ethereumParameters.EIP712Meta = (transaction.envelope as! EIP712Envelope).EIP712Meta
        
        var prepared = EthereumTransaction(type: .eip712,
                                           to: transaction.to,
                                           nonce: nonce,
                                           chainID: chainID,
                                           value: transaction.value,
                                           data: transaction.data,
                                           parameters: ethereumParameters)
        
        let domain = signer.domain
        let signature = signer.signTypedData(domain, typedData: prepared)
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
        prepared.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
        prepared.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
        prepared.envelope.v = BigUInt(unmarshalledSignature.v)
        
        guard let message = prepared.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }
        
#if DEBUG
        print("Transaction hash: \(String(describing: prepared.hash?.toHexString().addHexPrefix()))")
        print("Signature: \(signature))")
        print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
#endif
        return zkSync.web3.eth.sendRawTransactionPromise(prepared)
    }
}
