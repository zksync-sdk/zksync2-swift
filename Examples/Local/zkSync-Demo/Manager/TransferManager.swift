//
//  TransferManager.swift
//  zkSync-Demo
//
//  Created by Bojan on 14.5.23..
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync
#endif

class TransferManager: BaseManager {
    func transferViaWallet(callback: (() -> Void)) {
        let gasPrice = try! zkSync.web3.eth.getGasPrice()
        
        print("gasPrice:", gasPrice)
        
        let amount = BigUInt(1000000000000)
        
        let transactionSendingResult = try! wallet.transfer("0xa61464658AfeAf65CccaaFD3a512b69A83B77618", amount: amount).wait()
        
        // You can check balance
        let balance = try! wallet.getBalance().wait()
        
        // Also, you can convert amount number to decimal
        let decimalBalance = Token.ETH.intoDecimal(balance)
        
        callback()
    }
    
    func transfer(callback: (() -> Void)) {
        let value: BigUInt = 1
        
        let amountInWei = Web3.Utils.parseToBigUInt("1", units: .eth)!
        
        let nonce = try! zkSync.web3.eth.getTransactionCountPromise(address: EthereumAddress(signer.address)!, onBlock: ZkBlockParameterName.committed.rawValue).wait()
        
        var estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: EthereumAddress("0xa61464658AfeAf65CccaaFD3a512b69A83B77618")!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: Data(hex: "0x"))
        
        let fee = try! (zkSync as! JsonRpc2_0ZkSync).zksEstimateFee(estimate).wait()
        
        let gasPrice = try! zkSync.web3.eth.getGasPricePromise().wait()
        
        estimate.parameters.EIP712Meta?.gasPerPubdata = fee.gasPerPubdataLimit
        
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.from = EthereumAddress(signer.address)!
        transactionOptions.to = estimate.to
        transactionOptions.gasLimit = .manual(fee.gasLimit)
        transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
        transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
        transactionOptions.value = value
        transactionOptions.nonce = .manual(nonce)
        transactionOptions.chainID = chainId
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta
        
        var transaction = EthereumTransaction(type: .legacy,
                                              to: estimate.to,
                                              nonce: nonce,
                                              chainID: chainId,
                                              value: value,
                                              data: estimate.data,
                                              parameters: ethereumParameters)
        
        let signature = signer.signTypedData(signer.domain, typedData: transaction).addHexPrefix()
        
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
        transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
        transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
        transaction.envelope.v = BigUInt(unmarshalledSignature.v)
        
        let result = try! zkSync.web3.eth.sendRawTransactionPromise(transaction).wait()
        
        callback()
    }
}
