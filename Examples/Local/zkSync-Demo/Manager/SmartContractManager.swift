//
//  SmartContractManager.swift
//  zkSync-Demo
//
//  Created by Bojan on 17.6.23..
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync
#endif

class SmartContractManager: BaseManager {
    func check(callback: (() -> Void)) {
        let manager = KeystoreManager.init([credentials])
        zkSync.web3.eth.web3.addKeystoreManager(manager)
        self.eth.addKeystoreManager(manager)
        
        let contractAddress = EthereumAddress("0xb3d481a4e8D9F9eFfd6d4474E3fcA72d465CD896")!
        //let contractJsonABI = "<your contract ABI as a JSON string>".data(using: .utf8)!
        // You can optionally pass an abiKey param if the actual abi is nested and not the top level element of the json
        let contract = zkSync.web3.contract("[{\"inputs\":[],\"name\":\"get\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"set\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]", at: contractAddress)!
        //        let contract = try self.eth.Contract(json: contractJsonABI, abiKey: nil, address: contractAddress)
        
        let value = BigUInt(500)
        
        let parameters1 = [
            value as AnyObject
        ] as [AnyObject]
        
        var transactionOptions1 = TransactionOptions.defaultOptions
        transactionOptions1.from = EthereumAddress(signer.address)!
        
        guard let writeTransaction = contract.write("set",
                                                    parameters: parameters1,
                                                    transactionOptions: transactionOptions1) else {
            return
        }
        
        var estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: writeTransaction.transaction.to, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: writeTransaction.transaction.data)
        
        let nonce = try! zkSync.web3.eth.getTransactionCountPromise(address: EthereumAddress(signer.address)!, onBlock: ZkBlockParameterName.committed.rawValue).wait()
        
        let fee = try! (zkSync as! JsonRpc2_0ZkSync).zksEstimateFee(estimate).wait()
        
        let gasPrice = try! zkSync.web3.eth.getGasPricePromise().wait()
        
        estimate.parameters.EIP712Meta?.gasPerPubdata = BigUInt(160000)//fee.gasPerPubdataLimit
        
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.from = EthereumAddress(signer.address)!
        transactionOptions.to = estimate.to
        transactionOptions.gasLimit = .manual(fee.gasLimit)
        transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
        transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
        transactionOptions.nonce = .manual(nonce)
        transactionOptions.chainID = chainId
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta
        
        var transaction = EthereumTransaction(type: .eip712,
                                              to: estimate.to,
                                              nonce: nonce,
                                              chainID: chainId,
                                              data: estimate.data,
                                              parameters: ethereumParameters)
        
        let signature = signer.signTypedData(signer.domain, typedData: transaction).addHexPrefix()
        
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
        transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
        transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
        transaction.envelope.v = BigUInt(unmarshalledSignature.v)
        
        let result = try! zkSync.web3.eth.sendRawTransactionPromise(transaction).wait()
        
        //        var result = try! transaction.callPromise().wait()
        
        //print("result:", result)
        //------------
        
        let parameters2 = [
            
        ] as [AnyObject]
        
        guard let readTransaction = contract.read("get",
                                                  parameters: parameters2,
                                                  transactionOptions: nil) else {
            return
            //return Promise(error: EthereumProviderError.invalidParameter)
        }
        
        //        guard let encodedTransaction = readTransaction.transaction.encode(for: .transaction) else {
        //            fatalError("Failed to encode transaction.")
        //        }
        
        let result2 = try! readTransaction.callPromise().wait()
        
        print("result:", result2)
        //        print(contract.methods.count)
        //
        //        print(contract.allMethods)
        //        let getFunction = contract.methods["get"]!
        //
        //        let parameters: [AnyObject] = [
        //
        //        ]
        //
        //        guard let encodedTransaction = readTransaction.transaction.encode(for: .transaction) else {
        //            fatalError("Failed to encode transaction.")
        //        }
        //
        //        print("Encoded transaction: \(encodedTransaction.toHexString().addHexPrefix())")
        //
        //        return readTransaction.callPromise()
        
        // TODO: Verify calldata.
        //        let calldata = getFunction.encodeParameters(parameters)!
        
        //        var estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: EthereumAddress.L2EthTokenAddress, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, value: BigUInt.zero, data: calldata)
        
        //        let nonce = try! zkSync.web3.eth.getTransactionCountPromise(address: EthereumAddress(signer.address)!, onBlock: ZkBlockParameterName.committed.rawValue).wait()
        //        let result = try! wallet.estimateAndSend(estimate, nonce: nonce).wait()
        
        //        // Get balance of some address
        //        firstly {
        //            try contract["balanceOf"]!(EthereumAddress(hex: "0x3edB3b95DDe29580FFC04b46A68a31dD46106a4a", eip55: true)).call()
        //        }.done { outputs in
        //            print(outputs["_balance"] as? BigUInt)
        //        }.catch { error in
        //            print(error)
        //        }
        
