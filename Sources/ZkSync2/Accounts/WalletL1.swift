//
//  WalletL1.swift
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

enum EthereumProviderError: Error {
    case invalidAddress
    case invalidToken
    case invalidParameter
    case internalError
}

public class WalletL1: AdapterL1 {
    public let zkSync: ZkSyncClient
    public let ethClient: EthereumClient
    public let web: Web3
    
    fileprivate func l1ERC20BridgeAddress() async throws -> EthereumAddress? {
        let bridgeAddresses = try await zkSync.bridgeContracts()
        
        let erc20Bridge = web.contract(Web3.Utils.IL1Bridge, at: EthereumAddress(bridgeAddresses.l1Erc20DefaultBridge))
        
        return erc20Bridge?.contract.address
    }
    
    public let signer: ETHSigner
    
    public init(_ zkSync: ZkSyncClient, ethClient: EthereumClient, web3: Web3, ethSigner: ETHSigner) {
        self.zkSync = zkSync
        self.ethClient = ethClient
        self.web = web3
        self.signer = ethSigner
    }
}

extension WalletL1 {
    public func signTransaction(transaction: inout CodableTransaction) {
        let privateKeyData = (signer as! BaseSigner).credentials.privateKey
        let keystore = try! EthereumKeystoreV3(privateKey: privateKeyData, password: "web3swift")
        let keystoreManager = KeystoreManager([keystore!])
        web.addKeystoreManager(keystoreManager)
        
        try! transaction.sign(privateKey: privateKeyData)
    }
}

extension WalletL1 {
    func insertOptions(transaction: inout CodableTransaction, options: TransactionOption?) async{
        let options = await Web3Utils.insertGasPrice(options: options, provider: ethClient)
        if transaction.from == nil {
            if let from = options.from {
                transaction.from = EthereumAddress(from)
            }else{
                transaction.from = EthereumAddress(signer.address)
            }
        }
        transaction.chainID = options.chainID ?? signer.domain.chainId
        
        if transaction.nonce == BigUInt.zero {
            if let nonce = options.nonce {
                transaction.nonce = nonce
            }else{
                let nonce = try! await ethClient.transactionCount(address: signer.address, blockNumber: .latest)
                transaction.nonce = nonce
            }
        }
        if transaction.maxFeePerGas == nil || transaction.maxFeePerGas == .zero {
            if let maxFeePerGas = options.maxFeePerGas {
                transaction.maxFeePerGas = maxFeePerGas
            }
        }
        if transaction.maxPriorityFeePerGas == nil || transaction.maxPriorityFeePerGas == .zero {
            if let maxPriorityFeePerGas = options.maxPriorityFeePerGas {
                transaction.maxPriorityFeePerGas = maxPriorityFeePerGas
            }else{
                transaction.maxPriorityFeePerGas = try? await ethClient.maxPriorityFeePerGas()
            }
        }
        if transaction.gasLimit == .zero {
            if let gasLimit = options.gasLimit {
                transaction.gasLimit = gasLimit
            }else{
                let baseLimit = try! await ethClient.estimateGas(transaction)
                transaction.gasLimit = Web3Utils.scaleGasLimit(gas: baseLimit)
            }
        }
    }
}

