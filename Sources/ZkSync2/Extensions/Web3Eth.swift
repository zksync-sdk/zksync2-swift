//
//  Web3Eth.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 9/29/22.
//

import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync
#endif

extension web3.Eth {
    
    func getChainIdPromise() -> Promise<BigUInt> {
        let request = JSONRPCRequestFabric.prepareRequest(.chainId, parameters: [])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue) { response in
            guard let value: BigUInt = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(desc: response.error!.message)
                }
                throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
            }
            return value
        }
    }
}
