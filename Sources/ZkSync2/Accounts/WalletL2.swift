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
    public func balance(token: String = ZkSyncAddresses.EthAddress, blockNumber: BlockNumber = .latest) async -> BigUInt {
        try! await zkSync.getBalance(address: signer.address, blockNumber: blockNumber, token: token)
    }
    
    public func allBalances(_ address: String) async throws -> Dictionary<String, String> {
        try await zkSync.allAccountBalances(address)
    }
    
    public func withdraw(_ amount: BigUInt, to: String?, token: String? = nil, options: TransactionOption? = nil, paymasterParams: PaymasterParams? = nil) async throws -> TransactionSendingResult? {
        let to = to ?? signer.address
        var options = options
        let nonce: BigUInt
        if let optionsNonce = options?.nonce {
            nonce = optionsNonce
        }else{
            nonce = try await getNonce()
        }
        let prepared = CodableTransaction.createEtherTransaction(from: EthereumAddress(signer.address)!, to: EthereumAddress(to)!, value: amount, nonce: nonce, paymasterParams: paymasterParams)
        if token == ZkSyncAddresses.EthAddress {
            if options?.value == nil {
                options?.value = amount
            }
            
            let ethL2Token = zkSync.web3.contract(Web3Utils.IEthToken, at: EthereumAddress.L2EthTokenAddress, transaction: prepared)
            var transaction = (ethL2Token?.createWriteOperation("withdraw", parameters: [to])!.transaction)!
            transaction.chainID = signer.domain.chainId
            await populateTransaction(&transaction)
            let signed = signTransaction(transaction)
            return try await sendTransaction(signed)
        }
        let bridgeAddresses = try await zkSync.bridgeContracts()
        let bridge = zkSync.web3.contract(Web3Utils.IL2Bridge, at: EthereumAddress(bridgeAddresses.l2Erc20DefaultBridge), transaction: prepared)
        var transaction = (bridge?.createWriteOperation("withdraw", parameters: [to, token!, amount])!.transaction)!
        transaction.chainID = signer.domain.chainId
        transaction.value = BigUInt.zero
        await populateTransaction(&transaction)
        let signed = signTransaction(transaction)
        
        return try await sendTransaction(signed)
    }
    
    public func callContract(_ transaction: CodableTransaction, blockNumber: BigUInt?) async throws -> Data {
        try await ethClient.callContract(transaction, blockNumber: blockNumber)
    }
    
    public func populateTransaction(_ transaction: inout CodableTransaction) async {
        if transaction.chainID == nil || transaction.chainID != signer.domain.chainId {
            transaction.chainID = signer.domain.chainId
        }
        if transaction.nonce == .zero {
            let nonce = try! await web.eth.getTransactionCount(
                for: EthereumAddress(signer.address)!,
                onBlock: .pending
            )
            
            transaction.nonce = nonce
        }
        
        let fee = try! await zkSync.estimateFee(transaction)
        if transaction.maxFeePerGas == nil || transaction.maxFeePerGas == .zero {
            transaction.maxFeePerGas = fee.maxFeePerGas
        }
        if transaction.maxPriorityFeePerGas == nil || transaction.maxPriorityFeePerGas == .zero {
            transaction.maxPriorityFeePerGas = fee.maxPriorityFeePerGas
        }
        if transaction.eip712Meta == nil {
            transaction.eip712Meta = EIP712Meta(gasPerPubdata: BigUInt(50_000))
        } else if transaction.eip712Meta?.gasPerPubdata == nil {
            transaction.eip712Meta?.gasPerPubdata = BigUInt(50_000)
        }
        if transaction.gasLimit == .zero {
            transaction.gasLimit = fee.gasLimit
        }
    }
    
    public func sendTransaction(_ transaction: CodableTransaction) async throws -> TransactionSendingResult {
        try await zkSync.web3.eth.send(raw: transaction.encode(for: .transaction)!)
    }
    
    public func signTransaction(_ transaction: CodableTransaction) -> CodableTransaction{
        let domain = signer.domain
        let signature = signer.signTypedData(signer.domain, typedData: transaction)
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(hex: signature))
        let r = BigUInt(from: unmarshalledSignature!.r.toHexString().addHexPrefix())!
        let s = BigUInt(from: unmarshalledSignature!.s.toHexString().addHexPrefix())!
        let v = BigUInt(unmarshalledSignature!.v)
        return CodableTransaction(type: transaction.type, to: transaction.to, nonce: transaction.nonce, chainID: transaction.chainID!, value: transaction.value, data: transaction.data, gasLimit: transaction.gasLimit, maxFeePerGas: transaction.maxFeePerGas, maxPriorityFeePerGas: transaction.maxPriorityFeePerGas, gasPrice: transaction.gasPrice, accessList: transaction.accessList, v: v, r: r, s: s, eip712Meta: transaction.eip712Meta, from: transaction.from)
    }
    
    public func estimateGasWithdraw(_ transaction: CodableTransaction) async throws -> BigUInt {
        try await zkSync.estimateGasWithdraw(transaction)
    }
    
    public func estimateGasTransfer(_ transaction: CodableTransaction) async throws -> BigUInt {
        try await zkSync.estimateGasTransfer(transaction)
    }
}

extension WalletL2 {
    public func transfer(_ to: String, amount: BigUInt, token: String? = nil, options: TransactionOption? = nil, paymasterParams: PaymasterParams? = nil) async -> TransactionSendingResult {
        let from = signer.address
        let nonce = try! await getNonce()
        var prepared = CodableTransaction.createEtherTransaction(from: EthereumAddress(from)!, to: EthereumAddress(to)!, value: amount, nonce: nonce, paymasterParams: paymasterParams)
        
        if token == nil || token == ZkSyncAddresses.EthAddress{
            await populateTransaction(&prepared)
            let signed = signTransaction(prepared)
            return try! await sendTransaction(signed)
        }
        let tokenContract = zkSync.web3.contract(Web3Utils.IERC20, at: EthereumAddress(token!)!, transaction: prepared)
        let writeOperation = tokenContract?.createWriteOperation("transfer", parameters: [to, amount])
        var transaction = writeOperation!.transaction
        transaction.value = BigUInt.zero
        await populateTransaction(&transaction)
        let signed = signTransaction(transaction)
        return try! await sendTransaction(signed)
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
