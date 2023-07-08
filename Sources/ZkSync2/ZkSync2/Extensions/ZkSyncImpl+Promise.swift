//
//  ZkSyncImpl+Promise.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/1/22.
//

import Foundation
import BigInt
import PromiseKit
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

public extension ZkSyncImpl {
    
    func zksMainContract() -> Promise<String> {
        Promise { seal in
            zksMainContract {
                seal.resolve($0)
            }
        }
    }
    
    func zksGetTokenPrice(_ tokenAddress: String) -> Promise<Decimal> {
        Promise { seal in
            zksGetTokenPrice(tokenAddress) {
                seal.resolve($0)
            }
        }
    }
    
    func zksL1ChainId() -> Promise<BigUInt> {
        Promise { seal in
            zksL1ChainId {
                seal.resolve($0)
            }
        }
    }
    
    func zksGetAllAccountBalances(_ address: String) -> Promise<Dictionary<String, String>> {
        Promise { seal in
            zksGetAllAccountBalances(address,
                                     completion: {
                seal.resolve($0)
            })
        }
    }
    
    func zksGetBridgeContracts() -> Promise<BridgeAddresses> {
        Promise { seal in
            zksGetBridgeContracts {
                seal.resolve($0)
            }
        }
    }
    
    func zksEstimateFee(_ transaction: EthereumTransaction) -> Promise<Fee> {
        Promise { seal in
            zksEstimateFee(transaction) {
                seal.resolve($0)
            }
        }
    }
    
    func zksGetConfirmedTokens(_ from: Int, limit: Int) -> Promise<[Token]> {
        Promise { seal in
            zksGetConfirmedTokens(from, limit: limit) {
                seal.resolve($0)
            }
        }
    }
    
    func ethEstimateGas(_ transaction: EthereumTransaction) -> Promise<BigUInt> {
        Promise { seal in
            ethEstimateGas(transaction) {
                seal.resolve($0)
            }
        }
    }
    
    func zksGetTestnetPaymaster() -> Promise<String> {
        Promise { seal in
            zksGetTestnetPaymaster() {
                seal.resolve($0)
            }
        }
    }
}
