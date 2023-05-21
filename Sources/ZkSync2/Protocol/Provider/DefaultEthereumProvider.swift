//
//  DefaultEthereumProvider.swift
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
import web3swift_zksync
#endif

extension DefaultEthereumProvider {
    
    enum EthereumProviderError: Error {
        case invalidAddress
        case invalidToken
        case invalidParameter
        case internalError
    }
}

class DefaultEthereumProvider: EthereumProvider {
    
    static let MaxApproveAmount = BigUInt.two.power(256).subtracting(BigUInt.one)
    static let DefaultThreshold = BigUInt.two.power(255)
    
    let web3: web3
    
    var l1ERC20Bridge: web3.web3contract!
    
    var l1ERC20BridgeAddress: String {
        return l1ERC20Bridge.contract.address!.address
    }
    
    var zkSyncContract: web3.web3contract!
    
    var mainContractAddress: String {
        return zkSyncContract.contract.address!.address
    }
    
    let gasProvider: ContractGasProvider
    
    let gasLimits: Dictionary<String, BigUInt> = [
        "0x0000000000095413afc295d19edeb1ad7b71c952": BigUInt(140000),
        "0xeb4c2781e4eba804ce9a9803c67d0893436bb27d": BigUInt(160000),
        "0xbbbbca6a901c926f240b89eacb641d8aec7aeafd": BigUInt(140000),
        "0xb64ef51c888972c908cfacf59b47c1afbc0ab8ac": BigUInt(140000),
        "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984": BigUInt(150000),
        "0x9ba00d6856a4edf4665bca2c2309936572473b7e": BigUInt(270000),
        "0x8daebade922df735c38c80c7ebd708af50815faa": BigUInt(140000),
        "0x0d8775f648430679a709e98d2b0cb6250d2887ef": BigUInt(140000),
        "0xdac17f958d2ee523a2206206994597c13d831ec7": BigUInt(140000),
        "0x6de037ef9ad2725eb40118bb1702ebb27e4aeb24": BigUInt(150000),
        "0x056fd409e1d7a124bd7017459dfea2f387b6d5cd": BigUInt(180000),
        "0x0f5d2fb29fb7d3cfee444a200298f468908cc942": BigUInt(140000),
        "0x514910771af9ca656af840dff83e8264ecf986ca": BigUInt(140000),
        "0x1985365e9f78359a9b6ad760e32412f4a445e862": BigUInt(180000),
        "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599": BigUInt(140000),
        "0xe41d2489571d322189246dafa5ebde1f4699f498": BigUInt(140000),
        "0x6b175474e89094c44da98b954eedeac495271d0f": BigUInt(140000),
        "0xaaaebe6fe48e54f431b0c390cfaf0b017d09d42d": BigUInt(150000),
        "0x2b591e99afe9f32eaa6214f7b7629768c40eeb39": BigUInt(140000),
        "0x65ece136b89ebaa72a7f7aa815674946e44ca3f9": BigUInt(140000),
        "0x0000000000085d4780b73119b644ae5ecd22b376": BigUInt(150000),
        "0xdb25f211ab05b1c97d595516f45794528a807ad8": BigUInt(180000),
        "0x408e41876cccdc0f92210600ef50372656052a38": BigUInt(140000),
        "0x15a2b3cfafd696e1c783fe99eed168b78a3a371e": BigUInt(160000),
        "0x38e4adb44ef08f22f5b5b76a8f0c2d0dcbe7dca1": BigUInt(160000),
        "0x3108ccfd96816f9e663baa0e8c5951d229e8c6da": BigUInt(140000),
        "0x56d811088235f11c8920698a204a5010a788f4b3": BigUInt(240000),
        "0x57ab1ec28d129707052df4df418d58a2d46d5f51": BigUInt(220000),
        "0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2": BigUInt(140000),
        "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48": BigUInt(150000),
        "0xc011a73ee8576fb46f5e1c5751ca3b9fe0af2a6f": BigUInt(200000),
        "0x744d70fdbe2ba4cf95131626614a1763df805b9e": BigUInt(230000),
        "0x0bc529c00c6401aef6d220be8c6ea1667f6ad93e": BigUInt(140000),
        "0x4c7065bca76fe44afb0d16c2441b1e6e163354e2": BigUInt(250000),
        "0xdd974d5c2e2928dea5f71b9825b8b646686bd200": BigUInt(140000),
        "0x80fb784b7ed66730e8b1dbd9820afd29931aab03": BigUInt(140000),
        "0xd56dac73a4d6766464b38ec6d91eb45ce7457c44": BigUInt(140000),
        "0x4fabb145d64652a948d72533023f6e7a623c7c53": BigUInt(150000),
        "0x38a2fdc11f526ddd5a607c1f251c065f40fbf2f7": BigUInt(140000),
        "0x7dd9c5cba05e151c895fde1cf355c9a1d5da6429": BigUInt(140000),
    ]
    
