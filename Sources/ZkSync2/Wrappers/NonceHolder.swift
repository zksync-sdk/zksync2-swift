//
//  NonceHolder.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/15/22.
//

import Foundation
import web3swift
import BigInt
import PromiseKit

class NonceHolder {
    
    let contractAddress: EthereumAddress!
    
    let zkSync: ZkSync!
    
    let contractGasProvider: ContractGasProvider!
    
    let credentials: Credentials
    
    init(_ contractAddress: EthereumAddress, zkSync: ZkSync, contractGasProvider: ContractGasProvider, credentials: Credentials) {
        self.contractAddress = contractAddress
        self.zkSync = zkSync
        self.contractGasProvider = contractGasProvider
        self.credentials = credentials
    }
    
    func getDeploymentNonce(_ address: EthereumAddress) -> Promise<Data> {
        let inputs = [
            ABI.Element.InOut(name: "_address", type: .address),
        ]
        
        let function = ABI.Element.Function(name: "getDeploymentNonce",
                                            inputs: inputs,
                                            outputs: [],
                                            constant: false,
                                            payable: false)
        
        let elementFunction: ABI.Element = .function(function)
        
        let parameters: [AnyObject] = [
            address as AnyObject,
        ]
        
        guard let encodedFunction = elementFunction.encodeParameters(parameters) else {
            fatalError("Failed to encode function.")
        }
        
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.from = address
        transactionOptions.to = contractAddress
        
        // TODO: Is gasLimit and gasPrice are needed?
        // transactionOptions.gasLimit = .manual(contractGasProvider.gasLimit)
        // transactionOptions.gasPrice = .manual(contractGasProvider.gasPrice)
        
        let ethereumParameters = EthereumParameters(from: transactionOptions)
        let transaction = EthereumTransaction(// type: ,
                                              to: contractAddress,
                                              // nonce: ,
                                              // chainID: ,
                                              // value: ,
                                              data: encodedFunction,
                                              parameters: ethereumParameters)

        return zkSync.web3.eth.callPromise(transaction, transactionOptions: transactionOptions)
    }
}
