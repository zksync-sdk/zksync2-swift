//
//  EthereumTransaction.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

extension EthereumTransaction {
    
    public static func createEthCallTransaction(from: EthereumAddress,
                                         to: EthereumAddress,
                                         data: String) -> EthereumTransaction {
        fatalError("Implement.")
    }
    
    public static func createContractTransaction(from: EthereumAddress,
                                          gasPrice: BigUInt,
                                          gasLimit: BigUInt,
                                          bytecode: Data,
                                          calldata: Data) -> EthereumTransaction {
        let calldataCreate = ContractDeployer.encodeCreate(bytecode, calldata: calldata)
        
#if DEBUG
        print("calldata: \(calldataCreate.toHexString().addHexPrefix())")
#endif
        
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.from = from
        
        let to = EthereumAddress(ZkSyncAddresses.ContractDeployerAddress)!
        transactionOptions.to = to
        transactionOptions.gasLimit = .manual(gasLimit)
        transactionOptions.gasPrice = .manual(gasPrice)
        transactionOptions.value = nil
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt(160000)
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = [bytecode]
        EIP712Meta.paymasterParams = nil
        ethereumParameters.EIP712Meta = EIP712Meta
        
        return EthereumTransaction(
            type: .eip712,
            to: to,
            value: nil,
            data: calldataCreate,
            parameters: ethereumParameters
        )
    }
    
    public static func createAccountTransaction(from: EthereumAddress,
                                          gasPrice: BigUInt,
                                          gasLimit: BigUInt,
                                          bytecode: Data,
                                          calldata: Data) -> EthereumTransaction {
        let calldataCreate = ContractDeployer.encodeCreateAccount(bytecode, calldata: calldata, version: .version1)
        
#if DEBUG
        print("calldata: \(calldataCreate.toHexString().addHexPrefix())")
#endif
        
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.from = from
        
        let to = EthereumAddress(ZkSyncAddresses.ContractDeployerAddress)!
        transactionOptions.to = to
        transactionOptions.gasLimit = .manual(gasLimit)
        transactionOptions.gasPrice = .manual(gasPrice)
        transactionOptions.value = nil
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt(160000)
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = [bytecode]
        EIP712Meta.paymasterParams = nil
        ethereumParameters.EIP712Meta = EIP712Meta
        
        return EthereumTransaction(
            type: .eip712,
            to: to,
            value: nil,
            data: calldataCreate,
            parameters: ethereumParameters
        )
    }
    
    public static func createEtherTransaction(from: EthereumAddress,
                                       gasPrice: BigUInt,
                                       gasLimit: BigUInt,
                                       to: EthereumAddress,
                                       value: BigUInt) -> EthereumTransaction {
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.from = from
        transactionOptions.to = to
        transactionOptions.gasLimit = .manual(gasLimit)
        transactionOptions.gasPrice = .manual(gasPrice)
        transactionOptions.value = value
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt(160000)
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = nil
        EIP712Meta.paymasterParams = nil
        ethereumParameters.EIP712Meta = EIP712Meta
        
        return EthereumTransaction(
            type: .eip712,
            to: to,
            value: value,
            data: Data(),
            parameters: ethereumParameters
        )
    }
    
    public static func createEtherTransaction(from: EthereumAddress,
                                       nonce: BigUInt?,
                                       gasPrice: BigUInt,
                                       gasLimit: BigUInt,
                                       to: EthereumAddress,
                                       value: BigUInt,
                                       chainID: BigUInt) -> EthereumTransaction {
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip1559
        transactionOptions.from = from
        transactionOptions.to = to
        if let nonce = nonce {
            transactionOptions.nonce = .manual(nonce)
        }
        transactionOptions.gasLimit = .manual(gasLimit)
        transactionOptions.gasPrice = .manual(gasPrice)
        transactionOptions.value = value
        transactionOptions.chainID = chainID
        
        let ethereumParameters = EthereumParameters(from: transactionOptions)
        
        return EthereumTransaction(
            type: .eip1559,
            to: to,
            nonce: nonce != nil ? nonce! : BigUInt.zero,
            chainID: chainID,
            value: value,
            data: Data(),
            parameters: ethereumParameters
        )
    }
    