    let l1ToL2GasPerPubData = BigUInt(800)
    
    init(_ web3: web3,
         l1ERC20Bridge: web3.web3contract,
         zkSyncContract: web3.web3contract,
         gasProvider: ContractGasProvider) {
        self.web3 = web3
        self.l1ERC20Bridge = l1ERC20Bridge
        self.zkSyncContract = zkSyncContract
        self.gasProvider = gasProvider
    }
    
    func gasPrice() throws -> BigUInt {
        return try web3.eth.getGasPrice()
    }
    
    func approveDeposits(with token: Token,
                         limit: BigUInt?) throws -> Promise<TransactionSendingResult> {
        guard let tokenAddress = EthereumAddress(token.l1Address),
              let spenderAddress = EthereumAddress(l1ERC20BridgeAddress) else {
                  throw EthereumProviderError.invalidToken
              }
        
        let tokenContract = ERC20(web3: web3,
                                  provider: web3.provider,
                                  address: tokenAddress)
        
        let maxApproveAmount = BigUInt.two.power(256) - 1
        let amount = limit?.description ?? maxApproveAmount.description
        
        do {
            let transaction = try tokenContract.approve(from: spenderAddress,
                                                        spender: spenderAddress,
                                                        amount: amount)
            return transaction.sendPromise()
        } catch {
            return .init(error: error)
        }
    }
    
    func transfer(with token: Token,
                  amount: BigUInt,
                  to address: String) throws -> Promise<TransactionSendingResult> {
        let transaction: WriteTransaction
        do {
            if token.isETH {
                transaction = try transferEth(amount: amount,
                                              to: address)
            } else {
                transaction = try transferERC20(token: token,
                                                amount: amount,
                                                to: address)
            }
            
            return transaction.sendPromise()
        } catch {
            return .init(error: error)
        }
    }
    
    func transferEth(amount: BigUInt,
                     to address: String) throws -> WriteTransaction {
        guard let fromAddress = EthereumAddress(l1ERC20BridgeAddress),
              let toAddress = EthereumAddress(address) else {
                  throw EthereumProviderError.invalidAddress
              }
        
        guard let transaction = web3.eth.sendETH(from: fromAddress,
                                                 to: toAddress,
                                                 amount: amount.description,
                                                 units: .wei) else {
            throw EthereumProviderError.internalError
        }
        
        return transaction
    }
    
    func transferERC20(token: Token,
                       amount: BigUInt,
                       to address: String) throws -> WriteTransaction {
        guard let fromAddress = EthereumAddress(l1ERC20BridgeAddress),
              let toAddress = EthereumAddress(address),
              let erc20ContractAddress = EthereumAddress(token.l1Address) else {
                  throw EthereumProviderError.invalidToken
              }
        
        guard let transaction = web3.eth.sendERC20tokensWithKnownDecimals(tokenAddress: erc20ContractAddress,
                                                                          from: fromAddress,
                                                                          to: toAddress,
                                                                          amount: amount) else {
            throw EthereumProviderError.internalError
        }
        
        return transaction
    }
    
