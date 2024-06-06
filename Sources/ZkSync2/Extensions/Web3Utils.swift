//
//  Web3Util.swift
//  zkSync-Demo
//
//  Created by Bojan on 11.7.23..
//

import BigInt
import PromiseKit
import Foundation
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

public extension Web3.Utils {
    /// Hashes a personal message by first padding it with the "\u{19}Ethereum Signed Message:\n" string and message length string.
    /// Should be used if some arbitrary information should be hashed and signed to prevent signing an Ethereum transaction
    /// by accident.
    static func hashPersonalMessage(_ personalMessage: Data) -> Data? {
        var prefix = "\u{19}Ethereum Signed Message:\n"
        prefix += String(personalMessage.count)
        guard let prefixData = prefix.data(using: .ascii) else {return nil}
        var data = Data()
        if personalMessage.count >= prefixData.count && prefixData == personalMessage[0 ..< prefixData.count] {
            data.append(personalMessage)
        } else {
            data.append(prefixData)
            data.append(personalMessage)
        }
        let hash = data.sha3(.keccak256)
        return hash
    }
    
    /// Recover the Ethereum address from recoverable secp256k1 signature.
    /// Takes a hash of some message. What message is hashed should be checked by user separately.
    ///
    /// Input parameters should be Data objects.
    static func hashECRecover(hash: Data, signature: Data) -> EthereumAddress? {
        if signature.count != 65 { return nil}
        let rData = signature[0..<32].bytes
        let sData = signature[32..<64].bytes
        var vData = signature[64]
        if vData >= 27 && vData <= 30 {
            vData -= 27
        } else if vData >= 31 && vData <= 34 {
            vData -= 31
        } else if vData >= 35 && vData <= 38 {
            vData -= 35
        }
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else {return nil}
        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else {return nil}
        return Web3.Utils.publicToAddress(publicKey)
    }
    
    /// Convert a public key to the corresponding EthereumAddress. Accepts public keys in compressed (33 bytes), non-compressed (65 bytes)
    /// or raw concat(X, Y) (64 bytes) format.
    ///
    /// Returns the EthereumAddress object.
    static func publicToAddress(_ publicKey: Data) -> EthereumAddress? {
        guard let addressData = Web3.Utils.publicToAddressData(publicKey) else {return nil}
        let address = addressData.toHexString().addHexPrefix().lowercased()
        return EthereumAddress(address)
    }
    
    /// Convert a public key to the corresponding EthereumAddress. Accepts public keys in compressed (33 bytes), non-compressed (65 bytes)
    /// or raw concat(X, Y) (64 bytes) format.
    ///
    /// Returns 20 bytes of address data.
    static func publicToAddressData(_ publicKey: Data) -> Data? {
        if publicKey.count == 33 {
            guard let decompressedKey = SECP256K1.combineSerializedPublicKeys(keys: [publicKey], outputCompressed: false) else {return nil}
            return publicToAddressData(decompressedKey)
        }
        var stipped = publicKey
        if (stipped.count == 65) {
            if (stipped[0] != 4) {
                return nil
            }
            stipped = stipped[1...64]
        }
        if (stipped.count != 64) {
            return nil
        }
        let sha3 = stipped.sha3(.keccak256)
        let addressData = sha3[12...31]
        return addressData
    }
    
    static let ADDRESS_MODULO = BigUInt(2).power(160)
    static let L1_TO_L2_ALIAS_OFFSET = "0x1111000000000000000000000000000000001111"
    
    static func applyL1ToL2Alias(address: String) -> String{
        return padTo42Characters(((BigUInt(address.stripHexPrefix(), radix: 16)! + BigUInt(L1_TO_L2_ALIAS_OFFSET.stripHexPrefix(), radix: 16)!) % ADDRESS_MODULO).toHexString().addHexPrefix())
    }
    
    static func padTo42Characters(_ address: String) -> String {
        var paddedAddress = address.stripHexPrefix()
        while paddedAddress.count < 40 {
            paddedAddress = "0" + paddedAddress
        }
        return "0x" + paddedAddress
    }
    
    static let L1_FEE_ESTIMATION_COEF_NUMERATOR = BigUInt(12)
    static let L1_FEE_ESTIMATION_COEF_DENOMINATOR = BigUInt(10)

    static func scaleGasLimit(gas: BigUInt) -> BigUInt{
        return gas.multiplied(by: L1_FEE_ESTIMATION_COEF_NUMERATOR)/L1_FEE_ESTIMATION_COEF_DENOMINATOR
    }
    
    static func isL1ChainLondonReady(provider: Web3) async -> BigUInt?{
        let block = try! await provider.eth.block(by: .latest)
        if let baseFeePerGas = block.baseFeePerGas {
            return baseFeePerGas
        }
        return nil
    }
    
