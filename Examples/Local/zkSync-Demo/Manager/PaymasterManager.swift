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
        
        let contractTransaction = EthereumTransaction.create2ContractTransaction(from: EthereumAddress(signer.address)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, bytecode: bytecodeData, deps: [bytecodeData], calldata: Data(), salt: Data(), chainId: signer.domain.chainId)
        
        let precomputedAddress = ContractDeployer.computeL2Create2Address(EthereumAddress(signer.address)!, bytecode: bytecodeData, constructor: Data(), salt: Data())
        
        let chainID = signer.domain.chainId
        let gasPrice = try! zkSync.web3.eth.getGasPrice()
        
        var estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: contractTransaction.to, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: contractTransaction.data)
        
        estimate.parameters.EIP712Meta?.factoryDeps = [bytecodeData]
        
        let fee = try! (zkSync as! JsonRpc2_0ZkSync).zksEstimateFee(estimate).wait()
        
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.chainID = chainID
        transactionOptions.nonce = .manual(nonce)
        transactionOptions.to = contractTransaction.to
        transactionOptions.value = contractTransaction.value
        transactionOptions.gasLimit = .manual(fee.gasLimit)
        transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
        transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
        transactionOptions.from = contractTransaction.parameters.from
        
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
        assert(precomputedAddress == receipt?.contractAddress)
        
        callback()
    }
    
    func approvalBasedPaymaster(callback: @escaping (() -> Void)) {
        self.zkSync.zksGetTestnetPaymaster { result in
            switch result {
            case .success(let paymasterAddress):
                var estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(self.signer.address)!, to: EthereumAddress(self.signer.address)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: Data())
                
                var transactionOptions1 = TransactionOptions.defaultOptions
                transactionOptions1.type = .eip712
                transactionOptions1.to = estimate.to
                transactionOptions1.from = estimate.parameters.from
                
                let gasPrice = try! self.zkSync.web3.eth.getGasPrice()
                
                let estimateGas = try! self.zkSync.web3.eth.estimateGas(estimate, transactionOptions: transactionOptions1)
                
                let fee = gasPrice.multiplied(by: estimateGas)
                
                let token = Token(l1Address: "0x36615Cf349d7F6344891B1e7CA7C72883F5dc049", l2Address: Token.DefaultAddress, symbol: "ETH", decimals: 18)
                
                let paymasterInput = Paymaster.encodeApprovalBased(
                    EthereumAddress(token.l2Address)!,
                    minimalAllowance: fee,
                    input: Data()
                )
                
                estimate.parameters.EIP712Meta?.paymasterParams = PaymasterParams(paymaster: paymasterAddress, paymasterInput: paymasterInput)
                
                let nonce = try! self.zkSync.web3.eth.getTransactionCountPromise(address: EthereumAddress(self.signer.address)!, onBlock: ZkBlockParameterName.committed.rawValue).wait()
                
                let chainID = self.signer.domain.chainId
                
                var transactionOptions = TransactionOptions.defaultOptions
                transactionOptions.gasPrice = .manual(BigUInt.zero)
                transactionOptions.type = .eip712
                transactionOptions.chainID = chainID
                transactionOptions.nonce = .manual(nonce)
                transactionOptions.to = estimate.to
                transactionOptions.value = BigUInt.zero
                transactionOptions.maxPriorityFeePerGas = .manual(BigUInt(100000000))
                transactionOptions.maxFeePerGas = .manual(gasPrice)
                transactionOptions.from = estimate.parameters.from
                transactionOptions.gasLimit = .manual(estimateGas)
                
                var ethereumParameters = EthereumParameters(from: transactionOptions)
                ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta
                
                var transaction = EthereumTransaction(
                    type: .eip712,
                    to: estimate.to,
                    nonce: nonce,
                    chainID: chainID,
                    data: estimate.data,
                    parameters: ethereumParameters
                )
                
                let signature = self.signer.signTypedData(self.signer.domain, typedData: transaction).addHexPrefix()
                
                let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
                transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
                transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
                transaction.envelope.v = BigUInt(unmarshalledSignature.v)
                
                guard let message = transaction.encode(for: .transaction) else {
                    fatalError("Failed to encode transaction.")
                }
                
                let result = try! self.zkSync.web3.eth.sendRawTransactionPromise(message).wait()
                
                let receipt = self.transactionReceiptProcessor.waitForTransactionReceipt(hash: result.hash)
                
                assert(receipt?.status == .ok)
                
                callback()
            case .failure(_):
                break
            }
        }
    }
}