    //    {
    //        "inputs": [
    //            {
    //                "internalType": "address",
    //                "name": "_contractL2",
    //                "type": "address"
    //            },
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2Value",
    //                "type": "uint256"
    //            },
    //            {
    //                "internalType": "bytes",
    //                "name": "_calldata",
    //                "type": "bytes"
    //            },
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2GasLimit",
    //                "type": "uint256"
    //            },
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2GasPerPubdataByteLimit",
    //                "type": "uint256"
    //            },
    //            {
    //                "internalType": "bytes[]",
    //                "name": "_factoryDeps",
    //                "type": "bytes[]"
    //            },
    //            {
    //                "internalType": "address",
    //                "name": "_refundRecipient",
    //                "type": "address"
    //            }
    //        ],
    //        "name": "requestL2Transaction",
    //        "outputs": [
    //            {
    //                "internalType": "bytes32",
    //                "name": "canonicalTxHash",
    //                "type": "bytes32"
    //            }
    //        ],
    //        "stateMutability": "payable",
    //        "type": "function"
    //    }
    func requestExecute(_ contractAddress: String,
                        l2Value: BigUInt,
                        calldata: Data,
                        gasLimit: BigUInt,
                        factoryDeps: [Data]?,
                        operatorTips: BigUInt?,
                        gasPrice: BigUInt?,
                        refundRecipient: String) throws -> Promise<TransactionSendingResult> {
        var gasPrice = gasPrice
        if gasPrice == nil {
            gasPrice = try! web3.eth.getGasPrice()
        }
        
        guard let baseCost = try getBaseCost(gasLimit, gasPrice: gasPrice).wait()["0"] as? BigUInt else {
            return Promise(error: EthereumProviderError.invalidParameter)
        }
        
        var parameters = [
            EthereumAddress(contractAddress)!,
            l2Value,
            calldata,
            gasLimit,
            l1ToL2GasPerPubData
        ] as [AnyObject]
        
        let bytesArr: [Data] = factoryDeps?.compactMap({ $0 }) ?? []
        parameters.append(bytesArr as AnyObject)
        
        parameters.append(EthereumAddress(contractAddress)! as AnyObject)
        
        let operatorTipsValue: BigUInt
        if let operatorTips = operatorTips {
            operatorTipsValue = operatorTips
        } else {
            operatorTipsValue = BigUInt.zero
        }
        
        let totalValue = l2Value + baseCost + operatorTipsValue
        
//        parameters.append(totalValue as AnyObject)
        
        let nonce = try! self.web3.eth.getTransactionCountPromise(address: EthereumAddress(contractAddress)!).wait()
        
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .legacy
        transactionOptions.from = EthereumAddress(contractAddress)!
        transactionOptions.to = zkSyncContract.contract.address
//        if let nonce = nonce {
            transactionOptions.nonce = .manual(nonce)
//        }
        transactionOptions.gasLimit = .manual(gasLimit)
        transactionOptions.gasPrice = .manual(gasPrice!)
//        transactionOptions.maxPriorityFeePerGas = .manual(gasPrice!)
        transactionOptions.value = totalValue
        transactionOptions.chainID = self.web3.provider.network?.chainID
        
        guard let transaction = zkSyncContract.write("requestL2Transaction",
                                                     parameters: parameters,
                                                     transactionOptions: transactionOptions) else {
            return Promise(error: EthereumProviderError.invalidParameter)
        }
        
        return transaction.sendPromise()
    }
    
    func deposit(with token: Token,
                 amount: BigUInt,
                 operatorTips: BigUInt,
                 to userAddress: String) throws -> Promise<TransactionSendingResult> {
        if token.isETH {
            let gasLimit = BigUInt(10000000)
            
            return try requestExecute(userAddress,
                                      l2Value: amount,
                                      calldata: Data(),
                                      gasLimit: gasLimit,
                                      factoryDeps: nil,
                                      operatorTips: operatorTips,
                                      gasPrice: nil,
                                      refundRecipient: userAddress)
        } else {
            let baseCost = BigUInt.zero
            let gasLimit = gasLimits[token.l1Address, default: BigUInt(300000)]
            let totalAmount = operatorTips + baseCost
            
            let parameters = [
                userAddress,
                token.l1Address,
                gasLimit,
                l1ToL2GasPerPubData,
                amount,
                totalAmount
            ] as [AnyObject]
            
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.to = EthereumAddress(userAddress)!
            
            guard let transaction = l1ERC20Bridge.write("deposit",
                                                        parameters: parameters,
                                                        transactionOptions: transactionOptions) else {
                return Promise(error: EthereumProviderError.invalidParameter)
            }
            
            return transaction.sendPromise()
        }
    }
    
