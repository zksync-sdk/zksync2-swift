//
//  CodableTransaction.swift
//  ZkSync2
//
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

extension CodableTransaction{
    
    public static func createEthCallTransaction(from: EthereumAddress,
                                         to: EthereumAddress,
                                         data: Data) -> CodableTransaction {
        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt(800)
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = nil
        EIP712Meta.paymasterParams = nil
        var transaction = CodableTransaction(
            type: .eip1559,
            to: to,
            data: Data()
        )
        transaction.from = from
        transaction.eip712Meta = EIP712Meta
        
        return transaction
    }
    
    public static func createContractTransaction(from: EthereumAddress,
                                          gasPrice: BigUInt,
                                          gasLimit: BigUInt,
                                          bytecode: Data,
                                          calldata: Data) -> CodableTransaction {
        let calldataCreate = ContractDeployer.encodeCreate(bytecode, calldata: calldata)

#if DEBUG
        print("calldata: \(calldataCreate.toHexString().addHexPrefix())")
#endif
        
        let to = EthereumAddress(ZkSyncAddresses.ContractDeployerAddress)!

        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt(160000)
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = [bytecode]
        EIP712Meta.paymasterParams = nil

        var transaction = CodableTransaction(
            type: .eip712,
            to: to,
            value: .zero,
            data: calldataCreate
        )
        transaction.from = from
        transaction.gasLimit = gasLimit
        transaction.gasPrice = gasPrice
        transaction.eip712Meta = EIP712Meta
        
        return transaction
    }
    
    public static func createAccountTransaction(from: EthereumAddress,
                                          gasPrice: BigUInt,
                                          gasLimit: BigUInt,
                                          bytecode: Data,
                                          calldata: Data) -> CodableTransaction {
        let calldataCreate = ContractDeployer.encodeCreateAccount(bytecode, calldata: calldata, version: .version1)
        
#if DEBUG
        print("calldata: \(calldataCreate.toHexString().addHexPrefix())")
#endif
        
        let to = EthereumAddress(ZkSyncAddresses.ContractDeployerAddress)!

        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt(160000)
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = [bytecode]
        EIP712Meta.paymasterParams = nil

        var transaction = CodableTransaction(
            type: .eip712,
            to: to,
            value: .zero,
            data: calldataCreate
        )
        transaction.from = from
        transaction.gasLimit = gasLimit
        transaction.gasPrice = gasPrice
        transaction.eip712Meta = EIP712Meta
        
        return transaction
    }
    
    public static func createEtherTransaction(from: EthereumAddress,
                                       gasPrice: BigUInt,
                                       gasLimit: BigUInt,
                                       to: EthereumAddress,
                                       value: BigUInt) -> CodableTransaction {
        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt(160000)
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = nil
        EIP712Meta.paymasterParams = nil

        var transaction = CodableTransaction(
            type: .eip712,
            to: to,
            value: value,
            data: Data()
        )
        transaction.from = from
        transaction.gasLimit = gasLimit
        transaction.gasPrice = gasPrice
        transaction.value = value
        transaction.eip712Meta = EIP712Meta
        
        return transaction
    }
    
    public static func createEtherTransaction(from: EthereumAddress,
                                       nonce: BigUInt?,
                                       gasPrice: BigUInt,
                                       gasLimit: BigUInt,
                                       to: EthereumAddress,
                                       value: BigUInt,
                                       chainID: BigUInt) -> CodableTransaction {
        var transaction = CodableTransaction(
            type: .eip712,
            to: to,
            nonce: nonce != nil ? nonce! : BigUInt.zero,
            chainID: chainID,
            value: value,
            data: Data()
        )
        transaction.from = from
        transaction.gasLimit = gasLimit
        transaction.gasPrice = gasPrice
        
        return transaction
    }
    
    public static func createEtherTransaction(from: EthereumAddress,
                                              to: EthereumAddress,
                                              value: BigUInt,
                                              nonce: BigUInt,
                                              gasPrice: BigUInt? = BigUInt.zero,
                                              gasLimit: BigUInt? = BigUInt.zero,
                                              paymasterParams: PaymasterParams? = nil) -> CodableTransaction {
        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt(50000)
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = nil
        EIP712Meta.paymasterParams = paymasterParams

        var transaction = CodableTransaction(
            type: .eip712,
            to: to,
            nonce: nonce,
            value: value,
            eip712Meta: EIP712Meta
        )
        transaction.from = from
        transaction.gasPrice = gasPrice!
        transaction.gasLimit = gasLimit!
        transaction.eip712Meta = EIP712Meta
        transaction.value = value
        
        return transaction
    }
    
    public static func createFunctionCallTransaction(from: EthereumAddress,
                                              to: EthereumAddress,
                                              gasPrice: BigUInt,
                                              gasLimit: BigUInt,
                                              value: BigUInt? = nil,
                                              data: Data) -> CodableTransaction {
        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt(160000)
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = nil
        EIP712Meta.paymasterParams = nil

        var transaction = CodableTransaction(
            type: .eip712,
            to: to,
            value: value ?? .zero,
            data: data
        )
        transaction.from = from
        transaction.gasPrice = gasPrice
        transaction.gasLimit = gasLimit
        transaction.eip712Meta = EIP712Meta
        
        return transaction
    }
    
    public static func create2ContractTransaction(from: EthereumAddress,
                                           gasPrice: BigUInt,
                                           gasLimit: BigUInt,
                                           bytecode: Data,
                                           deps: [Data],
                                           calldata: Data = Data(),
                                           salt: Data,
                                           chainId: BigUInt) -> CodableTransaction {
        let calldataCreate = ContractDeployer.encodeCreate2(bytecode, calldata: calldata)
        
#if DEBUG
        print("calldata: \(calldataCreate.toHexString().addHexPrefix())")
#endif
        
        let to = EthereumAddress(ZkSyncAddresses.ContractDeployerAddress)!
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt(160000)
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = [bytecode]
        EIP712Meta.paymasterParams = nil
        
        var transaction = CodableTransaction(
            type: .eip712,
            to: to,
            value: .zero,
            data: calldataCreate
        )
        transaction.from = from
        transaction.gasLimit = gasLimit
        transaction.gasPrice = gasPrice
        transaction.eip712Meta = EIP712Meta
        
        return transaction
    }
    
    public static func create2AccountTransaction(from: EthereumAddress,
                                                 gasPrice: BigUInt,
                                                 gasLimit: BigUInt,
                                                 bytecode: Data,
                                                 deps: [Data],
                                                 calldata: Data = Data(),
                                                 salt: Data,
                                                 chainId: BigUInt) -> CodableTransaction {
        let calldataCreate = ContractDeployer.encodeCreate2Account(bytecode, calldata: calldata, salt: salt, version: .version1)
        
#if DEBUG
        print("calldata: \(calldataCreate.toHexString().addHexPrefix())")
#endif
        
        let to = EthereumAddress(ZkSyncAddresses.ContractDeployerAddress)!
        
        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = BigUInt(160000)
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = [bytecode]
        EIP712Meta.paymasterParams = nil
        
        var transaction = CodableTransaction(
            type: .eip712,
            to: to,
            value: .zero,
            data: calldataCreate
        )
        transaction.from = from
        transaction.gasLimit = gasLimit
        transaction.gasPrice = gasPrice
        transaction.eip712Meta = EIP712Meta
        
        return transaction
    }
}
