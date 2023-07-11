//
//  EthereumAddress.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 9/27/22.
//

#if canImport(web3swift)
import web3swift
import Web3Core
#else
import web3swift_zksync2
#endif

public extension EthereumAddress {
    
    static let Default = EthereumAddress("0x0000000000000000000000000000000000000000")!
    static let L2EthTokenAddress = EthereumAddress("0x000000000000000000000000000000000000800a")!
}