    func withdraw(with token: Token,
                  amount: BigUInt,
                  from userAddress: String) throws -> Promise<TransactionSendingResult> {
        throw EthereumProviderError.internalError
    }
    
    func isDepositApproved(with token: Token,
                           address: String,
                           threshold: BigUInt?) throws -> Bool {
        guard let tokenAddress = EthereumAddress(token.l1Address),
              let ownerAddress = EthereumAddress(address),
              let spenderAddress = EthereumAddress(l1ERC20BridgeAddress) else {
                  throw EthereumProviderError.invalidToken
              }
        
        let tokenContract = ERC20(web3: web3,
                                  provider: web3.provider,
                                  address: tokenAddress)
        
        let allowance = try tokenContract.getAllowance(originalOwner: ownerAddress,
                                                       delegate: spenderAddress)
        
        return allowance > (threshold ?? DefaultEthereumProvider.DefaultThreshold)
    }
    
    //    {
    //        "inputs": [
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2BlockNumber",
    //                "type": "uint256"
    //            },
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2MessageIndex",
    //                "type": "uint256"
    //            },
    //            {
    //                "internalType": "uint16",
    //                "name": "_l2TxNumberInBlock",
    //                "type": "uint16"
    //            },
    //            {
    //                "internalType": "bytes",
    //                "name": "_message",
    //                "type": "bytes"
    //            },
    //            {
    //                "internalType": "bytes32[]",
    //                "name": "_merkleProof",
    //                "type": "bytes32[]"
    //            }
    //        ],
    //        "name": "finalizeEthWithdrawal",
    //        "outputs": [],
    //        "stateMutability": "nonpayable",
    //        "type": "function"
    //    }
    public func finalizeEthWithdrawal(_ l2BlockNumber: BigUInt,
                                      l2MessageIndex: BigUInt,
                                      l2TxNumberInBlock: UInt,
                                      message: Data,
                                      proof: [Data]) -> Promise<TransactionSendingResult> {
        let parameters = [
            l2BlockNumber,
            l2MessageIndex,
            l2TxNumberInBlock,
            message,
            proof
        ] as [AnyObject]
        
        guard let transaction = zkSyncContract.write("finalizeEthWithdrawal",
                                                     parameters: parameters,
                                                     transactionOptions: nil) else {
            return Promise(error: EthereumProviderError.invalidParameter)
        }
        
        return transaction.sendPromise()
    }
    
    //    {
    //        "inputs": [
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2BlockNumber",
    //                "type": "uint256"
    //            },
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2MessageIndex",
    //                "type": "uint256"
    //            },
    //            {
    //                "internalType": "uint16",
    //                "name": "_l2TxNumberInBlock",
    //                "type": "uint16"
    //            },
    //            {
    //                "internalType": "bytes",
    //                "name": "_message",
    //                "type": "bytes"
    //            },
    //            {
    //                "internalType": "bytes32[]",
    //                "name": "_merkleProof",
    //                "type": "bytes32[]"
    //            }
    //        ],
    //        "name": "finalizeWithdrawal",
    //        "outputs": [],
    //        "stateMutability": "nonpayable",
    //        "type": "function"
    //    }
    func finalizeWithdrawal(_ l1BridgeAddress: String,
                            l2BlockNumber: BigUInt,
                            l2MessageIndex: BigUInt,
                            l2TxNumberInBlock: UInt,
                            message: Data,
                            proof: [Data]) -> Promise<TransactionSendingResult> {
        let l1Bridge = web3.contract(Web3.Utils.IL1Bridge,
                                     at: EthereumAddress(l1BridgeAddress))!
        
        let parameters = [
            l2BlockNumber,
            l2MessageIndex,
            l2TxNumberInBlock,
            message,
            proof
        ] as [AnyObject]
        
        guard let writeTransaction = l1Bridge.write("finalizeWithdrawal",
                                                    parameters: parameters,
                                                    transactionOptions: nil) else {
            return Promise(error: EthereumProviderError.invalidParameter)
        }
        
        guard let encodedTransaction = writeTransaction.transaction.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }
        
