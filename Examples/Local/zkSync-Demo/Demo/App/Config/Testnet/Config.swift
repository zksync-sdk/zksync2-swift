//
//  Testnet.swift
//  zkSync-Demo
//
//  Created by Bojan on 11.7.23..
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync2
#endif

struct Config {
    static let privateKey = "<PRIVATE_KEY>"
    static let zkSyncProviderUrl = URL(string: "https://testnet.era.zksync.dev")!
    static let ethereumProviderUrl = URL(string: "https://rpc.ankr.com/eth_goerli")!
}
