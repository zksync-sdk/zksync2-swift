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
    public func baseCost(_ gasLimit: BigUInt, gasPerPubdataByte: BigUInt, gasPrice: BigUInt?) async throws -> [String : Any] {
        var chainId: BigUInt? = nil
        var gasPrice = gasPrice
        if gasPrice == nil {
            gasPrice = try! await web.eth.gasPrice()
        }
        
        if chainId == nil{
            chainId = try await zkSync.chainID()
        }
        let parameters = [
            chainId,
            gasPrice,
            gasLimit,
            gasPerPubdataByte
        ] as [AnyObject]
        
        let bridgehub = try await self.getBridgehubContract()
        guard let transaction = bridgehub.createReadOperation("l2TransactionBaseCost", parameters: parameters) else {
            throw EthereumProviderError.invalidParameter
        }
        
        return try await transaction.callContractMethod()
    }
    
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
        
        transaction.value = options.value ?? 0
        
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
        let params = await _finalizeWithdrawalParams(withdrawHash: withdrawalHash, index: index)
        let transaction = CodableTransaction(type: .eip1559, to: EthereumAddress(signer.address)!)
        
        let l1Bridge = ethClient.web3.contract(Web3Utils.IL1Bridge, at: EthereumAddress(try await getL1BridgeContracts().l1SharedDefaultBridge), transaction: transaction)
        
        let writeOperation = l1Bridge!.createWriteOperation("finalizeWithdrawal", parameters: [params])
        if var tx = writeOperation?.transaction{
            await insertOptions(transaction: &tx, options: options)
            signTransaction(transaction: &tx)
            return try await ethClient.web3.eth.send(raw: tx.encode()!)
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
    
    public func mainContract(transaction: CodableTransaction = .emptyTransaction) async throws -> Web3.Contract {
        let address = try await self.zkSync.mainContract()
        
        let zkSyncContract = self.web.contract(
            Web3.Utils.IZkSync,
            at: EthereumAddress(address),
            transaction: transaction
        )!
        
        return zkSyncContract
    }
    
    public func getBridgehubContract(transaction: CodableTransaction = .emptyTransaction) async throws -> Web3.Contract {
        let address = try await self.zkSync.getBridgehubContractAddress()
        
        let bridgehubContract = self.web.contract(
            Web3.Utils.IBridgehub,
            at: EthereumAddress(address),
            transaction: transaction
        )!
        
        return bridgehubContract
    }
    
    public func getL1BridgeContracts() async throws -> BridgeAddresses {
        try await self.zkSync.bridgeContracts()
    }
    
    public func getBaseToken() async throws -> String {
        let bridgehub = try await self.getBridgehubContract()
        let chainId = try await self.zkSync.chainID()
        
        return await (try! bridgehub.createReadOperation("baseToken", parameters: [chainId])?.callContractMethod()["0"] as! EthereumAddress).address
    }
    
    public func isETHBasedChain() async throws -> Bool {
        return try! await self.zkSync.isEthBasedChain()
    }
    
    public func balanceL1(token: String = ZkSyncAddresses.EthAddress, blockNumber: BlockNumber = .latest) async -> BigUInt {
        if ZkSyncAddresses.isEth(a: token){
            return try! await web.eth.getBalance(for: EthereumAddress(signer.address)!, onBlock: blockNumber)
        } else {
            let tokenContract = web.contract(Web3Utils.IERC20, at: EthereumAddress(token)!)
            return try! await tokenContract?.createReadOperation("balanceOf", parameters: [getAddress()])?.callContractMethod()["0"] as? BigUInt ?? BigUInt.zero
        }
    }
    
    public func getAllowanceL1(token: String, bridgeAddress: String? = nil) async throws -> BigUInt {
        var bridgeAddress = bridgeAddress
        if bridgeAddress == nil {
            bridgeAddress = try await getL1BridgeContracts().l1SharedDefaultBridge
        }
        
        let tokenContract = ERC20(web3: web,
                                  provider: web.provider,
                                  address: EthereumAddress(token)!)
        
        let owner = try! await getAddress()
        
        return try await tokenContract.getAllowance(originalOwner: EthereumAddress(owner)!, delegate: EthereumAddress(bridgeAddress!)!)
    }
    
    public func approveERC20(token: String, amount: BigUInt?, bridgeAddress: String? = nil) async throws -> TransactionSendingResult {
        var bridgeAddress = bridgeAddress
        if bridgeAddress == nil {
            bridgeAddress = try await getL1BridgeContracts().l1SharedDefaultBridge
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
    
    public func baseCost(_ gasLimit: BigUInt, gasPerPubdataByte: BigUInt = BigUInt(800), gasPrice: BigUInt?, chainId: BigUInt? = nil) async throws -> [String: Any] {
        var chainId = chainId
        var gasPrice = gasPrice
        if gasPrice == nil {
            gasPrice = try! await web.eth.gasPrice()
        }
        
        if chainId == nil{
            chainId = try await zkSync.chainID()
        }
        let parameters = [
            chainId,
            gasPrice,
            gasLimit,
            gasPerPubdataByte
        ] as [AnyObject]
        
        let bridgehub = try await self.getBridgehubContract()
        guard let transaction = bridgehub.createReadOperation("l2TransactionBaseCost", parameters: parameters) else {
            throw EthereumProviderError.invalidParameter
        }
        
        return try await transaction.callContractMethod()
    }
    
    public func getDepositAllowanceParams(token: String, amount: BigUInt) async throws -> [AllowanceParams]{
        var token = token
        if ZkSyncAddresses.isAddressEq(a: token, b: ZkSyncAddresses.LEGACY_ETH_ADDRESS){
            token = ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS
        }
        
        let baseToken = try! await getBaseToken()
        let isEthChain = try! await isETHBasedChain()
        
        if isEthChain && ZkSyncAddresses.isAddressEq(a: token, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS){
            fatalError("ETH token can't be approved! The address of the token does not exist on L1.")
        } else if ZkSyncAddresses.isAddressEq(a: baseToken, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS) {
            return [AllowanceParams(token: token, allowance: amount)]
        } else if ZkSyncAddresses.isAddressEq(a: token, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS) {
            let tx = try await _getDepositETHOnETHBasedChainTx(transaction: DepositTransaction(token: token, amount: amount))
            return [AllowanceParams(token: baseToken, allowance: tx.mintValue!)]
        } else if ZkSyncAddresses.isAddressEq(a: token, b: baseToken) {
            let mintValue = try await _getDepositBaseTokenOnNonETHBasedChainTx(transaction: DepositTransaction(token: token, amount: amount)).mintValue
            return [AllowanceParams(token: baseToken, allowance: mintValue!)]
        }
        let mintValue = try await _getDepositNonBaseTokenToNonETHBasedChainTx(transaction: DepositTransaction(token: token, amount: amount)).mintValue
        return [AllowanceParams(token: baseToken, allowance: mintValue), AllowanceParams(token: token, allowance: amount)]
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
        
        guard writeTransaction.transaction.encode(for: .transaction) != nil else {
            fatalError("Failed to encode transaction.")
        }
        return try await web.eth.send(writeTransaction.transaction)
    }
    
    public func getRequestExecute(transaction: RequestExecuteTransaction) async throws -> CodableTransaction{
        let isEthBasedChain = try await isETHBasedChain()
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
        
        let l2Costs = baseCost + (tx.operatorTip ?? BigUInt.zero) + tx.l2Value!
        var providedValue = isEthBasedChain ? tx.options?.value : l2Costs
        if providedValue == nil || providedValue == 0 {
            providedValue = l2Costs
            if isEthBasedChain {
                tx.options?.value = providedValue
            }
        }
        let tuple: [AnyObject] = [
            try await zkSync.chainID(),
            providedValue!,
            EthereumAddress(tx.contractAddress)!,
            tx.l2Value!,
            tx.calldata,
            tx.l2GasLimit!,
            tx.gasPerPubdataByte!,
            tx.factoryDeps!,
            EthereumAddress(tx.refundRecipient!)!
        ] as [AnyObject]
        let parameters: [AnyObject] = [tuple as AnyObject]
        
        var prepared = CodableTransaction.createEthCallTransaction(from: EthereumAddress((tx.options?.from)!)!, to: EthereumAddress(tx.contractAddress)!, data: Data(hex: "0x"))
        prepared.maxFeePerGas = tx.options?.maxFeePerGas
        prepared.maxPriorityFeePerGas = tx.options?.maxPriorityFeePerGas
        prepared.value = tx.options?.value ?? 0
        prepared.gasLimit = tx.options?.gasLimit ?? BigUInt.zero
        prepared.nonce = (tx.options?.nonce)!

        let writeOperation = try! await getBridgehubContract(transaction: prepared).createWriteOperation("requestL2TransactionDirect", parameters: parameters)
        writeOperation?.transaction.chainID = try await ethClient.chainID()
        
        return writeOperation!.transaction
    }
    
    public func getRequestExecuteAllowanceParams(transaction: RequestExecuteTransaction) async throws -> AllowanceParams{
        let isEthChain = try! await isETHBasedChain()
        var tx = transaction
        let address = try! await getAddress()
        if isEthChain {
            fatalError("ETH token can't be approved! The address of the token does not exist on L1.")
        }
        
        tx.options = tx.options ?? TransactionOption()
        tx.operatorTip = tx.operatorTip ?? 0
        tx.factoryDeps = tx.factoryDeps ?? []
        tx.l2Value = tx.l2Value ?? 0
        tx.gasPerPubdataByte = tx.gasPerPubdataByte ?? BigUInt(800)
        tx.refundRecipient = tx.refundRecipient ?? address
        tx.from = tx.from ?? address
        if tx.l2GasLimit == nil {
            tx.l2GasLimit = try! await zkSync.estimateL1ToL2Execute(transaction.contractAddress, from: tx.from!, calldata: tx.calldata, amount: tx.l2Value!, gasPerPubData: tx.gasPerPubdataByte!)
        }
        
        tx.options = await Web3Utils.insertGasPrice(options: tx.options, provider: ethClient)
        let gasPriceForEstimation = tx.options?.maxFeePerGas ?? tx.options?.gasPrice
        let baseCost = try await baseCost(tx.l2GasLimit!, gasPrice: gasPriceForEstimation)["0"] as! BigUInt
        
        return AllowanceParams(token: try await getBaseToken(), allowance: baseCost + tx.operatorTip! + tx.l2Value!)
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
    
    public func getDepositTransaction(transaction: DepositTransaction) async throws-> Any{
        var tx = transaction
        if ZkSyncAddresses.isAddressEq(a: transaction.token, b: ZkSyncAddresses.LEGACY_ETH_ADDRESS){
            tx.token = ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS
        }
        
        let baseToken = try await getBaseToken()
        let isEthChain = try await isETHBasedChain()
        
        if isEthChain && ZkSyncAddresses.isAddressEq(a: transaction.token, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS){
            return try await _getDepositETHOnETHBasedChainTx(transaction: tx)
        } else if ZkSyncAddresses.isAddressEq(a: baseToken, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS){
            return try await _getDepositTokenOnETHBasedChainTx(transaction: tx)
        } else if ZkSyncAddresses.isAddressEq(a: transaction.token, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS){
            return try await _getDepositETHOnNonETHBasedChainTx(transaction: tx).tx
        } else if ZkSyncAddresses.isAddressEq(a: transaction.token, b: baseToken){
            return try await _getDepositBaseTokenOnNonETHBasedChainTx(transaction: tx)
        } else {
            return try await _getDepositNonBaseTokenToNonETHBasedChainTx(transaction: tx).tx
        }
    }
    
    public func getFullRequiredDepositFee(transaction: DepositTransaction) async throws -> FullDepositFee{
        let dummyAmount = BigUInt.one
        var tx = transaction
        if ZkSyncAddresses.isAddressEq(a: transaction.token, b: ZkSyncAddresses.LEGACY_ETH_ADDRESS){
            tx.token = ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS
        }
        let baseToken = try await getBaseToken()
        let isEthChain = try await isETHBasedChain()
        
        tx = try await _getDepositTxWithDefaults(transaction: tx)
        
        let gasPriceForEstimation = tx.options?.maxFeePerGas ?? tx.options?.gasPrice
        let baseCost = try await baseCost(tx.l2GasLimit!, gasPrice: gasPriceForEstimation)["0"] as! BigUInt
        
        if isEthChain {
            let selfBalanceETH = await balanceL1()
            
            if (baseCost >= selfBalanceETH + dummyAmount){
                let recommendedAmount = (tx.token == ZkSyncAddresses.LEGACY_ETH_ADDRESS ? BigUInt(200_000) : BigUInt(400_000)) *
                ((gasPriceForEstimation ?? BigUInt.zero) + baseCost)
            }
            
            let amountForEstimate = dummyAmount
            if tx.token != ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS {
                let allowance = try! await getAllowanceL1(token: tx.token)
                if allowance < amountForEstimate {
                    fatalError("Not enough allowance to cover the deposit!")
                }
            }
        } else {
            let mintValue = baseCost + (tx.operatorTip ?? 0)
            
            if try! await getAllowanceL1(token: baseToken) < mintValue {
                fatalError("Not enough base token allowance to cover the deposit!")
            }
            
            if ZkSyncAddresses.isAddressEq(a: tx.token, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS) ||
                ZkSyncAddresses.isAddressEq(a: tx.token, b: baseToken){
                tx.options?.value = tx.amount
            } else {
                tx.options?.value = 0
                if try! await getAllowanceL1(token: tx.token) < dummyAmount {
                    fatalError("Not enough token allowance to cover the deposit!")
                }
            }
        }
        
        let options = await Web3Utils.insertGasPrice(options: tx.options, provider: ethClient)
        
        tx.options?.gasPrice = nil
        tx.options?.maxFeePerGas = nil
        tx.options?.maxPriorityFeePerGas = nil
                
        let l1GasLimit = try! await estimateGasDeposit(transaction: tx)
        
        var fullCost = FullDepositFee(baseCost: baseCost, l1GasLimit: l1GasLimit, l2GasLimit: tx.l2GasLimit!)
        
        if (options.gasPrice != nil) {
            fullCost.gasPrice = options.gasPrice
        } else {
            fullCost.maxFeePerGas = options.maxFeePerGas
            fullCost.maxPriorityFeePerGas = options.maxPriorityFeePerGas
        }
        
        return fullCost
    }
    
    public func estimateGasDeposit(transaction: DepositTransaction) async throws -> BigUInt {
        var tx = transaction
        if ZkSyncAddresses.isAddressEq(a: transaction.token, b: ZkSyncAddresses.LEGACY_ETH_ADDRESS){
            tx.token = ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS
        }
        
        let baseToken = try await getBaseToken()
        let isEthChain = try await isETHBasedChain()
        
        var prepared: Any
        if isEthChain && ZkSyncAddresses.isAddressEq(a: transaction.token, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS){
            prepared = try await _getDepositETHOnETHBasedChainTx(transaction: tx)
        } else if ZkSyncAddresses.isAddressEq(a: baseToken, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS){
            prepared = try await _getDepositTokenOnETHBasedChainTx(transaction: tx)
        } else if ZkSyncAddresses.isAddressEq(a: transaction.token, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS){
            prepared = try await _getDepositETHOnNonETHBasedChainTx(transaction: transaction).tx
        } else if ZkSyncAddresses.isAddressEq(a: transaction.token, b: baseToken){
            prepared = try await _getDepositBaseTokenOnNonETHBasedChainTx(transaction: transaction)
        } else {
            prepared = try await _getDepositNonBaseTokenToNonETHBasedChainTx(transaction: transaction).tx
        }
        
        let baseLimit: BigUInt
        if !tx.token.isEmpty && ZkSyncAddresses.isAddressEq(a: tx.token, b: baseToken){
            baseLimit = try await estimateGasRequestExecute(transaction: prepared as! RequestExecuteTransaction)!
        } else {
            baseLimit = try await ethClient.web3.eth.estimateGas(for: prepared as! CodableTransaction)
        }
        
        return Web3Utils.scaleGasLimit(gas: baseLimit)
    }
    
    public func deposit(transaction: DepositTransaction) async throws -> TransactionSendingResult {
        var tx = transaction
        if ZkSyncAddresses.isAddressEq(a: transaction.token, b: ZkSyncAddresses.LEGACY_ETH_ADDRESS){
            tx.token = ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS
        }
        
        let baseToken = try await getBaseToken()
        let isEthChain = try await isETHBasedChain()
        
        if isEthChain && ZkSyncAddresses.isAddressEq(a: tx.token, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS){
            return try await _depositETHToETHBasedChain(transaction: tx)
        } else if ZkSyncAddresses.isAddressEq(a: baseToken, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS){
            return try await _depositTokenToETHBasedChain(transaction: tx)
        } else if ZkSyncAddresses.isAddressEq(a: transaction.token, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS){
            return try await _depositETHToNonETHBasedChain(transaction: tx)
        } else if ZkSyncAddresses.isAddressEq(a: transaction.token, b: baseToken){
            return try await _depositBaseTokenToNonETHBasedChain(transaction: tx)
        } else {
            return try await _depositNonBaseTokenToNonETHBasedChain(transaction: tx)
        }
    }
    
    public func _depositNonBaseTokenToNonETHBasedChain(transaction: DepositTransaction) async throws -> TransactionSendingResult {
        let sharedBridge = try await getL1BridgeContracts().l1SharedDefaultBridge
        let baseToken = try await getBaseToken()
        
        let depositTx = try await _getDepositNonBaseTokenToNonETHBasedChainTx(transaction: transaction)
        var tx = depositTx.tx
        let mintValue = depositTx.mintValue
        
        if transaction.approveBaseERC20 ?? false{
            let allowance = try await getAllowanceL1(token: baseToken, bridgeAddress: sharedBridge)
            
            if allowance < mintValue {
                let result = try await approveERC20(token: baseToken, amount: mintValue, bridgeAddress: sharedBridge)
                _ = try! await ethClient.waitforTransactionReceipt(transactionHash: result.hash, timeout: 120, pollLatency: 0.5)
            }
            if transaction.options?.nonce == nil {
                tx.nonce = try await web.eth.getTransactionCount(for: tx.from!)
            }
        }
        
        if transaction.approveERC20 ?? false{
            let allowance = try await getAllowanceL1(token: transaction.token, bridgeAddress: sharedBridge)
            
            if allowance < transaction.amount {
                let result = try await approveERC20(token: transaction.token, amount: transaction.amount, bridgeAddress: sharedBridge)
                _ = try! await ethClient.waitforTransactionReceipt(transactionHash: result.hash, timeout: 120, pollLatency: 0.5)
            }
            if transaction.options?.nonce == nil {
                tx.nonce = try await web.eth.getTransactionCount(for: tx.from!)
            }
        }
        
        if transaction.options?.gasLimit == nil || transaction.options?.gasLimit == BigUInt.zero {
            let baseLimit = try await web.eth.estimateGas(for: tx)
            let gasLimit = Web3Utils.scaleGasLimit(gas: baseLimit)
            tx.gasLimit = gasLimit
        }
        
        signTransaction(transaction: &tx)
        return try await ethClient.web3.eth.send(raw: tx.encode()!)
    }
    
    public func _depositBaseTokenToNonETHBasedChain(transaction: DepositTransaction) async throws -> TransactionSendingResult {
        let sharedBridge = try await getL1BridgeContracts().l1SharedDefaultBridge
        let baseToken = try await getBaseToken()
        
        var tx = try await _getDepositBaseTokenOnNonETHBasedChainTx(transaction: transaction)
        
        if transaction.approveBaseERC20 ?? false || transaction.approveERC20 ?? false{
            let allowance = try await getAllowanceL1(token: baseToken, bridgeAddress: sharedBridge)
            
            if allowance < tx.mintValue! {
                let result = try await approveERC20(token: baseToken, amount: tx.mintValue, bridgeAddress: sharedBridge)
                _ = try! await ethClient.waitforTransactionReceipt(transactionHash: result.hash, timeout: 120, pollLatency: 0.5)
                if transaction.options?.nonce == nil {
                    tx.options?.nonce = try await web.eth.getTransactionCount(for: EthereumAddress(tx.from!)!)
                }
            }
        }
        
        if transaction.options?.gasLimit == nil || transaction.options?.gasLimit == BigUInt.zero {
            let baseLimit = try await estimateGasRequestExecute(transaction: tx)!
            let gasLimit = Web3Utils.scaleGasLimit(gas: baseLimit)
            tx.options?.gasLimit = gasLimit
        }
        
        return try await requestExecute(transaction: tx)
    }
    
    public func _depositETHToNonETHBasedChain(transaction: DepositTransaction) async throws -> TransactionSendingResult {
        let sharedBridge = try await getL1BridgeContracts().l1SharedDefaultBridge
        let baseToken = try await getBaseToken()
        
        let depositTx = try await _getDepositETHOnNonETHBasedChainTx(transaction: transaction)
        var tx = depositTx.tx
        let mintValue = depositTx.mintValue
        
        if transaction.approveBaseERC20 ?? false{
            let allowance = try await getAllowanceL1(token: baseToken, bridgeAddress: sharedBridge)
            
            if allowance < mintValue {
                let result = try await approveERC20(token: baseToken, amount: mintValue, bridgeAddress: sharedBridge)
                _ = try! await ethClient.waitforTransactionReceipt(transactionHash: result.hash, timeout: 120, pollLatency: 0.5)
                if transaction.options?.nonce == nil {
                    tx.nonce = try await web.eth.getTransactionCount(for: tx.from!)
                }
            }
        }
        
        if transaction.options?.gasLimit == nil || transaction.options?.gasLimit == BigUInt.zero {
            let baseLimit = try await web.eth.estimateGas(for: tx)
            let gasLimit = Web3Utils.scaleGasLimit(gas: baseLimit)
            tx.gasLimit = gasLimit
        }
        
        signTransaction(transaction: &tx)
        return try await ethClient.web3.eth.send(raw: tx.encode()!)
    }
    
    public func _depositTokenToETHBasedChain(transaction: DepositTransaction) async throws -> TransactionSendingResult {
        let bridgeAddresses = try await getL1BridgeContracts()
        var tx = try await _getDepositTokenOnETHBasedChainTx(transaction: transaction)
        
        if transaction.approveERC20 ?? false{
            let proposedBridge = bridgeAddresses.l1SharedDefaultBridge
            let bridgeAddress = transaction.bridgeAddress ?? proposedBridge
            
            let allowance = try await getAllowanceL1(token: transaction.token, bridgeAddress: bridgeAddress)
            
            if allowance < transaction.amount {
                let result = try await approveERC20(token: transaction.token, amount: transaction.amount, bridgeAddress: bridgeAddress)
                _ = try! await ethClient.waitforTransactionReceipt(transactionHash: result.hash, timeout: 120, pollLatency: 0.5)
                if transaction.options?.nonce == nil {
                    tx.nonce = try await web.eth.getTransactionCount(for: tx.from!)
                }
            }
        }
        
        if transaction.options?.gasLimit == nil || transaction.options?.gasLimit == BigUInt.zero {
            let baseLimit = try await web.eth.estimateGas(for: tx)
            let gasLimit = Web3Utils.scaleGasLimit(gas: baseLimit)
            tx.gasLimit = gasLimit
        }
        
        signTransaction(transaction: &tx)
        return try await ethClient.web3.eth.send(raw: tx.encode()!)
    }
    
    public func _depositETHToETHBasedChain(transaction: DepositTransaction) async throws -> TransactionSendingResult {
        var tx = try await _getDepositETHOnETHBasedChainTx(transaction: transaction)
        
        if tx.options?.gasLimit == nil || tx.options?.gasLimit == BigUInt.zero {
            let baseLimit = try await estimateGasRequestExecute(transaction: tx)!
            let gasLimit = Web3Utils.scaleGasLimit(gas: baseLimit)
            tx.options?.gasLimit = gasLimit
        }
        
        return try await requestExecute(transaction: tx)
    }
    
    public func _getDepositNonBaseTokenToNonETHBasedChainTx(transaction: DepositTransaction) async throws -> GetDepositTransaction {
        let chainID = try await zkSync.chainID()
        let sharedBridge = try await getL1BridgeContracts().l1SharedDefaultBridge
        
        var tx = try await _getDepositTxWithDefaults(transaction: transaction)
        
        let gasPriceForEstimation = tx.options?.maxFeePerGas ?? tx.options?.gasPrice
        let baseCost = try await baseCost(tx.l2GasLimit!, gasPrice: gasPriceForEstimation)["0"] as! BigUInt
        
        let mintValue = baseCost + tx.operatorTip!
        tx.options?.value = 0
        
        let tuple: [AnyObject] = [
            chainID,
            mintValue,
            BigUInt.zero,
            tx.l2GasLimit!,
            tx.gasPerPubdataByte!,
            tx.refundRecipient!,
            sharedBridge,
            0,
            ABIEncoder.encode(types: [ABI.Element.ParameterType.address, ABI.Element.ParameterType.uint(bits: 256), ABI.Element.ParameterType.address], values: [tx.token, tx.amount, tx.to!])!
        ] as [AnyObject]
        let parameters: [AnyObject] = [tuple as AnyObject]
        
        var prepared = CodableTransaction.createEthCallTransaction(from: EthereumAddress((tx.options?.from)!)!, to: EthereumAddress(tx.to!)!, data: Data(hex: "0x"))
        await insertOptions(transaction: &prepared, options: tx.options)
        if tx.options?.gasLimit == 0 || tx.options?.gasLimit == nil{
            prepared.gasLimit = 0
        }
        
        let bridgehub = try await getBridgehubContract(transaction: prepared)
        
        prepared = bridgehub.createWriteOperation("requestL2TransactionTwoBridges", parameters: parameters)!.transaction
        prepared.chainID = try await ethClient.chainID()
        
        return GetDepositTransaction(tx: prepared, mintValue: mintValue)
    }
    
    public func _getDepositBaseTokenOnNonETHBasedChainTx(transaction: DepositTransaction) async throws -> RequestExecuteTransaction {
        var tx = try await _getDepositTxWithDefaults(transaction: transaction)
        
        let gasPriceForEstimation = tx.options?.maxFeePerGas ?? tx.options?.gasPrice
        let baseCost = try await baseCost(tx.l2GasLimit!, gasPrice: gasPriceForEstimation)["0"] as! BigUInt
        
        tx.options?.value = 0
        let mintValue = baseCost + tx.operatorTip! + tx.amount
        
        return RequestExecuteTransaction(contractAddress: tx.to!, calldata: Data(hex: "0x"), from: tx.options?.from, l2Value: tx.amount, mintValue: mintValue, l2GasLimit: tx.l2GasLimit, operatorTip: tx.operatorTip, gasPerPubdataByte: tx.gasPerPubdataByte, refundRecipient: tx.refundRecipient, options: tx.options)
    }
    
    public func _getDepositETHOnNonETHBasedChainTx(transaction: DepositTransaction) async throws -> GetDepositTransaction {
        let chainID = try await zkSync.chainID()
        let sharedBridge = try await getL1BridgeContracts().l1SharedDefaultBridge
        
        var tx = try await _getDepositTxWithDefaults(transaction: transaction)
        
        let gasPriceForEstimation = tx.options?.maxFeePerGas ?? tx.options?.gasPrice
        let baseCost = try await baseCost(tx.l2GasLimit!, gasPrice: gasPriceForEstimation)["0"] as! BigUInt
        
        tx.options!.value = tx.options?.value ?? tx.amount
        let mintValue = baseCost + tx.operatorTip!

        let tuple: [AnyObject] = [
            chainID,
            mintValue,
            BigUInt.zero,
            tx.l2GasLimit!,
            tx.gasPerPubdataByte!,
            tx.refundRecipient!,
            sharedBridge,
            tx.amount,
            ABIEncoder.encode(types: [ABI.Element.ParameterType.address, ABI.Element.ParameterType.uint(bits: 256), ABI.Element.ParameterType.address], values: [ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS, BigUInt.zero, tx.to!])!
        ] as [AnyObject]
        let parameters: [AnyObject] = [tuple as AnyObject]
        
        var prepared = CodableTransaction.createEthCallTransaction(from: EthereumAddress((tx.options?.from)!)!, to: EthereumAddress(tx.to!)!, data: Data(hex: "0x"))
        await insertOptions(transaction: &prepared, options: tx.options)
        if tx.options?.gasLimit == 0 || tx.options?.gasLimit == nil{
            prepared.gasLimit = 0
        }
        
        let bridgehub = try await getBridgehubContract(transaction: prepared)
        
        prepared = bridgehub.createWriteOperation("requestL2TransactionTwoBridges", parameters: parameters)!.transaction
        prepared.chainID = try await ethClient.chainID()
        
        return GetDepositTransaction(tx: prepared, mintValue: mintValue)
    }
    
    public func _getDepositTokenOnETHBasedChainTx(transaction: DepositTransaction) async throws -> CodableTransaction {
        let chainID = try await zkSync.chainID()
        
        var tx = try await _getDepositTxWithDefaults(transaction: transaction)
        
        let gasPriceForEstimation = tx.options?.maxFeePerGas ?? tx.options?.gasPrice
        let baseCost = try await baseCost(tx.l2GasLimit!, gasPrice: gasPriceForEstimation)["0"] as! BigUInt
        
        let mintValue = baseCost + tx.operatorTip!
        tx.options!.value = tx.options?.value ?? mintValue
        
        var secondBridgeAddress: String
        var secondBridgeCalldata: Data
        if (tx.bridgeAddress != nil) {
            secondBridgeAddress = tx.bridgeAddress!;
            secondBridgeCalldata = await Web3Utils.getERC20DefaultBridgeData(l1TokenAddress: tx.token, provider: ethClient.web3)!
        } else {
          secondBridgeAddress = try await getL1BridgeContracts().l1SharedDefaultBridge
            secondBridgeCalldata = ABIEncoder.encode(types: [ABI.Element.ParameterType.address, ABI.Element.ParameterType.uint(bits: 256), ABI.Element.ParameterType.address], values: [tx.token, tx.amount, tx.to!])!
        }
        
        let tuple: [AnyObject] = [
            chainID,
            mintValue,
            BigUInt.zero,
            tx.l2GasLimit!,
            tx.gasPerPubdataByte!,
            tx.refundRecipient!,
            secondBridgeAddress,
            BigUInt.zero,
            secondBridgeCalldata
        ] as [AnyObject]
        let parameters: [AnyObject] = [tuple as AnyObject]
        
        var prepared = CodableTransaction.createEthCallTransaction(from: EthereumAddress((tx.options?.from)!)!, to: EthereumAddress(tx.to!)!, data: Data(hex: "0x"))
        await insertOptions(transaction: &prepared, options: tx.options)
        if tx.options?.gasLimit == 0 || tx.options?.gasLimit == nil{
            prepared.gasLimit = 0
        }
        
        let bridgehub = try await getBridgehubContract(transaction: prepared)
        
        prepared = bridgehub.createWriteOperation("requestL2TransactionTwoBridges", parameters: parameters)!.transaction
        prepared.chainID = try await ethClient.chainID()
        
        return prepared
    }
    
    public func _getDepositETHOnETHBasedChainTx(transaction: DepositTransaction) async throws -> RequestExecuteTransaction {
        var tx = try await _getDepositTxWithDefaults(transaction: transaction)
        
        let gasPriceForEstimation = tx.options?.maxFeePerGas ?? tx.options?.gasPrice
        let baseCost = try await baseCost(tx.l2GasLimit!, gasPrice: gasPriceForEstimation)["0"] as! BigUInt
        
        tx.options?.value = baseCost + tx.operatorTip! + tx.amount
        
        return RequestExecuteTransaction(contractAddress: tx.to!, calldata: Data(hex: "0x"), from: tx.options?.from, l2Value: tx.amount, mintValue: baseCost + tx.operatorTip! + tx.amount, l2GasLimit: tx.l2GasLimit, operatorTip: tx.operatorTip, gasPerPubdataByte: tx.gasPerPubdataByte, refundRecipient: tx.refundRecipient, options: tx.options)
    }
    
    public func _getDepositTxWithDefaults(transaction: DepositTransaction) async throws -> DepositTransaction {
        var tx = transaction
        let address = try! await self.getAddress()
        if tx.to == nil {
            tx.to = address
        }
        tx.operatorTip = tx.operatorTip ?? BigUInt(0)
        tx.options = await Web3Utils.insertGasPrice(options: tx.options, provider: ethClient)
        if tx.options?.from == nil {
            tx.options?.from = address
        }
        if tx.options?.chainID == nil{
            tx.options?.chainID = try await ethClient.chainID()
        }
        tx.refundRecipient = tx.refundRecipient ?? address
        tx.gasPerPubdataByte = tx.gasPerPubdataByte ?? BigUInt(800)
        tx.l2GasLimit = try await _getL2GasLimit(transaction: tx)
        
        return tx
    }
    
    public func _getL2GasLimitFromCustomBridge(transaction: DepositTransaction) async throws -> BigUInt {
        var customBridgeData: Data
        if let txCustomBridgeData = transaction.customBridgeData {
            customBridgeData = txCustomBridgeData
        } else {
            customBridgeData = await Web3Utils.getERC20DefaultBridgeData(l1TokenAddress: transaction.token, provider: ethClient.web3)!
        }
        
        let bridge = web.contract(Web3.Utils.IL1Bridge, at: EthereumAddress(transaction.bridgeAddress!))
        let l2Address = try! await bridge!.createReadOperation("l2BridgeAddress", parameters: [])!.callContractMethod()["0"] as! EthereumAddress
        
        return try await Web3Utils.estimateCustomBridgeDepositL2Gas(provider: zkSync, l1BridgeAddress: EthereumAddress(transaction.bridgeAddress!)!, l2BridgeAddress: l2Address, token: EthereumAddress(transaction.token)!, amount: transaction.amount, to: EthereumAddress(transaction.to!)!, bridgeData: customBridgeData, from: EthereumAddress((transaction.options?.from)!)!)
    }
    
    public func _getL2GasLimit(transaction: DepositTransaction) async throws -> BigUInt {
        if transaction.bridgeAddress != nil {
            return try await _getL2GasLimitFromCustomBridge(transaction: transaction)
        }
        
        return try await Web3Utils.estimateDefaultBridgeDepositL2Gas(providerL1: ethClient.web3, providerL2: zkSync, token: transaction.token, amount: transaction.amount, to: transaction.to!, from: transaction.options!.from!, gasPerPubDataByte: transaction.gasPerPubdataByte!)
    }
}