extension WalletL1 {
    public func finalizeWithdrawal(withdrawalHash: String, index: Int = 0, options: TransactionOption? = nil) async throws -> TransactionSendingResult?{
        let (
            l1BatchNumber,
            l2MessageIndex,
            l2TxNumberInBlock,
            message,
            sender,
            proof
          ) = await _finalizeWithdrawalParams(withdrawHash: withdrawalHash, index: index)
        let transaction = CodableTransaction(type: .eip1559, to: EthereumAddress(signer.address)!)
        
        if sender?.lowercased() == EthereumAddress.L2EthTokenAddress.address.lowercased()
            || sender?.lowercased() == EthereumAddress.Default.address.lowercased() {
            
            let mainContract = try await mainContract(transaction: transaction)
            let params = [l1BatchNumber, l2MessageIndex, l2TxNumberInBlock, message.toHexString().addHexPrefix(), proof] as [AnyObject]
            let writeOperation =  mainContract.createReadOperation("finalizeEthWithdrawal", parameters: params)
            if var tx = writeOperation?.transaction{
                tx.chainID = signer.domain.chainId
                await insertOptions(transaction: &tx, options: options)
                signTransaction(transaction: &tx)
                return try await ethClient.web3.eth.send(raw: tx.encode()!)
            }
            
        }else{
            let l2Bridge = zkSync.web3.contract(Web3Utils.IL2Bridge, at: EthereumAddress(sender!)!, transaction: transaction)
            let l1BridgeAddress = try! await l2Bridge?.createReadOperation("l1Bridge", parameters: [])?.callContractMethod()["0"] as! EthereumAddress
            let l1Bridge = ethClient.web3.contract(Web3Utils.IL1Bridge, at: l1BridgeAddress)
            let params = [l1BatchNumber, l2MessageIndex, l2TxNumberInBlock, message, proof] as [AnyObject]
            let writeOperation = l1Bridge!.createWriteOperation("finalizeWithdrawal", parameters: params)
            if var tx = writeOperation?.transaction{
                await insertOptions(transaction: &tx, options: options)
                signTransaction(transaction: &tx)
                return try await ethClient.web3.eth.send(raw: tx.encode()!)
            }
            
        }
        return nil
    }
    
    public func isWithdrawalFinalized(withdrawHash: String, index: Int = 0) async -> Bool {
        let receipt = try! await zkSync.web3.eth.transactionReceipt(Data(hex: withdrawHash))
        let (log, _) = _getWithdrawalLog(receipt: receipt, index: UInt(index))!
        let (l2ToL1LogIndex, _) = _getWithdrawL2ToL1Log(txReceipt: receipt, index: index)!
        let sender = log.topics[1].suffix(from: 12).toHexString().addHexPrefix()
        let hexHash = withdrawHash
        let proof = try! await zkSync.logProof(txHash: hexHash, logIndex: l2ToL1LogIndex)
        let l2BlockNumber = receipt.l1BatchNumber
        
        if sender.lowercased() == EthereumAddress.L2EthTokenAddress.address.lowercased() 
            || sender.lowercased() == EthereumAddress.Default.address.lowercased() {
            let mainContract = try! await mainContract()
            return try! await mainContract.createReadOperation("isEthWithdrawalFinalized", parameters: [l2BlockNumber!, proof.id])?.callContractMethod()["0"] as! Bool
        }
        
        let l2Bridge = zkSync.web3.contract(Web3Utils.IL2Bridge, at: EthereumAddress(sender)!)
        let l1BridgeAddress = try! await l2Bridge?.createReadOperation("l1Bridge", parameters: [])?.callContractMethod()["0"] as! EthereumAddress
        let l1Bridge = ethClient.web3.contract(Web3Utils.IL1Bridge, at: l1BridgeAddress)
        
        return try! await l1Bridge!.createReadOperation("isWithdrawalFinalized", parameters: [l2BlockNumber!, proof.id])?.callContractMethod()["0"] as! Bool
    }
    
    func _finalizeWithdrawalParams(withdrawHash: String, index: Int) async -> (BigUInt, Int, UInt, Data, String?, [String]) {
        let receipt = try! await zkSync.web3.eth.transactionReceipt(Data(hex: withdrawHash))
        let (log, _) = _getWithdrawalLog(receipt: receipt, index: UInt(index))!
        let (l2ToL1LogIndex, _) = _getWithdrawL2ToL1Log(txReceipt: receipt, index: index)!
        let sender = log.topics[1].suffix(from: 12).toHexString().addHexPrefix()
        let proof = try! await zkSync.logProof(txHash: withdrawHash, logIndex: l2ToL1LogIndex)
        let msg = ABIDecoder.decodeSingleType(type: ABI.Element.ParameterType.dynamicBytes, data: log.data).value as! Data
        
        return (receipt.l1BatchNumber!, proof.id, receipt.l1BatchTxIndex!, msg, sender, proof.proof)
    }
    
