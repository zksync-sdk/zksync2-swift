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
import Web3Core
#else
import web3swift_zksync2
#endif

public extension ZkSyncClientImpl {
    
    func zksMainContract() -> Promise<String> {
        Promise { seal in
            mainContract {
                seal.resolve($0)
            }
        }
    }
    
    func zksGetTokenPrice(_ tokenAddress: String) -> Promise<Decimal> {
        Promise { seal in
            tokenPrice(tokenAddress) {
                seal.resolve($0)
            }
        }
    }
    
    func zksL1ChainId() -> Promise<BigUInt> {
        Promise { seal in
            L1ChainId {
                seal.resolve($0)
            }
        }
    }
    
    func zksGetAllAccountBalances(_ address: String) -> Promise<Dictionary<String, String>> {
        Promise { seal in
            allAccountBalances(address, completion: {
                seal.resolve($0)
            })
        }
    }
    
    func zksGetBridgeContracts() -> Promise<BridgeAddresses> {
        Promise { seal in
            bridgeContracts {
                seal.resolve($0)
            }
        }
    }
    
    func zksEstimateFee(_ transaction: CodableTransaction) -> Promise<Fee> {
        Promise { seal in
            estimateFee(transaction) {
                seal.resolve($0)
            }
        }
    }
    
    func zksGetConfirmedTokens(_ from: Int, limit: Int) -> Promise<[Token]> {
        Promise { seal in
            confirmedTokens(from, limit: limit) {
                seal.resolve($0)
            }
        }
    }
    
    func estimateGas(_ transaction: CodableTransaction) async throws -> BigUInt {
        try await web3.eth.estimateGas(for: transaction)
    }
    
    func zksGetTestnetPaymaster() -> Promise<String> {
        Promise { seal in
            getTestnetPaymaster() {
                seal.resolve($0)
            }
        }
    }
}
