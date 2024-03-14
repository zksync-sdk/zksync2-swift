//
//  TransactionParameters.swift
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

public protocol TransactionOptionsInheritable {
    var transactionOptions: TransactionOptions { get }
}

/// Options for sending or calling a particular Ethereum transaction
public struct TransactionOptions {
    // Sets the transaction envelope type.
    // default here is legacy, so it will work on all chains
    // but the provider should perhaps set better defaults based on what chain is connected
    // id for Ethereum, default to EIP-1559
    public var type: TransactionType?

    /// Sets the transaction destination. It can either be a contract address or a private key controlled wallet address.
    ///
    /// Usually should never be nil, left undefined for a contract-creation transaction.
    public var to: EthereumAddress?
    /// Sets from what account a transaction should be sent. Used only internally as the sender of Ethereum transaction
    /// is determined purely from the transaction signature. Indicates to the Ethereum node or to the local keystore what private key
    /// should be used to sign a transaction.
    ///
    /// Can be nil if one reads the information from the blockchain.
    public var from: EthereumAddress?

    public var chainID: BigUInt?

    public enum GasLimitPolicy {
        case automatic
        case manual(BigUInt)
        case limited(BigUInt)
        case withMargin(Double)
    }
    public var gasLimit: GasLimitPolicy?

    public enum GasPricePolicy {
        case automatic
        case manual(BigUInt)
        case withMargin(Double)
    }

    public var gasPrice: GasPricePolicy?

    // new gas parameters for EIP-1559 support
    public enum FeePerGasPolicy {
        case automatic
        case manual(BigUInt)
    }
    public var maxFeePerGas: FeePerGasPolicy?
    public var maxPriorityFeePerGas: FeePerGasPolicy?

    /// The value transferred for the transaction in wei, also the endowment if it’s a contract-creation transaction.
    public var value: BigUInt?

    public enum NoncePolicy {
        case pending
        case latest
        case manual(BigUInt)
    }

    public var nonce: NoncePolicy?

    public enum CallingBlockPolicy {
        case pending
        case latest
        case exactBlockNumber(BigUInt)

        var stringValue: String {
            switch self {
            case .pending:
                return "pending"
            case .latest:
                return "latest"
            case .exactBlockNumber(let number):
                return String(number, radix: 16).addHexPrefix()
            }
        }
    }

    public var callOnBlock: CallingBlockPolicy?

    public var accessList: [AccessListEntry]?

    public static var defaultOptions: TransactionOptions {
        var opts = TransactionOptions()
        opts.type = .legacy
        opts.gasLimit = .automatic
        opts.gasPrice = .automatic
        opts.maxFeePerGas = .automatic
        opts.maxPriorityFeePerGas = .automatic
        opts.nonce = .pending
        opts.callOnBlock = .pending
        return opts
    }

    public func resolveNonce(_ suggestedByNode: BigUInt) -> BigUInt {
        guard let noncePolicy = self.nonce else { return suggestedByNode }
        switch noncePolicy {
        case .pending, .latest:
            return suggestedByNode
        case .manual(let value):
            return value
        }
    }

    public func resolveGasPrice(_ suggestedByNode: BigUInt) -> BigUInt {
        guard let gasPricePolicy = self.gasPrice else { return suggestedByNode }
        switch gasPricePolicy {
        case .automatic, .withMargin:
            return suggestedByNode
        case .manual(let value):
            return value
        }
    }

    public func resolveGasLimit(_ suggestedByNode: BigUInt) -> BigUInt {
        guard let gasLimitPolicy = self.gasLimit else { return suggestedByNode }
        switch gasLimitPolicy {
        case .automatic, .withMargin:
            return suggestedByNode
        case .manual(let value):
            return value
        case .limited(let limit):
            if limit <= suggestedByNode {
                return suggestedByNode
            } else {
                return limit
            }
        }
    }

    public func resolveMaxFeePerGas(_ suggestedByNode: BigUInt) -> BigUInt {
        guard let maxFeePerGasPolicy = self.maxFeePerGas else { return suggestedByNode }
        switch maxFeePerGasPolicy {
        case .automatic:
            return suggestedByNode
        case .manual(let value):
            return value
        }
    }

    public func resolveMaxPriorityFeePerGas(_ suggestedByNode: BigUInt) -> BigUInt {
        guard let maxPriorityFeePerGasPolicy = self.maxPriorityFeePerGas else { return suggestedByNode }
        switch maxPriorityFeePerGasPolicy {
        case .automatic:
            return suggestedByNode
        case .manual(let value):
            return value
        }
    }