        print("Encoded transaction: \(encodedTransaction.toHexString().addHexPrefix())")
        
        return writeTransaction.sendPromise()
    }
    
    //    {
    //        "inputs": [
    //            {
    //                "internalType": "address",
    //                "name": "_depositSender",
    //                "type": "address"
    //            },
    //            {
    //                "internalType": "address",
    //                "name": "_l1Token",
    //                "type": "address"
    //            },
    //            {
    //                "internalType": "bytes32",
    //                "name": "_l2TxHash",
    //                "type": "bytes32"
    //            },
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2BlockNumber",
    //                "type": "uint256"
    //            },
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2MessageIndex",
    //                "type": "uint256"
    //            },
    //            {
    //                "internalType": "uint16",
    //                "name": "_l2TxNumberInBlock",
    //                "type": "uint16"
    //            },
    //            {
    //                "internalType": "bytes32[]",
    //                "name": "_merkleProof",
    //                "type": "bytes32[]"
    //            }
    //        ],
    //        "name": "claimFailedDeposit",
    //        "outputs": [],
    //        "stateMutability": "nonpayable",
    //        "type": "function"
    //    }
    func claimFailedDeposit(_ l1BridgeAddress: String,
                            depositSender: String,
                            l1Token: String,
                            l2TxHash: Data,
                            l2BlockNumber: BigUInt,
                            l2MessageIndex: BigUInt,
                            l2TxNumberInBlock: UInt,
                            proof: [Data]) -> Promise<TransactionSendingResult> {
        let l1Bridge = web3.contract(Web3.Utils.IL1Bridge,
                                     at: EthereumAddress(l1BridgeAddress))!
        
        let parameters = [
            depositSender,
            l1Token,
            l2TxHash,
            l2BlockNumber,
            l2MessageIndex,
            l2TxNumberInBlock,
            proof
        ] as [AnyObject]
        
        guard let writeTransaction = l1Bridge.write("claimFailedDeposit",
                                                    parameters: parameters,
                                                    transactionOptions: nil) else {
            return Promise(error: EthereumProviderError.invalidParameter)
        }
        
        guard let encodedTransaction = writeTransaction.transaction.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }
        
        print("Encoded transaction: \(encodedTransaction.toHexString().addHexPrefix())")
        
        return writeTransaction.sendPromise()
    }
    
    //    {
    //        "inputs": [
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2BlockNumber",
    //                "type": "uint256"
    //            },
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2MessageIndex",
    //                "type": "uint256"
    //            }
    //        ],
    //        "name": "isEthWithdrawalFinalized",
    //        "outputs": [
    //            {
    //                "internalType": "bool",
    //                "name": "",
    //                "type": "bool"
    //            }
    //        ],
    //        "stateMutability": "view",
    //        "type": "function"
    //    }
    func isEthWithdrawalFinalized(_ l2BlockNumber: BigUInt,
                                  l2MessageIndex: BigUInt) -> Promise<[String: Any]> {
        let parameters = [
            l2BlockNumber,
            l2MessageIndex
        ] as [AnyObject]
        
        guard let readTransaction = zkSyncContract.read("isEthWithdrawalFinalized",
                                                        parameters: parameters,
                                                        transactionOptions: nil) else {
            return Promise(error: EthereumProviderError.invalidParameter)
        }
        
        guard let encodedTransaction = readTransaction.transaction.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }
        
        print("Encoded transaction: \(encodedTransaction.toHexString().addHexPrefix())")
        
        return readTransaction.callPromise()
    }
    
    //    {
    //        "inputs": [
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2BlockNumber",
    //                "type": "uint256"
    //            },
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2MessageIndex",
    //                "type": "uint256"
    //            }
    //        ],
    //        "name": "isWithdrawalFinalized",
    //        "outputs": [
    //            {
    //                "internalType": "bool",
    //                "name": "",
    //                "type": "bool"
    //            }
    //        ],
    //        "stateMutability": "view",
    //        "type": "function"
    //    }
    func isWithdrawalFinalized(_ l1BridgeAddress: String,
                               l2BlockNumber: BigUInt,
                               l2MessageIndex: BigInt) -> Promise<[String: Any]> {
        let l1Bridge = web3.contract(Web3.Utils.IL1Bridge,
                                     at: EthereumAddress(l1BridgeAddress))!
        
        let parameters = [
            l2BlockNumber,
            l2MessageIndex
        ] as [AnyObject]
        
        guard let readTransaction = l1Bridge.read("isWithdrawalFinalized",
                                                  parameters: parameters,
                                                  transactionOptions: nil) else {
            return Promise(error: EthereumProviderError.invalidParameter)
        }
        
        guard let encodedTransaction = readTransaction.transaction.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }
        
        print("Encoded transaction: \(encodedTransaction.toHexString().addHexPrefix())")
        
        return readTransaction.callPromise()
    }
    
    //    {
    //        "inputs": [
    //            {
    //                "internalType": "uint256",
    //                "name": "_gasPrice",
    //                "type": "uint256"
    //            },
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2GasLimit",
    //                "type": "uint256"
    //            },
    //            {
    //                "internalType": "uint256",
    //                "name": "_l2GasPerPubdataByteLimit",
    //                "type": "uint256"
    //            }
    //        ],
    //        "name": "l2TransactionBaseCost",
    //        "outputs": [
    //            {
    //                "internalType": "uint256",
    //                "name": "",
    //                "type": "uint256"
    //            }
    //        ],
    //        "stateMutability": "view",
    //        "type": "function"
    //    }
    func getBaseCost(_ gasLimit: BigUInt,
                     gasPerPubdataByte: BigUInt = BigUInt(50000),
                     gasPrice: BigUInt?) -> Promise<[String: Any]> {
        var gasPrice = gasPrice
        if gasPrice == nil {
            gasPrice = try! web3.eth.getGasPrice()
        }
        
        let parameters = [
            gasPrice,
            gasLimit,
            gasPerPubdataByte
        ] as [AnyObject]
        
        guard let transaction = zkSyncContract.read("l2TransactionBaseCost",
                                                    parameters: parameters,
                                                    transactionOptions: nil) else {
            return Promise(error: EthereumProviderError.invalidParameter)
        }
        
        return transaction.callPromise()
    }
}

