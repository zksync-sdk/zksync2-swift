//  Package: web3swift
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
//  Additions for new transaction types by Mark Loit 2022

import Foundation
import BigInt

///  Structure capable of carying the parameters for any transaction type.
///  while all fields in this struct are optional, they are not necessarily
///  optional for the type of transaction they apply to.
public struct EthereumParameters {

    /// signifies the transaction type that this payload is for
    /// indicates what fields should be populated. 
    /// this should always be set to give an idea of what other fields to expect
    public var type: TransactionType?

    /// the destination, or contract, address for the transaction
    public var to: EthereumAddress?

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
    
    public var from: EthereumAddress?
    
    public var EIP712Meta: EIP712Meta?
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

public struct EIP712Meta {
    
    public var ergsPerPubdata: BigUInt?
    
    public var customSignature: Data? = Data()
    
    public var paymasterParams: PaymasterParams?
    
    public var factoryDeps: [Data]?
    
    public init(ergsPerPubdata: BigUInt? = nil,
                customSignature: Data? = Data(),
                paymasterParams: PaymasterParams? = nil,
                factoryDeps: [Data]? = nil) {
        self.ergsPerPubdata = ergsPerPubdata
        self.customSignature = customSignature
        self.paymasterParams = paymasterParams
        self.factoryDeps = factoryDeps
    }
}

public struct PaymasterParams {
    
    public var paymaster: String?
    
    public var paymasterInput: Data?
    
    public init(paymaster: String? = nil,
                paymasterInput: Data? = nil) {
        self.paymaster = paymaster
        self.paymasterInput = paymasterInput
    }
}
