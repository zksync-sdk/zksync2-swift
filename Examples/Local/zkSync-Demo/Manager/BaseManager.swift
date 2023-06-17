//
//  BaseManager.swift
//  zkSync-Demo
//
//  Created by Bojan on 14.5.23..
//

import Foundation
import CryptoKit
import BigInt
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync
#endif

class BaseManager {
    let credentials = Credentials("0x7726827caac94a7f9e1b160f7ea819f172f7b6f9d2a97f992c38edeab82d4110")
    
    let zkSync: ZkSync = JsonRpc2_0ZkSync(URL(string: "http://127.0.0.1:3050")!)
    let eth: web3 = try! Web3.new(URL(string: "http://127.0.0.1:8545")!)
    
    var chainId: BigUInt {
        return try! zkSync.web3.eth.getChainIdPromise().wait()
    }
    
    var signer: EthSigner {
        PrivateKeyEthSigner(credentials, chainId: chainId)
    }
    
    var wallet: ZkSyncWallet {
        ZkSyncWallet(zkSync, ethSigner: signer, feeToken: Token.ETH)
    }
    
    func check(callback: (() -> Void)) {
        let keyStore = EthereumKeystoreV3("0x7726827caac94a7f9e1b160f7ea819f172f7b6f9d2a97f992c38edeab82d4110")
        let manager = KeystoreManager.init([keyStore])
        zkSync.web3.eth.web3.addKeystoreManager(manager)
        self.eth.addKeystoreManager(manager)
        
        let contractAddress = EthereumAddress("0xb3d481a4e8D9F9eFfd6d4474E3fcA72d465CD896")!
        //let contractJsonABI = "<your contract ABI as a JSON string>".data(using: .utf8)!
        // You can optionally pass an abiKey param if the actual abi is nested and not the top level element of the json
        let contract = zkSync.web3.contract("[{\"inputs\":[],\"name\":\"get\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"set\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]", at: contractAddress)!
//        let contract = try self.eth.Contract(json: contractJsonABI, abiKey: nil, address: contractAddress)
        
        //------------
        
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
            //return Promise(error: EthereumProviderError.invalidParameter)
        }
        
        var estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: writeTransaction.transaction.to, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: writeTransaction.transaction.data)
        
        let nonce = try! zkSync.web3.eth.getTransactionCountPromise(address: EthereumAddress(signer.address)!, onBlock: ZkBlockParameterName.committed.rawValue).wait()
        //let nonce = BigUInt(12)
        
        let fee = try! (zkSync as! JsonRpc2_0ZkSync).zksEstimateFee(estimate).wait()
        
        let gasPrice = try! zkSync.web3.eth.getGasPricePromise().wait()
        
        estimate.parameters.EIP712Meta?.gasPerPubdata = BigUInt(160000)//fee.gasPerPubdataLimit
        
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.from = EthereumAddress(signer.address)!
        transactionOptions.to = estimate.to
        transactionOptions.gasLimit = .manual(BigUInt(144857))//111.manual(fee.gasLimit)
        transactionOptions.maxPriorityFeePerGas = .manual(BigUInt(100000000))//111.manual(fee.maxPriorityFeePerGas)
        transactionOptions.maxFeePerGas = .manual(BigUInt(250000000))//111.manual(fee.maxFeePerGas)
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
                    
                    let address1 = EthereumAddress("0x834FF28392Ab0460f13286c389fEF4E3980e28F6")
                    let parameters: [AnyObject] = [
                        address1 as AnyObject
                    ]
                    
                    guard var encodedCallData = elementFunction.encodeParameters(parameters) else {
                        fatalError("Failed to encode function.")
                    }
                    
                    encodedCallData = encodedCallData.dropFirst()
                    encodedCallData = encodedCallData.dropFirst()
                    encodedCallData = encodedCallData.dropFirst()
                    encodedCallData = encodedCallData.dropFirst()
                    
                    let nonce = try! zkSync.web3.eth.getTransactionCountPromise(address: EthereumAddress(signer.address)!, onBlock: ZkBlockParameterName.committed.rawValue).wait()
                    
                    let contractTransaction = EthereumTransaction.create2AccountTransaction(from: EthereumAddress(signer.address)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, bytecode: bytecodeData, deps: [bytecodeData], calldata: encodedCallData, salt: Data(), chainId: signer.domain.chainId)
                    
                    let address = ContractDeployer.computeL2Create2Address(EthereumAddress(signer.address)!, bytecode: bytecodeData, constructor: Data(), salt: Data())
                    
                    let chainID = signer.domain.chainId
                    let gasPrice = try! zkSync.web3.eth.getGasPrice()
                    
                    var estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: contractTransaction.to, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: contractTransaction.data)
                    
                    var transactionOptions = TransactionOptions.defaultOptions
                    transactionOptions.type = .eip712
                    transactionOptions.chainID = chainID
                    transactionOptions.nonce = .manual(nonce)
                    transactionOptions.to = contractTransaction.to
                    transactionOptions.value = contractTransaction.value
                    //111transactionOptions.gasLimit = .manual(BigUInt(1073041))//.manual(fee.gasLimit)
                    transactionOptions.maxPriorityFeePerGas = .manual(BigUInt(100000000))//.manual(fee.maxPriorityFeePerGas)
                    transactionOptions.maxFeePerGas = .manual(BigUInt(250000000))//.manual(fee.maxFeePerGas) gasPrice
                    transactionOptions.from = contractTransaction.parameters.from
                    
