//
//  EthereumImpl+Promise.swift
//  zkSync-Demo
//
//  Created by Bojan on 12.9.23..
//

import Foundation
import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

public extension EthereumImpl {
    func getAllAccountBalances(_ address: String) -> Promise<Dictionary<String, String>> {
        Promise { seal in
//111            getAllAccountBalances(address,
//                                     completion: {
//                seal.resolve($0)
//            })
        }
    }
    
    func estimateGas(_ transaction: EthereumTransaction) -> Promise<BigUInt> {
        Promise { seal in
            estimateGas(transaction) {
                seal.resolve($0)
            }
        }
    }
}
