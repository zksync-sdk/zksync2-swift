//
//  EthereumAddress.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 9/27/22.
//

#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync
#endif

extension EthereumAddress {
    
    static let Default = EthereumAddress("0x0000000000000000000000000000000000000000")!
}