    public func merge(_ otherOptions: TransactionOptions?) -> TransactionOptions {
        guard let other = otherOptions else { return self }
        var opts = TransactionOptions()
        opts.type = mergeIfNotNil(first: self.type, second: other.type)
        opts.to = mergeIfNotNil(first: self.to, second: other.to)
        opts.from = mergeIfNotNil(first: self.from, second: other.from)
        opts.chainID = mergeIfNotNil(first: self.chainID, second: other.chainID)
        opts.gasLimit = mergeIfNotNil(first: self.gasLimit, second: other.gasLimit)
        opts.gasPrice = mergeIfNotNil(first: self.gasPrice, second: other.gasPrice)
        opts.maxFeePerGas = mergeIfNotNil(first: self.maxFeePerGas, second: other.maxFeePerGas)
        opts.maxPriorityFeePerGas = mergeIfNotNil(first: self.maxPriorityFeePerGas, second: other.maxPriorityFeePerGas)
        opts.value = mergeIfNotNil(first: self.value, second: other.value)
        opts.nonce = mergeIfNotNil(first: self.nonce, second: other.nonce)
        opts.callOnBlock = mergeIfNotNil(first: self.callOnBlock, second: other.callOnBlock)
        return opts
    }

    /// Merges two sets of options by overriding the parameters from the first set by parameters from the second
    /// set if those are not nil.
    ///
    /// Returns default options if both parameters are nil.
    public static func merge(_ options: TransactionOptions?, with other: TransactionOptions?) -> TransactionOptions? {
        var newOptions = TransactionOptions.defaultOptions // default has lowest priority
        newOptions = newOptions.merge(options)
        newOptions = newOptions.merge(other) // other has highest priority
        return newOptions
    }
}

private func mergeIfNotNil<T>(first: T?, second: T?) -> T? {
    if second != nil {
        return second
    } else if first != nil {
        return first
    }
    return nil
}

extension TransactionOptions: Decodable {
    public enum CodingKeys: String, CodingKey {
        case type
        case to
        case from
        case chainId
        case gasPrice
        case gas
        case maxFeePerGas
        case maxPriorityFeePerGas
        case value
        case nonce
        case callOnBlock
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaultOptions = TransactionOptions.defaultOptions

        // type is guaranteed to be set after this
        if let typeUInt = try? container.decodeHex(UInt.self, forKey: .type) {
            if typeUInt < TransactionType.allCases.count {
                guard let type = TransactionType(rawValue: typeUInt) else { throw Web3Error.dataError }
                self.type = type
            } else { throw Web3Error.dataError }
        } else { self.type = .legacy } // legacy streams may not have type set

        self.chainID = try container.decodeHexIfPresent(BigUInt.self, forKey: .chainId)

        let toString = try? container.decode(String.self, forKey: .to)
        switch toString {
        case nil, "0x", "0x0":
            self.to = EthereumAddress.contractDeploymentAddress()
        default:
            // the forced unwrap here is safe as we trap nil in the previous case
            // swiftlint:disable force_unwrapping
            guard let ethAddr = EthereumAddress(toString!) else { throw Web3Error.dataError }
            // swiftlint:enable force_unwrapping
            self.to = ethAddr
        }

        self.from = try container.decodeIfPresent(EthereumAddress.self, forKey: .from)

        if let gasPrice = try? container.decodeHex(BigUInt.self, forKey: .gasPrice) {
            self.gasPrice = .manual(gasPrice)
        } else {
            self.gasPrice = defaultOptions.gasPrice
        }

        if let gasLimit = try? container.decodeHex(BigUInt.self, forKey: .gas) {
            self.gasLimit = .manual(gasLimit)
        } else {
            self.gasLimit = defaultOptions.gasLimit
        }

        if let maxFeePerGas = try? container.decodeHex(BigUInt.self, forKey: .maxFeePerGas) {
            self.maxFeePerGas = .manual(maxFeePerGas)
        } else {
            self.maxFeePerGas = defaultOptions.maxFeePerGas
        }

        if let maxPriorityFeePerGas = try? container.decodeHex(BigUInt.self, forKey: .maxPriorityFeePerGas) {
            self.maxPriorityFeePerGas = .manual(maxPriorityFeePerGas)
        } else {
            self.maxPriorityFeePerGas = defaultOptions.maxPriorityFeePerGas
        }