//111                    let estimateGas = try! zkSync.web3.eth.estimateGas(contractTransaction, transactionOptions: transactionOptions)
//                    print("estimateGas:", estimateGas)
//                    transactionOptions.gasLimit = .manual(estimateGas)
                    
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
                    
                    let hash = result.hash
                }
            } catch {
                
            }
        }
    }
    
    func deploySmartContract(callback: (() -> Void)) {
        let nonce = try! zkSync.web3.eth.getTransactionCountPromise(address: EthereumAddress(signer.address)!, onBlock: ZkBlockParameterName.committed.rawValue).wait()
        print("nonce:", nonce)
        let value = [0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 1, 3, 85, 0, 0, 0, 96, 1, 16, 2, 112, 0, 0, 0, 19, 0, 16, 1, 157, 0, 0, 0, 128, 1, 0, 0, 57, 0, 0, 0, 64, 0, 16, 4, 63, 0, 0, 0, 1, 1, 32, 1, 144, 0, 0, 0, 41, 0, 0, 193, 61, 0, 0, 0, 0, 1, 0, 0, 49, 0, 0, 0, 4, 1, 16, 0, 140, 0, 0, 0, 66, 0, 0, 65, 61, 0, 0, 0, 1, 1, 0, 3, 103, 0, 0, 0, 0, 1, 1, 4, 59, 0, 0, 0, 224, 1, 16, 2, 112, 0, 0, 0, 21, 2, 16, 0, 156, 0, 0, 0, 49, 0, 0, 97, 61, 0, 0, 0, 22, 1, 16, 0, 156, 0, 0, 0, 66, 0, 0, 193, 61, 0, 0, 0, 0, 1, 0, 4, 22, 0, 0, 0, 0, 1, 16, 0, 76, 0, 0, 0, 66, 0, 0, 193, 61, 0, 0, 0, 4, 1, 0, 0, 138, 0, 0, 0, 0, 1, 16, 0, 49, 0, 0, 0, 23, 2, 0, 0, 65, 0, 0, 0, 32, 3, 16, 0, 140, 0, 0, 0, 0, 3, 0, 0, 25, 0, 0, 0, 0, 3, 2, 64, 25, 0, 0, 0, 23, 1, 16, 1, 151, 0, 0, 0, 0, 4, 16, 0, 76, 0, 0, 0, 0, 2, 0, 160, 25, 0, 0, 0, 23, 1, 16, 0, 156, 0, 0, 0, 0, 1, 3, 0, 25, 0, 0, 0, 0, 1, 2, 96, 25, 0, 0, 0, 0, 1, 16, 0, 76, 0, 0, 0, 66, 0, 0, 193, 61, 0, 0, 0, 4, 1, 0, 0, 57, 0, 0, 0, 1, 1, 16, 3, 103, 0, 0, 0, 0, 1, 1, 4, 59, 0, 0, 0, 0, 0, 16, 4, 27, 0, 0, 0, 0, 1, 0, 0, 25, 0, 0, 0, 73, 0, 1, 4, 46, 0, 0, 0, 0, 1, 0, 4, 22, 0, 0, 0, 0, 1, 16, 0, 76, 0, 0, 0, 66, 0, 0, 193, 61, 0, 0, 0, 32, 1, 0, 0, 57, 0, 0, 1, 0, 0, 16, 4, 67, 0, 0, 1, 32, 0, 0, 4, 67, 0, 0, 0, 20, 1, 0, 0, 65, 0, 0, 0, 73, 0, 1, 4, 46, 0, 0, 0, 0, 1, 0, 4, 22, 0, 0, 0, 0, 1, 16, 0, 76, 0, 0, 0, 66, 0, 0, 193, 61, 0, 0, 0, 4, 1, 0, 0, 138, 0, 0, 0, 0, 1, 16, 0, 49, 0, 0, 0, 23, 2, 0, 0, 65, 0, 0, 0, 0, 3, 16, 0, 76, 0, 0, 0, 0, 3, 0, 0, 25, 0, 0, 0, 0, 3, 2, 64, 25, 0, 0, 0, 23, 1, 16, 1, 151, 0, 0, 0, 0, 4, 16, 0, 76, 0, 0, 0, 0, 2, 0, 160, 25, 0, 0, 0, 23, 1, 16, 0, 156, 0, 0, 0, 0, 1, 3, 0, 25, 0, 0, 0, 0, 1, 2, 96, 25, 0, 0, 0, 0, 1, 16, 0, 76, 0, 0, 0, 68, 0, 0, 97, 61, 0, 0, 0, 0, 1, 0, 0, 25, 0, 0, 0, 74, 0, 1, 4, 48, 0, 0, 0, 0, 1, 0, 4, 26, 0, 0, 0, 128, 0, 16, 4, 63, 0, 0, 0, 24, 1, 0, 0, 65, 0, 0, 0, 73, 0, 1, 4, 46, 0, 0, 0, 72, 0, 0, 4, 50, 0, 0, 0, 73, 0, 1, 4, 46, 0, 0, 0, 74, 0, 1, 4, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 64, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 109, 76, 230, 60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 96, 254, 71, 177, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 156, 140, 143, 167, 137, 150, 126, 181, 20, 243, 236, 157, 239, 116, 132, 128, 148, 92, 201, 177, 15, 203, 209, 161, 149, 151, 217, 36, 235, 32, 16, 131]
        let hexArr = value.compactMap({ String(format:"%02X", $0).addHexPrefix() })
//        let bytecodeBytes = Data(fromArray: hexArr )
//        let bytecodeBytes = Data(fromArray: value)
        
        let url = Bundle.main.url(forResource: "Storage", withExtension: "zbin")!
        let bytecodeBytes = try! Data(contentsOf: url)
        
//        let bytecodeBytes = Data(fromArray: hexArr )
//        let bytecodeBytes = Data(fromHex: bytecode)!
        let contractTransaction = EthereumTransaction.create2ContractTransaction(from: EthereumAddress(signer.address)!, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, bytecode: bytecodeBytes, deps: [bytecodeBytes], calldata: Data(), salt: Data(), chainId: signer.domain.chainId)
        
        let address = ContractDeployer.computeL2Create2Address(EthereumAddress(signer.address)!, bytecode: bytecodeBytes, constructor: Data(), salt: Data())
        //0x24275566908ede24fe40a6ce8e59b56bcf555301
        print("address:", address)
        
        let chainID = signer.domain.chainId
        let gasPrice = try! zkSync.web3.eth.getGasPrice()
        
        var estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!, to: contractTransaction.to, gasPrice: BigUInt.zero, gasLimit: BigUInt.zero, data: contractTransaction.data)
        //let fee = try! (zkSync as! JsonRpc2_0ZkSync).zksEstimateFee(estimate).wait()
        //0x58d4b8ebd79c41d47d8a4449440d8cbd9831d32f9f13659ed28daa6d89aea184
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.type = .eip712
        transactionOptions.chainID = chainID
        transactionOptions.nonce = .manual(nonce)
        transactionOptions.to = contractTransaction.to
        transactionOptions.value = contractTransaction.value
        transactionOptions.gasLimit = .manual(BigUInt(486832))//.manual(fee.gasLimit)
        transactionOptions.maxPriorityFeePerGas = .manual(BigUInt(100000000))//.manual(fee.maxPriorityFeePerGas)
        transactionOptions.maxFeePerGas = .manual(BigUInt(250000000))//.manual(fee.maxFeePerGas)
        transactionOptions.from = contractTransaction.parameters.from
        
        var ethereumParameters = EthereumParameters(from: transactionOptions)
        ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta
        ethereumParameters.EIP712Meta?.factoryDeps = [bytecodeBytes]
        
        var transaction = EthereumTransaction(type: .eip712,
                                              to: estimate.to,
                                              nonce: nonce,
                                              chainID: chainId,
                                              data: estimate.data,
                                              parameters: ethereumParameters)
        
        let signature = signer.signTypedData(signer.domain, typedData: transaction).addHexPrefix()
        print("signature:", signature)
        //let signature = "0x5ab02819a432b120ee5ae6bf72780e8476b98ef64563fa33c5f0db253c120f4025475b51413af5f52dc403a60bb27716226dece49d2589a5788aacbd155bba891b"
        
        //print("signature:", signature)
        
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
        transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
        transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
        transaction.envelope.v = BigUInt(unmarshalledSignature.v)
        
        guard let message = transaction.encode(for: .transaction) else {
            fatalError("Failed to encode transaction.")
        }
        
