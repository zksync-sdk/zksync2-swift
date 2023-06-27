//
//  PaymasterManager.swift
//  zkSync-Demo
//
//  Created by Bojan on 20.6.23..
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync
#endif

class PaymasterManager: BaseManager {
    func deployPaymaster(callback: (() -> Void)) {
        guard let path = Bundle.main.path(forResource: "PaymasterFlow", ofType: "json") else { return }
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let jsonResult = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        guard let json = jsonResult as? [String: Any], let bytecode = json["bytecode"] as? String else { return }
        
        let bytecodeData = Data(fromHex: bytecode)!
        
        let nonce = try! zkSync.web3.eth.getTransactionCountPromise(address: EthereumAddress(signer.address)!, onBlock: ZkBlockParameterName.committed.rawValue).wait()
        
        var estimate = EthereumTransaction.create2ContractTransaction(from: EthereumAddress(signer.address)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, bytecode: bytecodeData, deps: [bytecodeData], calldata: Data(), salt: Data(), chainId: signer.domain.chainId)
        
        let gas = try! (zkSync as! JsonRpc2_0ZkSync).ethEstimateGas(estimate).wait()
        
        //let precomputedAddress = ContractDeployer.computeL2Create2Address(EthereumAddress(signer.address)!, bytecode: bytecodeData, constructor: Data(), salt: Data())
        
        let chainID = signer.domain.chainId
        let gasPrice = try! zkSync.web3.eth.getGasPrice()
        //???
//        estimate.parameters.EIP712Meta?.factoryDeps = [bytecodeData]
        
        let fee = try! (zkSync as! JsonRpc2_0ZkSync).zksEstimateFee(estimate).wait()
        
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.chainID = chainID
        transactionOptions.nonce = .manual(nonce)
        transactionOptions.to = estimate.to
        transactionOptions.value = estimate.value
        transactionOptions.gasLimit = .manual(fee.gasLimit)
        transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
        transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
        transactionOptions.from = estimate.parameters.from

        var ethereumParameters = EthereumParameters(from: transactionOptions)
        ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta
        ethereumParameters.EIP712Meta?.factoryDeps = [bytecodeData]
        
        var transaction = EthereumTransaction(
            type: .eip712,
            to: estimate.to,
            nonce: nonce,
            chainID: chainId,
            data: estimate.data,
            parameters: ethereumParameters
        )

        let signature = signer.signTypedData(signer.domain, typedData: transaction).addHexPrefix()

        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
        transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
        transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
        transaction.envelope.v = BigUInt(unmarshalledSignature.v)

        guard let message = transaction.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }

        let result = try! zkSync.web3.eth.sendRawTransactionPromise(message).wait()

        let receipt = transactionReceiptProcessor.waitForTransactionReceipt(hash: result.hash)

        assert(receipt?.status == .ok)
        //assert(precomputedAddress == receipt?.contractAddress)
        
        callback()
    }
}