    func _getWithdrawalLog(receipt: TransactionReceipt, index: UInt = 0) -> (EventLog, Int)?{
        for (i, log) in receipt.logs.enumerated() {
            if log.address.address == ZkSyncAddresses.MessengerAddress &&
                log.topics[0].toHexString() == "L1MessageSent(address,bytes32,bytes)".data(using: .utf8)?.sha3(.keccak256).toHexString(){
                
                return (log, i)
            }
        }
        return nil
    }
    
    func _getWithdrawL2ToL1Log(txReceipt: TransactionReceipt, index: Int = 0) -> (Int, L2ToL1Log)? {
        guard let l2ToL1Logs = txReceipt.l2ToL1Logs else {
            return nil
        }
        
        var msgs: [(Int, L2ToL1Log)] = []
        for (i, e) in l2ToL1Logs.enumerated() {
            if e.sender.address.lowercased() == ZkSyncAddresses.MessengerAddress.lowercased() {
                msgs.append((i, e))
            }
        }
        
        if index < msgs.count {
            let (l2ToL1LogIndex, log) = msgs[index]
            return (l2ToL1LogIndex, log)
        } else {
            return nil
        }
    }
}

extension WalletL1 {
    public func getAddress() async throws -> String {
        return signer.address
    }
    
    public func approveERC20(token: String, amount: BigUInt?, bridgeAddress: String? = nil) async throws -> TransactionSendingResult {
        var bridgeAddress = bridgeAddress
        if bridgeAddress == nil {
            bridgeAddress = try await L1BridgeContracts().l1Erc20DefaultBridge
        }
        
        let prepared = CodableTransaction(type: .eip1559, to: EthereumAddress(bridgeAddress!)!, from: EthereumAddress(signer.address))
        
        let tokenContract = web.contract(Web3Utils.IERC20, at: EthereumAddress(token)!, transaction: prepared)
                
        let parameters = [
            bridgeAddress!,
            amount!
        ] as [AnyObject]
        
        let writeOperation = tokenContract?.createWriteOperation("approve", parameters: parameters)
        var transaction = writeOperation!.transaction
        await insertOptions(transaction: &transaction, options: nil)
        signTransaction(transaction: &transaction)
        return try await web.eth.send(raw: (transaction.encode())!)
    }
    
    public func getAllowanceL1(token: String, bridgeAddress: String? = nil) async throws -> BigUInt {
        var bridgeAddress = bridgeAddress
        if bridgeAddress == nil {
            bridgeAddress = try await L1BridgeContracts().l1Erc20DefaultBridge
        }
        
        let tokenContract = ERC20(web3: web,
                                  provider: web.provider,
                                  address: EthereumAddress(token)!)
        
        let owner = try! await getAddress()
        
        return try await tokenContract.getAllowance(originalOwner: EthereumAddress(owner)!, delegate: EthereumAddress(bridgeAddress!)!)
    }
    
    public func mainContract(transaction: CodableTransaction = .emptyTransaction) async throws -> Web3.Contract {
        let address = try await self.zkSync.mainContract()
        
        let zkSyncContract = self.web.contract(
            Web3.Utils.IZkSync,
            at: EthereumAddress(address),
            transaction: transaction
        )!
        
        return zkSyncContract
    }
    
    public func balanceL1() async -> BigUInt {
        return try! await web.eth.getBalance(for: EthereumAddress(signer.address)!)
    }
    
    public func baseCost(_ gasLimit: BigUInt, gasPerPubdataByte: BigUInt = BigUInt(800), gasPrice: BigUInt?) async throws -> [String: Any] {
        var gasPrice = gasPrice
        if gasPrice == nil {
            gasPrice = try! await web.eth.gasPrice()
        }
        
        let parameters = [
            gasPrice,
            gasLimit,
            gasPerPubdataByte
        ] as [AnyObject]
        
        guard let transaction = try await mainContract().createReadOperation("l2TransactionBaseCost", parameters: parameters) else {
            throw EthereumProviderError.invalidParameter
        }
        
        return try await transaction.callContractMethod()
    }
    