        if let value = try? container.decodeHex(BigUInt.self, forKey: .value) {
            self.value = value
        } else {
            self.value = defaultOptions.value
        }

        if let nonce = try? container.decodeHex(BigUInt.self, forKey: .nonce) {
            self.nonce = .manual(nonce)
        } else {
            self.nonce = defaultOptions.nonce
        }

        if let callOnBlock = try? container.decodeHex(BigUInt.self, forKey: .callOnBlock) {
            self.callOnBlock = .exactBlockNumber(callOnBlock)
        } else {
            self.callOnBlock = defaultOptions.callOnBlock
        }
    }
}

extension TransactionOptions {
    @available(*, deprecated, message: "use Decodable instead")
    public static func fromJSON(_ json: [String: Any]) -> TransactionOptions? {
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try JSONDecoder().decode(TransactionOptions.self, from: jsonData)
        } catch {
            return nil
        }
    }

}

public struct EthereumParameters {
    /// signifies the transaction type that this payload is for
    /// indicates what fields should be populated.
    /// this should always be set to give an idea of what other fields to expect
    public var type: TransactionType?
    /// the destination, or contract, address for the transaction
    public var to: EthereumAddress?
    
    public var from: EthereumAddress?
    /// the nonce for the transaction
    public var nonce: BigUInt?
    /// the chainId that transaction is targeted for
    /// should be set for all types, except some Legacy transactions (Pre EIP-155)
    /// will not have this set
    public var chainID: BigUInt?
    /// the native value of the transaction
    public var value: BigUInt?
    /// any additional data for the transaction
    public var data: Data?
    /// the max number of gas units allowed to process this transaction
    public var gasLimit: BigUInt?
    /// the price per gas unit for the tranaction (Legacy and EIP-2930 only)
    public var gasPrice: BigUInt?
    /// the max base fee per gas unit (EIP-1559 only)
    /// this value must be >= baseFee + maxPriorityFeePerGas
    public var maxFeePerGas: BigUInt?
    /// the maximum tip to pay the miner (EIP-1559 only)
    public var maxPriorityFeePerGas: BigUInt?

    /// access list for contract execution (EIP-2930 and EIP-1559 only)
    public var accessList: [AccessListEntry]?
    
    public var eip712Meta: EIP712Meta?
}

public extension EthereumParameters {
    init(from opts: TransactionOptions) {
        self.type = opts.type
        self.from = opts.from
        self.to = opts.to
        if opts.nonce != nil { self.nonce = opts.resolveNonce(0) }
        self.chainID = opts.chainID
        self.value = opts.value
        if opts.gasLimit != nil { self.gasLimit = opts.resolveGasLimit(0) }
        if opts.gasPrice != nil { self.gasPrice = opts.resolveGasPrice(0) }
        if opts.maxFeePerGas != nil { self.maxFeePerGas = opts.resolveMaxFeePerGas(0) }
        if opts.maxPriorityFeePerGas != nil { self.maxPriorityFeePerGas = opts.resolveMaxPriorityFeePerGas(0) }
        self.accessList = opts.accessList
    }
}

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
    public var eip712Meta: EIP712Meta?
    
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
        params.accessList = self.accessList?.compactMap({
            guard
                let list = $0.encodeAsList(),
                let address = list.first as? String,
                let storage = list.last as? [Data]
            else { return nil }
            
            return TransactionParameters.AccessListEntry.init(address: address, storageKeys: storage.compactMap({ data in
                BigUInt(data).toHexString()
            }))
        })
        let gasEncoding = self.gasLimit.abiEncode(bits: 256)
        params.gas = gasEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        let maxFeeEncoding = self.maxFeePerGas?.abiEncode(bits: 256)
        params.maxFeePerGas = maxFeeEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        let maxPriorityEncoding = self.maxPriorityFeePerGas?.abiEncode(bits: 256)
        params.maxPriorityFeePerGas = maxPriorityEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        let valueEncoding = self.value.abiEncode(bits: 256)
        params.value = valueEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        params.data = self.data.toHexString().addHexPrefix()
        params.eip712Meta = self.eip712Meta
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
        params.accessList = self.accessList.compactMap({
            guard
                let list = $0.encodeAsList(),
                let address = list.first as? String,
                let storage = list.last as? [Data]
            else { return nil }
            
            return TransactionParameters.AccessListEntry.init(address: address, storageKeys: storage.compactMap({ data in
                BigUInt(data).toHexString()
            }))
        })
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
