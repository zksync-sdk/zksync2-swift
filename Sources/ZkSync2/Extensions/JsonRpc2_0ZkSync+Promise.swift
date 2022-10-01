//
//  JsonRpc2_0ZkSync+Promise.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/1/22.
//

import Foundation
import BigInt
import PromiseKit

extension JsonRpc2_0ZkSync {
    
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
    
    func chainId() -> Promise<BigUInt> {
        Promise { seal in
            chainId {
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
}