//        let message = Data(fromHex: "0x71f90476808405f5e100840ee6b28083076db094000000000000000000000000000000000000800680b8843cda335100000000000000000000000000000000000000000000000000000000000000000100001b39e79a3700a4c960f47817703622e085a07a58a470500086308a4a100000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000082010e808082010e9436615cf349d7f6344891b1e7ca7c72883f5dc04983027100f90363b90360000200000000000200010000000103550000006001100270000000130010019d0000008001000039000000400010043f0000000101200190000000290000c13d0000000001000031000000040110008c000000420000413d0000000101000367000000000101043b000000e001100270000000150210009c000000310000613d000000160110009c000000420000c13d0000000001000416000000000110004c000000420000c13d000000040100008a00000000011000310000001702000041000000200310008c000000000300001900000000030240190000001701100197000000000410004c000000000200a019000000170110009c00000000010300190000000001026019000000000110004c000000420000c13d00000004010000390000000101100367000000000101043b000000000010041b0000000001000019000000490001042e0000000001000416000000000110004c000000420000c13d0000002001000039000001000010044300000120000004430000001401000041000000490001042e0000000001000416000000000110004c000000420000c13d000000040100008a00000000011000310000001702000041000000000310004c000000000300001900000000030240190000001701100197000000000410004c000000000200a019000000170110009c00000000010300190000000001026019000000000110004c000000440000613d00000000010000190000004a00010430000000000100041a000000800010043f0000001801000041000000490001042e0000004800000432000000490001042e0000004a00010430000000000000000000000000000000000000000000000000000000000000000000000000ffffffff0000000200000000000000000000000000000040000001000000000000000000000000000000000000000000000000000000000000000000000000006d4ce63c0000000000000000000000000000000000000000000000000000000060fe47b18000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000080000000000000000000000000000000000000000000000000000000000000000000000000000000009c8c8fa789967eb514f3ec9def748480945cc9b10fcbd1a19597d924eb201083b8415ab02819a432b120ee5ae6bf72780e8476b98ef64563fa33c5f0db253c120f4025475b51413af5f52dc403a60bb27716226dece49d2589a5788aacbd155bba891bc0")!
        
        let result = try! zkSync.web3.eth.sendRawTransactionPromise(message).wait()
        
        let hash = result.hash
        print("hash:", hash)
        
        // transaction receipt
        
        callback()
    }
    
    func deploySmartContractViaWallet(callback: (() -> Void)) {
        let wallet = ZkSyncWallet(zkSync, ethSigner: signer, feeToken: Token.ETH)
        
        let bytecode = "000200000000000200010000000103550000006001100270000000130010019d0000008001000039000000400010043f0000000101200190000000290000c13d0000000001000031000000040110008c000000420000413d0000000101000367000000000101043b000000e001100270000000150210009c000000310000613d000000160110009c000000420000c13d0000000001000416000000000110004c000000420000c13d000000040100008a00000000011000310000001702000041000000200310008c000000000300001900000000030240190000001701100197000000000410004c000000000200a019000000170110009c00000000010300190000000001026019000000000110004c000000420000c13d00000004010000390000000101100367000000000101043b000000000010041b0000000001000019000000490001042e0000000001000416000000000110004c000000420000c13d0000002001000039000001000010044300000120000004430000001401000041000000490001042e0000000001000416000000000110004c000000420000c13d000000040100008a00000000011000310000001702000041000000000310004c000000000300001900000000030240190000001701100197000000000410004c000000000200a019000000170110009c00000000010300190000000001026019000000000110004c000000440000613d00000000010000190000004a00010430000000000100041a000000800010043f0000001801000041000000490001042e0000004800000432000000490001042e0000004a00010430000000000000000000000000000000000000000000000000000000000000000000000000ffffffff0000000200000000000000000000000000000040000001000000000000000000000000000000000000000000000000000000000000000000000000006d4ce63c0000000000000000000000000000000000000000000000000000000060fe47b1800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000008000000000000000000000000000000000000000000000000000000000000000000000000000000000d5c7d2782d356f4a1a2e458d242d21e07a04810c9f771eed6501083e07288c87"
        let bytecodeBytes = Data(fromHex: bytecode)!
        let transactionSendingResult = try! wallet.deploy(bytecodeBytes).wait()
        
        callback()
    }
}