extension DefaultEthereumProvider {
    
    static func load(_ zkSync: ZkSync,
                     web3: web3,
                     gasProvider: ContractGasProvider) -> Promise<DefaultEthereumProvider> {
        Promise { seal in
            zkSync.zksGetBridgeContracts { result in
                switch result {
                case .success(let bridgeAddresses):
                    zkSync.zksMainContract { result in
                        switch result {
                        case .success(let mainContractAddress):
                            let erc20Bridge = web3.contract(Web3.Utils.IL1Bridge,
                                                            at: EthereumAddress(bridgeAddresses.l1Erc20DefaultBridge))!
                            
                            let mainContract = web3.contract(Web3.Utils.IZkSync,
                                                             at: EthereumAddress(mainContractAddress))!
                            
                            let defaultEthereumProvider = DefaultEthereumProvider(web3,
                                                                                  l1ERC20Bridge: erc20Bridge,
                                                                                  zkSyncContract: mainContract,
                                                                                  gasProvider: gasProvider)
                            
                            return seal.resolve(.fulfilled(defaultEthereumProvider))
                        case .failure(let error):
                            return seal.resolve(.rejected(error))
                        }
                    }
                case .failure(let error):
                    return seal.resolve(.rejected(error))
                }
            }
        }
    }
}
