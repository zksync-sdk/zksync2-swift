//
//  Transaction712.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 9/5/22.
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

extension CodableTransaction: Structurable {
    public func getTypeName() -> String {
        "Transaction"
    }
    
    public func eip712types() -> [EIP712.`Type`] {
        return [
            ("txType", EIP712.UInt256(type.rawValue)),
            ("from", BigUInt(from!.addressData)),
            ("to", BigUInt(to.addressData)),
            ("gasLimit", gasLimit),
//333            ("gasPerPubdataByteLimit", EIP712Meta!.gasPerPubdata as Any),
            ("maxFeePerGas", maxFeePerGas as Any),
            ("maxPriorityFeePerGas", maxPriorityFeePerGas as Any),
//333            ("paymaster", BigUInt(EIP712Meta?.paymasterParams?.paymaster?.addressData ?? Data())),
            ("nonce", nonce),
            ("value", value as Any),
            ("data", data),
//333            ("factoryDeps", EIP712Meta?.factoryDeps ?? []),
//            ("paymasterInput", EIP712Meta?.paymasterParams?.paymasterInput ?? Data())
        ]
    }
}
