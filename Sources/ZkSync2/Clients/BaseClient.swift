//
//  BaseClient.swift
//  zkSync-Demo
//
//  Created by Bojan on 12.9.23..
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

public class BaseClient: ZkSyncClient {
    public var web3: Web3
    
    let transport: Transport
    var mainContractAddress: String?
    
    public init(_ providerURL: URL) {
        self.web3 = Web3(provider: Web3HttpProvider(url: providerURL, network: .Mainnet))
        self.transport = HTTPTransport(self.web3.provider.url)
    }
    
    public func estimateFee(_ transaction: CodableTransaction) async throws -> Fee {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.from))
        ]

        return try await transport.send(method: "zks_estimateFee", parameters: parameters)
    }
    
    public func chainID() async throws -> BigUInt {
        let result: String = try await transport.send(method: "eth_chainId", parameters: [])
        return BigUInt(from: result.stripHexPrefix())!
    }
    
    public func estimateGas(_ transaction: CodableTransaction) async throws -> BigUInt {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.from))
        ]
        let result: String? = try await transport.send(method: "eth_estimateGas", parameters: parameters)
        return BigUInt((result?.stripHexPrefix())!, radix: 16)!
    }
    
    public func getBalance(address: String, blockNumber: BlockNumber = .latest, token: String?) async throws -> BigUInt {
        if token == nil || token == ZkSyncAddresses.EthAddress {
            return try await web3.eth.getBalance(for: EthereumAddress(address)!, onBlock: blockNumber)
        }
        do {
            let tokenContract = web3.contract(Web3Utils.IERC20, at: EthereumAddress(token!)!)
            return try await tokenContract?.createReadOperation("balanceOf", parameters: [address])?.callContractMethod()["0"] as! BigUInt
        } catch {
            return BigUInt.zero
        }
    }
    
    public func l1TokenAddress(address: String) async throws -> String {
        if address == ZkSyncAddresses.EthAddress {
            return address
        }
        let bridgeAddress = try await bridgeContracts().l1Erc20DefaultBridge
        let bridge = web3.contract(Web3Utils.IL1Bridge, at: EthereumAddress(bridgeAddress)!)
        
        return try await bridge?.createReadOperation("l2TokenAddress", parameters: [address])?.callContractMethod()["0"] as! String
    }
    
    public func l2TokenAddress(address: String) async throws -> String {
        if address == ZkSyncAddresses.EthAddress {
            return address
        }
        let bridgeAddress = try await bridgeContracts().l2Erc20DefaultBridge
        let bridge = web3.contract(Web3Utils.IL2Bridge, at: EthereumAddress(bridgeAddress)!)
        let result = try await bridge?.createReadOperation("l2TokenAddress", parameters: [address])?.callContractMethod()["0"] as! EthereumAddress
        return result.address
    }
    
    public func estimateGasL1(_ transaction: CodableTransaction) async throws -> BigUInt {
        let parameters = [
            JRPC.Parameter(type: .transactionParameters, value: transaction.encodeAsDictionary(from: transaction.from))
        ]
        let result: String = try await transport.send(method: "zks_estimateGasL1ToL2", parameters: parameters)

        return BigUInt(from: result.stripHexPrefix())!
    }
    
    public func mainContract() async throws -> String {
        if mainContractAddress == nil {
            mainContractAddress = try await transport.send(method: "zks_getMainContract", parameters: [])
        }
        return (mainContractAddress)!
    }
    
    public func tokenPrice(_ tokenAddress: String) async throws -> Decimal {
        let parameters = [
            JRPC.Parameter(type: .string, value: tokenAddress),
        ]
        
        let result: String = try await transport.send(method: "zks_getTokenPrice", parameters: parameters)
        
        return Decimal(string: result)!
    }
    
    public func L1ChainId() async throws -> BigUInt {
        let result: String = try await transport.send(method: "zks_L1ChainId", parameters: [])
        
        return BigUInt(from: result.stripHexPrefix())!
    }
    
    public func allAccountBalances(_ address: String) async throws -> Dictionary<String, String> {
        let parameters = [
            JRPC.Parameter(type: .string, value: address)
        ]
        
        return try await transport.send(method: "zks_getAllAccountBalances", parameters: parameters)
    }
    
    public func bridgeContracts() async throws -> BridgeAddresses {
        try await transport.send(method: "zks_getBridgeContracts", parameters: [])
    }
    
    public func getL2ToL1MsgProof(_ block: Int, sender: String, message: String, l2LogPosition: Int64?) async throws -> L2ToL1MessageProof {
        let parameters = [
            JRPC.Parameter(type: .int, value: block),
            JRPC.Parameter(type: .string, value: sender),
            JRPC.Parameter(type: .string, value: message)
        ]
        
        return try await transport.send(method: "zks_getL2ToL1MsgProof", parameters: parameters)
    }
    
    public func getL2ToL1LogProof(_ txHash: String, logIndex: Int) async throws -> L2ToL1MessageProof {
        let parameters = [
            JRPC.Parameter(type: .string, value: txHash),
            JRPC.Parameter(type: .int, value: logIndex),
        ]
        
        return try await transport.send(method: "zks_getL2ToL1LogProof", parameters: parameters)
    }
    
    public func getTestnetPaymaster() async throws -> String {
        try await transport.send(method: "zks_getTestnetPaymaster", parameters: [])
    }
    
    public func transactionDetails(_ txHash: String) async throws -> TransactionDetails {
        try await web3.eth.transactionDetails(Data(hex: txHash))
    }
    
    public func blockDetails(_ block: Int) async throws -> BlockDetails {
        let parameters = [
            JRPC.Parameter(type: .int, value: block),
        ]
        
        return try await transport.send(method: "zks_getBlockDetails", parameters: parameters)
    }
    
    public func blockDetails(_ blockNumber: BigUInt, returnFullTransactionObjects: Bool) async throws -> BlockDetails {
        let parameters = [
            JRPC.Parameter(type: .string, value: blockNumber.toHexString().addHexPrefix()),
        ]
        
        return try await transport.send(method: "zks_getBlockDetails", parameters: parameters)
    }
    
    public func l1BatchNumber() async throws -> String {
        try await transport.send(method: "zks_L1BatchNumber", parameters: [])
    }
    
    public func l1BatchBlockRange(l1BatchNumber: BigUInt) async throws -> String {
        let parameters = [
            JRPC.Parameter(type: .int, value: l1BatchNumber)
        ]
        
        return try await transport.send(method: "zks_getL1BatchBlockRange", parameters: parameters)
    }
    
    public func l1BatchDetails(l1BatchNumber: BigUInt) async throws -> String {
        let parameters = [
            JRPC.Parameter(type: .int, value: l1BatchNumber)
        ]
        
        return try await transport.send(method: "zks_getL1BatchDetails", parameters: parameters)
    }
    
    public func logProof(txHash: String, logIndex: Int) async throws -> L2ToL1MessageProof {
        let parameters = [
            JRPC.Parameter(type: .string, value: txHash),
            JRPC.Parameter(type: .int, value: logIndex)
        ]
        
        return try await transport.send(method: "zks_getL2ToL1LogProof", parameters: parameters)
    }
    
    public func msgProof(block: BigUInt, sender: String) async throws -> String {
        let parameters = [
            JRPC.Parameter(type: .int, value: block),
            JRPC.Parameter(type: .string, value: sender)
        ]
        
        return try await transport.send(method: "zks_getL2ToL1MsgProof", parameters: parameters)
    }
    
    public func getProof(address: String, keys: [String], l1BatchNumber: BigUInt) async throws -> Proof{
        let parameters = [
            JRPC.Parameter(type: .string, value: address),
            JRPC.Parameter(type: .string, value: keys),
            JRPC.Parameter(type: .uint, value: l1BatchNumber)
        ]
        
        return try await transport.send(method: "zks_getProof", parameters: parameters)
    }
    
    public func getL2HashFromPriorityOp(receipt: TransactionReceipt) async throws -> String? {
        let mainContractAddress = try await mainContract()
        let zkSyncContract = web3.contract(Web3Utils.IZkSync, at: EthereumAddress(mainContractAddress))!
        for log in receipt.logs {
            if log.address.address.lowercased() != mainContractAddress.lowercased(){
                continue
            }
            let data = log.data.toHexString()
            return "0x" + data[64..<128]
        }
        
        return nil
    }
    
    public func estimateL1ToL2Execute(_ to: String, from: String, calldata: Data, amount: BigUInt, gasPerPubData: BigUInt = BigUInt(800)) async throws -> BigUInt {
        var EIP712Meta = EIP712Meta()
        EIP712Meta.gasPerPubdata = gasPerPubData
        EIP712Meta.customSignature = nil
        EIP712Meta.factoryDeps = nil
        EIP712Meta.paymasterParams = nil

        var transaction = CodableTransaction(
            type: .eip1559,
            to: EthereumAddress(from: to)!,
            value: amount,
            data: calldata
        )
        transaction.from = EthereumAddress(from: from)!
        transaction.eip712Meta = EIP712Meta

        return try await estimateGasL1(transaction)
    }
    
    public func getWithdrawTx(_ amount: BigUInt, from: String, to: String?, token: String? = nil, options: TransactionOption? = nil, paymasterParams: PaymasterParams? = nil) async throws -> CodableTransaction{
        let to = to ?? from
        var options = options
        let nonce: BigUInt
        if let optionsNonce = options?.nonce {
            nonce = optionsNonce
        }else{
            nonce = try await web3.eth.getTransactionCount(for: EthereumAddress(from)!)
        }
        let prepared = CodableTransaction.createEtherTransaction(from: EthereumAddress(from)!, to: EthereumAddress(to)!, value: amount, nonce: nonce, paymasterParams: paymasterParams)
        if token == ZkSyncAddresses.EthAddress || token == nil {
            if options?.value == nil {
                options?.value = amount
            }
            
            let ethL2Token = web3.contract(Web3Utils.IEthToken, at: EthereumAddress.L2EthTokenAddress, transaction: prepared)
            var transaction = (ethL2Token?.createWriteOperation("withdraw", parameters: [to])!.transaction)!
            transaction.chainID = try await chainID()
            return transaction
        }
        let bridgeAddresses = try await bridgeContracts()
        let bridge = web3.contract(Web3Utils.IL2Bridge, at: EthereumAddress(bridgeAddresses.l2Erc20DefaultBridge), transaction: prepared)
        var transaction = (bridge?.createWriteOperation("withdraw", parameters: [to, token!, amount])!.transaction)!
        transaction.chainID = try await chainID()
        transaction.value = BigUInt.zero

        return transaction
    }
    
    public func estimateGasWithdraw(_ amount: BigUInt, from: String, to: String?, token: String?, options: TransactionOption?, paymasterParams: PaymasterParams?) async throws -> BigUInt?{
        let tx = try await getWithdrawTx(amount, from: from, to: to, token: token, options: options, paymasterParams: paymasterParams)
        return try await web3.eth.estimateGas(for: tx)
    }
    
    public func getTransferTx(_ to: String, amount: BigUInt, from:String, token: String? = nil, options: TransactionOption? = nil, paymasterParams: PaymasterParams? = nil) async -> CodableTransaction {
        let nonce = try! await web3.eth.getTransactionCount(for: EthereumAddress(from)!)
        let prepared = CodableTransaction.createEtherTransaction(from: EthereumAddress(from)!, to: EthereumAddress(to)!, value: amount, nonce: nonce, paymasterParams: paymasterParams)
        
        if token == nil || token == ZkSyncAddresses.EthAddress{
            return prepared
        }
        let tokenContract = web3.contract(Web3Utils.IERC20, at: EthereumAddress(token!)!, transaction: prepared)
        let writeOperation = tokenContract?.createWriteOperation("transfer", parameters: [to, amount])
        var transaction = writeOperation!.transaction
        transaction.value = BigUInt.zero

        return transaction
    }
    
    public func estimateGasTransfer(_ to: String, amount: BigUInt, from:String, token: String? = nil, options: TransactionOption? = nil, paymasterParams: PaymasterParams? = nil) async -> BigUInt {
        let transaction = await getTransferTx(to, amount: amount, from: from, token: token, options: options, paymasterParams: paymasterParams)

        return try! await web3.eth.estimateGas(for: transaction)
    }
}
