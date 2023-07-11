//
//  TransactionParameters.swift
//  zkSync-Demo
//
//  Created by Bojan on 11.7.23..
//

import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

/// Transaction parameters JSON structure for interaction with Ethereum node.
public struct TransactionParameters: Codable {
    /// accessList parameter JSON structure
    public struct AccessListEntry: Codable {
        public var address: String
        public var storageKeys: [String]
    }
    
    public var type: String?  // must be set for new EIP-2718 transaction types
    public var chainID: String?
    public var data: String?
    public var from: String?
    public var gas: String?
    public var gasPrice: String? // Legacy & EIP-2930
    public var maxFeePerGas: String? // EIP-1559
    public var maxPriorityFeePerGas: String? // EIP-1559
    public var accessList: [AccessListEntry]? // EIP-1559 & EIP-2930
    public var to: String?
    public var value: String? = "0x0"
    //333public var eip712Meta: EIP712Meta?
    
    public init(from _from: String?, to _to: String?) {
        from = _from
        to = _to
    }
}

extension CodableTransaction {
    public func encodeAsDictionary(from: EthereumAddress? = nil) -> TransactionParameters? {
        var toString: String?
        switch self.to.type {
        case .normal:
            toString = self.to.address.lowercased()
        case .contractDeployment:
            break
        }
        var params = TransactionParameters(from: from?.address.lowercased(), to: toString)
        let typeEncoding = String(UInt8(self.type.rawValue), radix: 16).addHexPrefix()
        params.type = typeEncoding
        let chainEncoding = self.chainID?.abiEncode(bits: 256)
        params.chainID = chainEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        var accessEncoding: [TransactionParameters.AccessListEntry] = []
        for listEntry in self.accessList ?? [] {
//333            guard let encoded = listEntry.encodeAsDictionary() else { return nil }
//            accessEncoding.append(encoded)
        }
        params.accessList = accessEncoding
        let gasEncoding = self.gasLimit.abiEncode(bits: 256)
        params.gas = gasEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        let maxFeeEncoding = self.maxFeePerGas?.abiEncode(bits: 256)
        params.maxFeePerGas = maxFeeEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        let maxPriorityEncoding = self.maxPriorityFeePerGas?.abiEncode(bits: 256)
        params.maxPriorityFeePerGas = maxPriorityEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        let valueEncoding = self.value.abiEncode(bits: 256)
        params.value = valueEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        params.data = self.data.toHexString().addHexPrefix()
        //333params.eip712Meta = self.EIP712Meta
        return params
    }
}

extension EIP2930Envelope {
    public func encodeAsDictionary(from: EthereumAddress? = nil) -> TransactionParameters? {
        var toString: String?
        switch self.to.type {
        case .normal:
            toString = self.to.address.lowercased()
        case .contractDeployment:
            break
        }
        var params = TransactionParameters(from: from?.address.lowercased(), to: toString)
        let typeEncoding = String(UInt8(self.type.rawValue), radix: 16).addHexPrefix()
        params.type = typeEncoding
        let chainEncoding = self.chainID?.abiEncode(bits: 256)
        params.chainID = chainEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        var accessEncoding: [TransactionParameters.AccessListEntry] = []
        for listEntry in self.accessList {
//333            guard let encoded = listEntry.encodeAsDictionary() else { return nil }
//            accessEncoding.append(encoded)
        }
        params.accessList = accessEncoding
        let gasEncoding = self.gasLimit.abiEncode(bits: 256)
        params.gas = gasEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        let gasPriceEncoding = self.gasPrice?.abiEncode(bits: 256)
        params.gasPrice = gasPriceEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        let valueEncoding = self.value.abiEncode(bits: 256)
        params.value = valueEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        params.data = self.data.toHexString().addHexPrefix()
        return params
    }
}

extension BigUInt {
    func abiEncode(bits: UInt64) -> Data? {
        let data = self.serialize()
        let paddedLength = UInt64(ceil((Double(bits)/8.0)))
        let padded = data.setLengthLeft(paddedLength)
        return padded
    }
}
