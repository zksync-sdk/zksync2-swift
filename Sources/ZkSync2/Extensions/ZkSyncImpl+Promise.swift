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
    
    func mainContract() -> Promise<String> {
        Promise { seal in
            mainContract {
                seal.resolve($0)
            }
        }
    }
    
    func getTokenPrice(_ tokenAddress: String) -> Promise<Decimal> {
        Promise { seal in
            tokenPrice(tokenAddress) {
                seal.resolve($0)
            }
        }
    }
    
    func L1ChainId() -> Promise<BigUInt> {
        Promise { seal in
            L1ChainId {
                seal.resolve($0)
            }
        }
    }
    
    func getBridgeContracts() -> Promise<BridgeAddresses> {
        Promise { seal in
            bridgeContracts {
                seal.resolve($0)
            }
        }
    }
    
    func estimateFee(_ transaction: EthereumTransaction) -> Promise<Fee> {
        Promise { seal in
            estimateFee(transaction) {
                seal.resolve($0)
            }
        }
    }
    
    func getConfirmedTokens(_ from: Int, limit: Int) -> Promise<[Token]> {
        Promise { seal in
            confirmedTokens(from, limit: limit) {
                seal.resolve($0)
            }
        }
    }
    
    func getTestnetPaymaster() -> Promise<String> {
        Promise { seal in
            getTestnetPaymaster() {
                seal.resolve($0)
            }
        }
    }
}
