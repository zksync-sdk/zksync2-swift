//
//  NonceHolder.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/15/22.
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
    
    func getDeploymentNonce(_ address: EthereumAddress) async -> Data {
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
        
        // TODO: Is gasLimit and gasPrice are needed?
        // transactionOptions.gasLimit = .manual(contractGasProvider.gasLimit)
        // transactionOptions.gasPrice = .manual(contractGasProvider.gasPrice)
        
        var transaction = CodableTransaction(
            to: contractAddress,
            data: encodedFunction
        )
        transaction.from = address

        return try! await zkSync.web3.eth.callTransaction(transaction)
    }
}
