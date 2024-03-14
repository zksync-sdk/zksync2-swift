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
            ("gasPerPubdataByteLimit", eip712Meta?.gasPerPubdata as Any),
            ("maxFeePerGas", maxFeePerGas as Any),
            ("maxPriorityFeePerGas", maxPriorityFeePerGas as Any),
            ("paymaster", BigUInt(eip712Meta?.paymasterParams?.paymaster?.addressData ?? Data())),
            ("nonce", nonce),
            ("value", value as Any),
            ("data", data),
            ("factoryDeps", eip712Meta?.factoryDeps ?? []),
            ("paymasterInput", eip712Meta?.paymasterParams?.paymasterInput ?? Data())
        ]
    }
    public func eip712typest() -> [EIP712.`Type`] {
        return [
            ("txType", EIP712.UInt256(type.rawValue)),
            ("from", BigUInt(from!.addressData)),
            ("to", BigUInt(to.addressData)),
            ("gasLimit", gasLimit),
            ("gasPerPubdataByteLimit", eip712Meta?.gasPerPubdata as Any),
            ("maxFeePerGas", maxFeePerGas as Any),
            ("maxPriorityFeePerGas", maxPriorityFeePerGas as Any),
            ("paymaster", BigUInt(eip712Meta?.paymasterParams?.paymaster?.addressData ?? Data())),
            ("nonce", nonce),
            ("value", value as Any),
            ("data", data),
            ("factoryDeps", eip712Meta?.factoryDeps ?? []),
            //("signature", )
            ("paymasterInput", eip712Meta?.paymasterParams?.paymasterInput ?? Data())
        ]
    }
}
