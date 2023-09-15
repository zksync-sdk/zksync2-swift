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
        let chainID = signer.domain.chainId
        let gasPrice = try! await zkSync.web3.eth.gasPrice()

        let estimate = CodableTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: transaction.to, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: transaction.data)

        let fee = try! await zkSync.estimateFee(estimate)

        var transaction = transaction
        //444transaction.type = .eip712
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

//444        var ethereumParameters = EthereumParameters(from: transactionOptions)
//
//        ethereumParameters.EIP712Meta = (transaction.envelope as! EIP712Envelope).EIP712Meta

        var prepared = CodableTransaction(
            type: .eip712,
            to: transaction.to,
            nonce: nonce,
            chainID: chainID,
            value: transaction.value,
            data: transaction.data
            //444parameters: ethereumParameters
        )

        let domain = signer.domain
//444        let signature = signer.signTypedData(domain, typedData: prepared)
//        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
//        prepared.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
//        prepared.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
//        prepared.envelope.v = BigUInt(unmarshalledSignature.v)

        guard let message = prepared.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }

#if DEBUG
        print("Transaction hash: \(String(describing: prepared.hash?.toHexString().addHexPrefix()))")
        //444print("Signature: \(signature))")
        print("Encoded and signed transaction: \(message.toHexString().addHexPrefix())")
#endif
        return try! await zkSync.web3.eth.send(prepared)//444 remove !
    }
}