    static func getERC20DefaultBridgeData(l1TokenAddress: String, provider: Web3) async -> Data?{
        var l1TokenAddress = l1TokenAddress
        if ZkSyncAddresses.isAddressEq(a: l1TokenAddress, b: ZkSyncAddresses.LEGACY_ETH_ADDRESS){
            l1TokenAddress = ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS
        }
        let token = provider.contract(
            Web3.Utils.IERC20,
            at: EthereumAddress(l1TokenAddress)
        )!

        let name = ZkSyncAddresses.isAddressEq(a: l1TokenAddress, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS) ?
            "Ether" : try! await token.createWriteOperation("name")?.callContractMethod()["0"] as? String
        let symbol = ZkSyncAddresses.isAddressEq(a: l1TokenAddress, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS) ?
            "ETH" : try! await token.createWriteOperation("symbol")?.callContractMethod()["0"] as? String
        let decimals = ZkSyncAddresses.isAddressEq(a: l1TokenAddress, b: ZkSyncAddresses.ETH_ADDRESS_IN_CONTRACTS) ?
            BigUInt(18) : try! await token.createWriteOperation("decimals")?.callContractMethod()["0"] as? BigUInt
        
        let encodedName = ABIEncoder.encode(types: [ABI.Element.ParameterType.string], values: [name!])
        let encodedSymbol = ABIEncoder.encode(types: [ABI.Element.ParameterType.string], values: [symbol!])
        let encodedDecimals = ABIEncoder.encode(types: [ABI.Element.ParameterType.uint(bits: 256)], values: [decimals!])
        
        return ABIEncoder.encode(types: [ABI.Element.ParameterType.dynamicBytes, ABI.Element.ParameterType.dynamicBytes, ABI.Element.ParameterType.dynamicBytes], values: [encodedName!, encodedSymbol!, encodedDecimals!])
    }
    
    static func insertGasPrice(options: TransactionOption?, provider: EthereumClient) async -> TransactionOption{
        var options = options ?? TransactionOption()
        
        let baseFeePerGas: BigUInt? = await Web3.Utils.isL1ChainLondonReady(provider: provider.web3)
        
        if options.gasPrice == nil && options.maxFeePerGas == nil {
            if let baseFee = baseFeePerGas {
                let maxPriorityFeePerGas = try! await provider.maxPriorityFeePerGas()
                options.maxPriorityFeePerGas = maxPriorityFeePerGas
                
                let additionalFee = baseFee * 3 / 2
                options.maxFeePerGas = maxPriorityFeePerGas + additionalFee
            } else {
                let gasPrice = try! await provider.suggestGasPrice()
                options.gasPrice = gasPrice
            }
        }
        
        return options
    }
        
    static func estimateCustomBridgeDepositL2Gas(provider: ZkSyncClient,
                                                 l1BridgeAddress: EthereumAddress,
                                                 l2BridgeAddress: EthereumAddress,
                                                 token: EthereumAddress,
                                                 amount: BigUInt,
                                                 to: EthereumAddress,
                                                 bridgeData: Data,
                                                 from: EthereumAddress,
                                                 gasPerPubdataByte: BigUInt? = BigUInt(800),
                                                 l2Value: BigUInt? = nil) async throws -> BigUInt{
        let calldata = try Web3Utils.getERC20BridgeCalldata(provider: provider, l1TokenAddress: token, l1Sender: from, l2Receiver: to, amount: amount, bridgeData: bridgeData)

        return try await provider.estimateL1ToL2Execute(l2BridgeAddress.address, from: Web3Utils.applyL1ToL2Alias(address: l1BridgeAddress.address), calldata: calldata, amount: l2Value ?? BigUInt.zero, gasPerPubData: gasPerPubdataByte!)
    }
    
    static func getERC20BridgeCalldata(provider: ZkSyncClient ,l1TokenAddress: EthereumAddress, l1Sender: EthereumAddress, l2Receiver: EthereumAddress, amount: BigUInt, bridgeData: Data) throws -> Data {
        let bridge = provider.web3.contract(Web3.Utils.IL2Bridge)!
        return bridge.contract.method("finalizeDeposit", parameters: [l1Sender, l2Receiver, l1TokenAddress, amount, bridgeData], extraData: Data())!
    }
    
    static func estimateDefaultBridgeDepositL2Gas(providerL1: Web3, providerL2: ZkSyncClient, token: String, amount: BigUInt, to: String, from: String, gasPerPubDataByte: BigUInt = BigUInt(800)) async throws -> BigUInt{
        if try await providerL2.isBaseToken(tokenAddress: token) {
            return try await providerL2.estimateL1ToL2Execute(to, from: from, calldata: Data(hex: "0x"), amount: amount, gasPerPubData: gasPerPubDataByte)
        }
        let bridgeAddresses = try await providerL2.bridgeContracts()
        let bridgeData = await Web3.Utils.getERC20DefaultBridgeData(l1TokenAddress: token, provider: providerL1)
        
        return try await Web3.Utils.estimateCustomBridgeDepositL2Gas(provider: providerL2, l1BridgeAddress: EthereumAddress(bridgeAddresses.l1SharedDefaultBridge)!, l2BridgeAddress: EthereumAddress(bridgeAddresses.l2SharedDefaultBridge)!, token: EthereumAddress(token)!, amount: amount, to: EthereumAddress(to)!, bridgeData: bridgeData!, from: EthereumAddress(from)!)
    }
}
