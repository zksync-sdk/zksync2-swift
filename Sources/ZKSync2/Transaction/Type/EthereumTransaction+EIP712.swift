//
//  Transaction712.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 9/5/22.
//

import Foundation
import web3swift
import BigInt

extension EthereumTransaction: Structurable {
    
    func getTypeName() -> String {
        "Transaction"
    }
    
    func eip712types() -> [ZkSync2.EIP712.`Type`] {
        let envelope = envelope as! EIP712Envelope
        
        return [
            ("txType", EIP712.UInt256(envelope.type.rawValue)),
            ("from", BigUInt(envelope.from!.addressData)),
            ("to", BigUInt(envelope.to.addressData)),
            ("ergsLimit", envelope.parameters.gasLimit!),
            ("ergsPerPubdataByteLimit", envelope.EIP712Meta!.ergsPerPubdata as Any),
            ("maxFeePerErg", envelope.parameters.maxFeePerGas as Any),
            ("maxPriorityFeePerErg", envelope.parameters.maxPriorityFeePerGas as Any),
            ("paymaster", envelope.EIP712Meta?.paymasterParams?.paymaster ?? BigUInt.zero),
            ("nonce", envelope.nonce),
            ("value", envelope.parameters.value as Any),
            ("data", data),
            ("factoryDeps", envelope.EIP712Meta?.factoryDeps ?? []),
            ("paymasterInput", envelope.parameters.EIP712Meta?.paymasterParams?.paymasterInput ?? Data())
        ]
    }
}