        //        // Send some tokens to another address (locally signing the transaction)
        //        let myPrivateKey = try EthereumPrivateKey(hexPrivateKey: "...")
        //        guard let transaction = contract["transfer"]?(EthereumAddress.testAddress, BigUInt(100000)).createTransaction(
        //            nonce: 0,
        //            gasPrice: EthereumQuantity(quantity: 21.gwei),
        //            maxFeePerGas: nil,
        //            maxPriorityFeePerGas: nil,
        //            gasLimit: 150000,
        //            from: myPrivateKey.address,
        //            value: 0,
        //            accessList: [:],
        //            transactionType: .legacy
        //        )) else {
        //            return
        //        }
        //        let signedTx = try transaction.sign(with: myPrivateKey)
        //
        //        firstly {
        //            web3.eth.sendRawTransaction(transaction: signedTx)
        //        }.done { txHash in
        //            print(txHash)
        //        }.catch { error in
        //            print(error)
        //        }
    }
    
    func accountAbstraction(callback: (() -> Void)) {
        if let path = Bundle.main.path(forResource: "Paymaster", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let json = jsonResult as? [String: Any], let bytecode = json["bytecode"] as? String {
                    let bytecodeData = Data(fromHex: bytecode)!
                    
                    let inputs = [
                        ABI.Element.InOut(name: "erc20", type: .address),
                    ]
                    
                    let function = ABI.Element.Function(
                        name: "",
                        inputs: inputs,
                        outputs: [],
                        constant: false,
                        payable: false)
                    
                    let elementFunction: ABI.Element = .function(function)
                    
                    let address = EthereumAddress("0x834FF28392Ab0460f13286c389fEF4E3980e28F6")
                    let parameters: [AnyObject] = [
                        address as AnyObject
                    ]
                    
                    guard var encodedCallData = elementFunction.encodeParameters(parameters) else {
                        fatalError("Failed to encode function.")
                    }
                    
                    // Removing signature prefix, which is first 4 bytes
                    for _ in 0..<4 {
                        encodedCallData = encodedCallData.dropFirst()
                    }
                    
                    let nonce = try! zkSync.web3.eth.getTransactionCountPromise(address: EthereumAddress(signer.address)!, onBlock: ZkBlockParameterName.committed.rawValue).wait()
                    
                    let estimate = EthereumTransaction.create2AccountTransaction(from: EthereumAddress(signer.address)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, bytecode: bytecodeData, deps: [bytecodeData], calldata: encodedCallData, salt: Data(), chainId: signer.domain.chainId)
                    
                    let chainID = signer.domain.chainId
                    let gasPrice = try! zkSync.web3.eth.getGasPrice()
                    
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
                    
                    let estimateGas = try! zkSync.web3.eth.estimateGas(estimate, transactionOptions: transactionOptions)
                    transactionOptions.gasLimit = .manual(estimateGas)
                    
                    var ethereumParameters = EthereumParameters(from: transactionOptions)
                    ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta
                    ethereumParameters.EIP712Meta?.factoryDeps = [bytecodeData]
                    
                    var transaction = EthereumTransaction(type: .eip712, to: estimate.to, nonce: nonce, chainID: chainId, data: estimate.data, parameters: ethereumParameters)
                    
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
                    
                    callback()
                }
            } catch {
                
            }
        }
    }
    
    func deploySmartContract(callback: (() -> Void)) {
        let nonce = try! zkSync.web3.eth.getTransactionCountPromise(address: EthereumAddress(signer.address)!, onBlock: ZkBlockParameterName.committed.rawValue).wait()
        
        let url = Bundle.main.url(forResource: "Storage", withExtension: "zbin")!
        let bytecodeBytes = try! Data(contentsOf: url)
        
        let contractTransaction = EthereumTransaction.create2ContractTransaction(from: EthereumAddress(signer.address)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, bytecode: bytecodeBytes, deps: [bytecodeBytes], calldata: Data(), salt: Data(), chainId: signer.domain.chainId)
        
        let precomputedAddress = ContractDeployer.computeL2Create2Address(EthereumAddress(signer.address)!, bytecode: bytecodeBytes, constructor: Data(), salt: Data())
        
        let chainID = signer.domain.chainId
        let gasPrice = try! zkSync.web3.eth.getGasPrice()
        
        var estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: contractTransaction.to, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: contractTransaction.data)
        
        estimate.parameters.EIP712Meta?.factoryDeps = [bytecodeBytes]
        
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
        ethereumParameters.EIP712Meta?.factoryDeps = [bytecodeBytes]
        
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
    
    func deploySmartContractViaWallet(callback: (() -> Void)) {
        let wallet = ZkSyncWallet(zkSync, ethSigner: signer, feeToken: Token.ETH)
        
        let url = Bundle.main.url(forResource: "Storage", withExtension: "zbin")!
        let bytecodeBytes = try! Data(contentsOf: url)
        let result = try! wallet.deploy(bytecodeBytes).wait()
        
        let receipt = transactionReceiptProcessor.waitForTransactionReceipt(hash: result.hash)
        
        assert(receipt?.status == .ok)
        
        callback()
    }
}