    public func claimFailedDeposit(_ l1BridgeAddress: String, depositSender: String, l1Token: String, l2TxHash: Data, l2BlockNumber: BigUInt, l2MessageIndex: BigUInt, l2TxNumberInBlock: UInt, proof: [Data]) async throws -> TransactionSendingResult {
        let l1Bridge = web.contract(Web3.Utils.IL1Bridge, at: EthereumAddress(l1BridgeAddress))!

        let parameters = [
            depositSender,
            l1Token,
            l2TxHash,
            l2BlockNumber,
            l2MessageIndex,
            l2TxNumberInBlock,
            proof
        ] as [AnyObject]

        guard let writeTransaction = l1Bridge.createWriteOperation("claimFailedDeposit",
                                                    parameters: parameters) else {
            throw EthereumProviderError.invalidParameter
        }

        guard let encodedTransaction = writeTransaction.transaction.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }
        return try await web.eth.send(writeTransaction.transaction)
    }
    
    public func getRequestExecute(transaction: RequestExecuteTransaction) async throws -> CodableTransaction{
        var tx = transaction
        let address = try await getAddress()
        tx.l2Value = tx.l2Value ?? BigUInt(0)
        tx.operatorTip = tx.operatorTip ?? BigUInt(0)
        tx.factoryDeps = tx.factoryDeps ?? []
        tx.options = tx.options ?? TransactionOption()
        if tx.options?.from == nil {
            tx.options?.from = address
        }
        if tx.options!.nonce == nil{
            tx.options?.nonce = try await ethClient.web3.eth.getTransactionCount(for: EthereumAddress(address)!)
        }

        if tx.refundRecipient == nil {
            tx.refundRecipient = address
        }
        tx.gasPerPubdataByte = tx.gasPerPubdataByte ?? BigUInt(800)
        
        if tx.l2GasLimit == nil {
            tx.l2GasLimit = try! await zkSync.estimateL1ToL2Execute(tx.contractAddress, from: (tx.options?.from)!, calldata: tx.calldata, amount: tx.l2Value!, gasPerPubData: tx.gasPerPubdataByte!)
        }
        
        tx.options = await Web3Utils.insertGasPrice(options: tx.options, provider: ethClient)
        let gasPriceForEstimation = tx.options?.maxFeePerGas ?? tx.options?.gasPrice
        
        guard let baseCost = try await baseCost(tx.l2GasLimit!, gasPrice: gasPriceForEstimation)["0"] as? BigUInt else {
            throw EthereumProviderError.invalidParameter
        }
        
        if tx.options?.value == nil {
            tx.options?.value = baseCost + (tx.operatorTip ?? BigUInt.zero) + tx.l2Value!
        }
        
        let parameters = [
            EthereumAddress(tx.contractAddress)!,
            tx.l2Value!,
            tx.calldata,
            tx.l2GasLimit!,
            tx.gasPerPubdataByte!,
            tx.factoryDeps!,
            tx.refundRecipient!
        ] as [AnyObject]
        var prepared = CodableTransaction.createEthCallTransaction(from: EthereumAddress((tx.options?.from)!)!, to: EthereumAddress(tx.contractAddress)!, data: Data(hex: "0x"))
        prepared.maxFeePerGas = tx.options?.maxFeePerGas
        prepared.maxPriorityFeePerGas = tx.options?.maxPriorityFeePerGas
        prepared.value = (tx.options?.value)!
        prepared.gasLimit = tx.options?.gasLimit ?? BigUInt.zero
        prepared.nonce = (tx.options?.nonce)!
        
        let writeOperation = try! await mainContract(transaction: prepared).createWriteOperation("requestL2Transaction", parameters: parameters)
        writeOperation?.transaction.chainID = try await ethClient.chainID()
        
        return writeOperation!.transaction
    }
    
    public func estimateGasRequestExecute(transaction: CodableTransaction) async throws -> BigUInt?{
        return try! await ethClient.estimateGas(transaction)
    }
    
    public func estimateGasRequestExecute(transaction: RequestExecuteTransaction) async throws -> BigUInt?{
        let requestExecuteTx = try! await getRequestExecute(transaction: transaction)
        return try! await ethClient.estimateGas(requestExecuteTx)
    }

    public func requestExecute(transaction: RequestExecuteTransaction) async throws -> TransactionSendingResult {
        var tx = try await getRequestExecute(transaction: transaction)
        signTransaction(transaction: &tx)
        return try await ethClient.web3.eth.send(raw: tx.encode()!)
    }
    
    public func L1BridgeContracts() async throws -> BridgeAddresses {
        try await self.zkSync.bridgeContracts()
    }
    
    public func deposit(transaction: DepositTransaction) async throws -> TransactionSendingResult {
        var tx = try await getDepositTransaction(transaction: transaction)
        
        if tx.token == ZkSyncAddresses.EthAddress {
            let requestTx = RequestExecuteTransaction(contractAddress: tx.to!, calldata: Data(hex: "0x"), from: tx.options?.from, l2Value: tx.amount, l2GasLimit: tx.l2GasLimit, operatorTip: tx.operatorTip, gasPerPubdataByte: tx.gasPerPubdataByte, refundRecipient: tx.refundRecipient, options: tx.options)
            var prepared = try await getRequestExecute(transaction: requestTx)
            if prepared.gasLimit == BigUInt.zero {
                let baseLimit = try await estimateRequestExecute(transaction: prepared)!
                let gasLimit = Web3Utils.scaleGasLimit(gas: baseLimit)
                prepared.gasLimit = gasLimit
            }
            signTransaction(transaction: &prepared)
            return try await ethClient.web3.eth.send(raw: prepared.encode()!)
        }
        if tx.bridgeAddress == nil{
            tx.bridgeAddress = try await L1BridgeContracts().l1Erc20DefaultBridge
        }
        var bridge = web.contract(Web3Utils.IL1Bridge, at: EthereumAddress(tx.bridgeAddress!))
        
        if tx.approveERC20 ?? false {
            let allowance = try await getAllowanceL1(token: tx.token, bridgeAddress: tx.bridgeAddress)

            if allowance < tx.amount {
                let result = try await approveERC20(token: tx.token, amount: tx.amount, bridgeAddress: tx.bridgeAddress)
                _ = try! await ethClient.waitforTransactionReceipt(transactionHash: result.hash, timeout: 120, pollLatency: 0.5)
            }
        }
        
        var prepared = CodableTransaction.createEthCallTransaction(from: EthereumAddress((tx.options?.from)!)!, to: EthereumAddress(tx.to!)!, data: Data(hex: "0x"))
        prepared.maxFeePerGas = tx.options?.maxFeePerGas
        prepared.maxPriorityFeePerGas = tx.options?.maxPriorityFeePerGas
        prepared.value = (tx.options?.value)!
        prepared.gasLimit = tx.options?.gasLimit ?? BigUInt.zero
        if tx.options?.nonce == nil{
            tx.options?.nonce = try await ethClient.web3.eth.getTransactionCount(for: EthereumAddress(signer.address)!)
        }
        prepared.nonce = (tx.options?.nonce)!
        
        
        let parameters = [
            tx.to!,
            tx.token,
            tx.amount,
            tx.l2GasLimit!,
            tx.gasPerPubdataByte!,
            tx.refundRecipient!
        ] as [AnyObject]
        bridge = web.contract(Web3Utils.IL1Bridge, at: EthereumAddress(tx.bridgeAddress!), transaction: prepared)
        
        
        prepared = (bridge?.createWriteOperation("deposit", parameters: parameters)!.transaction)!
        prepared.chainID = tx.options?.chainID
        
        if prepared.gasLimit == BigUInt.zero {
            let baseLimit = try await ethClient.web3.eth.estimateGas(for: prepared)
            let gasLimit = Web3Utils.scaleGasLimit(gas: baseLimit)
            prepared.gasLimit = gasLimit
        }
        
        signTransaction(transaction: &prepared)
        return try await ethClient.web3.eth.send(raw: prepared.encode()!)
    }
}
