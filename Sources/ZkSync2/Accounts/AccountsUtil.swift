//
//  Util.swift
//  zkSync-Demo
//
//  Created by Bojan on 1.9.23..
//

import Foundation
import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

public class AccountsUtil {
    static func estimateAndSend(zkSync: ZkSyncClient, signer: EthSigner, _ transaction: EthereumTransaction, nonce: BigUInt) -> Promise<TransactionSendingResult> {
        let chainID = signer.domain.chainId
        let gasPrice = try! zkSync.web3.eth.getGasPrice()
        
        let estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: transaction.to, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: transaction.data)
        
        let fee = try! zkSync.estimateFee(estimate).wait()
        
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.chainID = chainID
        transactionOptions.nonce = .manual(nonce)
        transactionOptions.from = transaction.parameters.from
        transactionOptions.to = transaction.to
        transactionOptions.value = transaction.value
        transactionOptions.gasLimit = .manual(fee.gasLimit)
        transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
        transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
        
        let gas = try! zkSync.web3.eth.estimateGas(transaction, transactionOptions: transactionOptions)
        transactionOptions.gasLimit = .manual(gas)
        
#if DEBUG
        print("chainID: \(chainID)")
        print("gas: \(gas)")
        print("gasPrice: \(gasPrice)")
#endif
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        
        ethereumParameters.EIP712Meta = (transaction.envelope as! EIP712Envelope).EIP712Meta
        
        var prepared = EthereumTransaction(type: .eip712,
                                           to: transaction.to,
                                           nonce: nonce,
                                           chainID: chainID,
                                           value: transaction.value,
                                           data: transaction.data,
                                           parameters: ethereumParameters)
        
        let domain = signer.domain
        let signature = signer.signTypedData(domain, typedData: prepared)
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
        prepared.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
        prepared.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
        prepared.envelope.v = BigUInt(unmarshalledSignature.v)
        
        guard let message = prepared.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }
        
#if DEBUG
        print("Transaction hash: \(String(describing: prepared.hash?.toHexString().addHexPrefix()))")
        print("Signature: \(signature))")
        print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
#endif
        return zkSync.web3.eth.sendRawTransactionPromise(prepared)
    }
}
