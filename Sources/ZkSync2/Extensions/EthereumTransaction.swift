//
//  EthereumTransaction.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
import web3swift

extension EthereumTransaction {
    
    static func createEtherTransaction(from: EthereumAddress,
                                       ergsPrice: BigUInt,
                                       ergsLimit: BigUInt,
                                       to: EthereumAddress,
                                       value: BigUInt) -> EthereumTransaction {
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.from = from
        transactionOptions.to = to
        transactionOptions.gasLimit = .manual(ergsLimit)
        transactionOptions.gasPrice = .manual(ergsPrice)
        transactionOptions.value = value
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.ergsPerPubdata = BigUInt(160000)
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = nil
        EIP712Meta.paymasterParams = nil
        ethereumParameters.EIP712Meta = EIP712Meta
        
        return EthereumTransaction(type: .eip712,
                                   to: to,
                                   value: value,
                                   data: Data(),
                                   parameters: ethereumParameters)
    }
    
    static func createEtherTransaction(from: EthereumAddress,
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
        
        return EthereumTransaction(type: .eip1559,
                                   to: to,
                                   nonce: nonce != nil ? nonce! : BigUInt.zero,
                                   chainID: chainID,
                                   value: value,
                                   data: Data(),
                                   parameters: ethereumParameters)
    }
    
    static func createFunctionCallTransaction(from: EthereumAddress,
                                              to: EthereumAddress,
                                              ergsPrice: BigUInt,
                                              ergsLimit: BigUInt,
                                              value: BigUInt? = nil,
                                              data: Data) -> EthereumTransaction {
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.from = from
        transactionOptions.to = to
        transactionOptions.gasPrice = .manual(ergsPrice)
        transactionOptions.gasLimit = .manual(ergsLimit)
        transactionOptions.value = value
        
        // transactionOptions.nonce =
        // transactionOptions.chainID =
        // transactionOptions.maxPriorityFeePerGas =
        // transactionOptions.maxFeePerGas =
        // transactionOptions.callOnBlock =
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.ergsPerPubdata = BigUInt(160000)
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = nil
        EIP712Meta.paymasterParams = nil
        ethereumParameters.EIP712Meta = EIP712Meta
        
        let ethereumTransaction = EthereumTransaction(type: .eip712,
                                                      to: to,
                                                      // nonce: ,
                                                      // chainID: ,
                                                      value: value,
                                                      data: data,
                                                      parameters: ethereumParameters)
        
        return ethereumTransaction
    }
    
    static func create2ContractTransaction(from: EthereumAddress,
                                           ergsPrice: BigUInt,
                                           ergsLimit: BigUInt,
                                           bytecode: Data,
                                           calldata: Data = Data()) -> EthereumTransaction {
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.from = from
        transactionOptions.gasPrice = .manual(ergsPrice)
        transactionOptions.gasLimit = .manual(ergsLimit)
        
        let to = EthereumAddress(ZkSyncAddresses.ContractDeployerAddress)!
        transactionOptions.to = to
        transactionOptions.value = nil
        
        // transactionOptions.nonce =
        // transactionOptions.chainID =
        // transactionOptions.maxPriorityFeePerGas =
        // transactionOptions.maxFeePerGas =
        // transactionOptions.callOnBlock =
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        ethereumParameters.from = from
        
        let calldataCreate = ContractDeployer.encodeCreate2(bytecode, calldata: calldata)
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.ergsPerPubdata = BigUInt(160000)
        EIP712Meta.factoryDeps = [bytecode]
        EIP712Meta.paymasterParams = nil
        ethereumParameters.EIP712Meta = EIP712Meta
        
        let ethereumTransaction = EthereumTransaction(type: .eip712,
                                                      to: to,
                                                      // nonce: ,
                                                      // chainID: ,
                                                      value: nil,
                                                      data: calldataCreate,
                                                      parameters: ethereumParameters)
        
        return ethereumTransaction
    }
}
