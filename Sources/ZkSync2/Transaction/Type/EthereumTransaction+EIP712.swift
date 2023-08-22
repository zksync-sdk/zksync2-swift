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
#else
import web3swift_zksync2
#endif

extension EthereumTransaction: Structurable {
    public func getTypeName() -> String {
        "Transaction"
    }
    
    public func eip712types() -> [EIP712.`Type`] {
        let envelope = envelope as! EIP712Envelope
        
        return [
            ("txType", EIP712.UInt256(envelope.type.rawValue)),
            ("from", BigUInt(envelope.from!.addressData)),
            ("to", BigUInt(envelope.to.addressData)),
            ("gasLimit", envelope.parameters.gasLimit!),
            ("gasPerPubdataByteLimit", envelope.EIP712Meta!.gasPerPubdata as Any),
            ("maxFeePerGas", envelope.parameters.maxFeePerGas as Any),
            ("maxPriorityFeePerGas", envelope.parameters.maxPriorityFeePerGas as Any),
            ("paymaster", BigUInt(envelope.EIP712Meta?.paymasterParams?.paymaster?.addressData ?? Data())),
            ("nonce", envelope.nonce),
            ("value", envelope.parameters.value as Any),
            ("data", data),
            ("factoryDeps", envelope.EIP712Meta?.factoryDeps ?? []),
            ("paymasterInput", envelope.parameters.EIP712Meta?.paymasterParams?.paymasterInput ?? Data())
        ]
    }
}
