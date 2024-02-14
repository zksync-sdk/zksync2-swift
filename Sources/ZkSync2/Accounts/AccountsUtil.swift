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
import web3core
#else
import web3swift_zksync2
#endif

public class AccountsUtil {
    static func estimateAndSend(zkSync: ZkSyncClient, signer: ETHSigner, _ transaction: CodableTransaction, nonce: BigUInt) async -> TransactionSendingResult {
        let chainID = BigUInt(270)//222signer.domain.chainId
        let gasPrice = try! await zkSync.web3.eth.gasPrice()

        let estimate = CodableTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: transaction.to, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: transaction.data)

        let fee = try! await zkSync.estimateFee(estimate)

        var transaction = transaction
        transaction.chainID = chainID
        transaction.nonce = nonce
        transaction.to = transaction.to
        transaction.value = transaction.value
        transaction.gasLimit = fee.gasLimit
        transaction.maxPriorityFeePerGas = fee.maxPriorityFeePerGas
        transaction.maxFeePerGas = fee.maxFeePerGas

        let gas = try! await zkSync.web3.eth.estimateGas(for: transaction)
        transaction.gasLimit = gas

#if DEBUG
        print("chainID: \(chainID)")
        print("gas: \(gas)")
        print("gasPrice: \(gasPrice)")
#endif

        var prepared = CodableTransaction(
            type: .eip712,
            to: transaction.to,
            nonce: nonce,
            chainID: chainID,
            value: transaction.value,
            data: transaction.data
        )
        prepared.from = transaction.from
        prepared.eip712Meta = transaction.eip712Meta
        prepared.value = transaction.value
        prepared.gasLimit = transaction.gasLimit
        prepared.maxPriorityFeePerGas = transaction.maxPriorityFeePerGas
        prepared.maxFeePerGas = transaction.maxFeePerGas

        let domain = signer.domain
        let signature = signer.signTypedData(domain, typedData: prepared)
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(from: signature)!)!
        prepared.r = BigUInt(from: unmarshalledSignature.r.toHexString().addHexPrefix())!
        prepared.s = BigUInt(from: unmarshalledSignature.s.toHexString().addHexPrefix())!
        prepared.v = BigUInt(unmarshalledSignature.v)

        guard let message = prepared.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }

#if DEBUG
        print("Transaction hash: \(String(describing: prepared.hash?.toHexString().addHexPrefix()))")
        print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
#endif
        return try! await zkSync.web3.eth.send(prepared)
    }
}