    public static func createFunctionCallTransaction(from: EthereumAddress,
                                              to: EthereumAddress,
                                              gasPrice: BigUInt,
                                              gasLimit: BigUInt,
                                              value: BigUInt? = nil,
                                              data: Data) -> EthereumTransaction {
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.from = from
        transactionOptions.to = to
        transactionOptions.gasPrice = .manual(gasPrice)
        transactionOptions.gasLimit = .manual(gasLimit)
        transactionOptions.value = value
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt(160000)
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = nil
        EIP712Meta.paymasterParams = nil
        ethereumParameters.EIP712Meta = EIP712Meta
        
        let ethereumTransaction = EthereumTransaction(
            type: .eip712,
            to: to,
            // nonce: ,
            // chainID: ,
            value: value,
            data: data,
            parameters: ethereumParameters
        )
        
        return ethereumTransaction
    }
    
    public static func create2ContractTransaction(from: EthereumAddress,
                                           gasPrice: BigUInt,
                                           gasLimit: BigUInt,
                                           bytecode: Data,
                                           deps: [Data],
                                           calldata: Data = Data(),
                                           salt: Data,
                                           chainId: BigUInt) -> EthereumTransaction {
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.from = from
        transactionOptions.gasPrice = .manual(gasPrice)
        transactionOptions.gasLimit = .manual(gasLimit)
        
        let to = EthereumAddress(ZkSyncAddresses.ContractDeployerAddress)!
        transactionOptions.to = to
        transactionOptions.value = nil
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        ethereumParameters.from = from
        ethereumParameters.gasPrice = gasPrice
        ethereumParameters.gasLimit = gasLimit
        
        let calldataCreate = ContractDeployer.encodeCreate2(bytecode,
                                                            calldata: calldata,
                                                            salt: salt)
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt(160000)
        EIP712Meta.factoryDeps = [bytecode]
        EIP712Meta.paymasterParams = nil
        EIP712Meta.customSignature = nil
        ethereumParameters.EIP712Meta = EIP712Meta
        
        let ethereumTransaction = EthereumTransaction(
            type: .eip712,
            to: to,
            // nonce: ,
//            chainID: chainId,
            value: nil,
            data: calldataCreate,
            parameters: ethereumParameters
        )
        
        return ethereumTransaction
    }
    
    public static func create2AccountTransaction(from: EthereumAddress,
                                           gasPrice: BigUInt,
                                           gasLimit: BigUInt,
                                           bytecode: Data,
                                           deps: [Data],
                                           calldata: Data = Data(),
                                           salt: Data,
                                           chainId: BigUInt) -> EthereumTransaction {
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.from = from
        transactionOptions.gasPrice = .manual(gasPrice)
        transactionOptions.gasLimit = .manual(gasLimit)
        
        let to = EthereumAddress(ZkSyncAddresses.ContractDeployerAddress)!
        transactionOptions.to = to
        transactionOptions.value = nil
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        ethereumParameters.from = from
//        ethereumParameters.gasPrice = gasPrice
//        ethereumParameters.gasLimit = gasLimit
        
        let calldataCreate = ContractDeployer.encodeCreate2Account(bytecode, calldata: calldata, salt: salt, version: .version1)
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt(160000)
        EIP712Meta.factoryDeps = [bytecode]
        EIP712Meta.paymasterParams = nil
        EIP712Meta.customSignature = nil
        ethereumParameters.EIP712Meta = EIP712Meta
        
        let ethereumTransaction = EthereumTransaction(
            type: .eip712,
            to: to,
            // nonce: ,
//            chainID: chainId,
            value: nil,
            data: calldataCreate,
            parameters: ethereumParameters
        )
        
        return ethereumTransaction
    }
}
