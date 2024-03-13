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
import Web3Core
#else
import web3swift_zksync2
#endif

public class AccountsUtil {
    static func estimateAndSend(zkSync: ZkSyncClient, signer: ETHSigner, _ transaction: CodableTransaction, nonce: BigUInt) async -> TransactionSendingResult {
        let chainID = BigUInt(270)//222signer.domain.chainId
        let gasPrice = try! await zkSync.web3.eth.gasPrice()

        let estimate = CodableTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: transaction.to, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: transaction.data)

        //let fee = try! await zkSync.estimateFee(estimate)

        var transaction = transaction
        transaction.chainID = chainID
        transaction.nonce = nonce
        transaction.gasPrice = BigUInt(250000000)
        let fee = try! await zkSync.estimateFee(transaction)

//        transaction.gasLimit = fee.gasLimit
        transaction.maxPriorityFeePerGas = BigUInt(100000000)
        transaction.maxFeePerGas = fee.maxFeePerGas
        let gas = try! await zkSync.estimateGas(transaction)
        transaction.gasLimit = gas

#if DEBUG
        print("chainID: \(chainID)")
        print("gas: \(0)")
        print("gasPrice: \(gasPrice)")
#endif

        var prepared = CodableTransaction(
            type: .eip712,
            to: transaction.to,
            nonce: nonce,
            chainID: chainID,
            value: transaction.value,
            data: transaction.data,
            eip712Meta: EIP712Meta(gasPerPubdata: BigUInt(50000), customSignature: nil, paymasterParams: nil, factoryDeps: nil),
            from: transaction.from
        )
        prepared.gasPrice = BigUInt(250000000)
        prepared.from = EthereumAddress(from: signer.address)
        prepared.eip712Meta = transaction.eip712Meta
        prepared.value = transaction.value
        prepared.gasLimit = transaction.gasLimit
        prepared.maxPriorityFeePerGas = BigUInt(100000000)
        prepared.maxFeePerGas = BigUInt(250000000)

        let domain = signer.domain
        let msg = signer.signTypedData(domain, typedData: prepared)
        let pls = SECP256K1.unmarshalSignature(signatureData: Data(hex: msg))
        let r = BigUInt(from: pls!.r.toHexString().addHexPrefix())!
        let s = BigUInt(from: pls!.s.toHexString().addHexPrefix())!
        let v = BigUInt(pls!.v)
        var a = CodableTransaction(type: prepared.type, to: prepared.to, nonce: prepared.nonce, chainID: prepared.chainID!, value: prepared.value, data: prepared.data, gasLimit: prepared.gasLimit, maxFeePerGas: prepared.maxFeePerGas, maxPriorityFeePerGas: prepared.maxPriorityFeePerGas, gasPrice: prepared.gasPrice, accessList: prepared.accessList, v: v, r: r, s: s, eip712Meta: prepared.eip712Meta, from: prepared.from)
        
//        a.eip712Meta = prepared.eip712Meta
//        a.maxFeePerGas = prepared.maxFeePerGas
//        a.maxPriorityFeePerGas = prepared.maxPriorityFeePerGas
        
        guard let message = a.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }

#if DEBUG
        print("Transaction hash: \(String(describing: prepared.hash?.toHexString().addHexPrefix()))")
        print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
#endif
//        do {
//            let response = try await zkSync.sendRawTransaction(transaction: message.toHexString().addHexPrefix())
//            print("response is \(response)")
//        } catch {
//            print("error is \(error)")
//        }
        return try! await zkSync.web3.eth.send(raw: message)
    }
}
