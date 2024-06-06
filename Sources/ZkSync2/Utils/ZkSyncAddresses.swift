//
//  ZkSyncAddresses.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 9/30/22.
//

import Foundation

public struct ZkSyncAddresses {
    
    public static let EthAddress = "0x0000000000000000000000000000000000000000"
    public static let LEGACY_ETH_ADDRESS = "0x0000000000000000000000000000000000000000"
    public static let ETH_ADDRESS_IN_CONTRACTS = "0x0000000000000000000000000000000000000001"
    public static let L2_BASE_TOKEN_ADDRESS = "0x000000000000000000000000000000000000800a"
    public static let ContractDeployerAddress = "0x0000000000000000000000000000000000008006"
    public static let NonceHolderAddress = "0x0000000000000000000000000000000000008003"
    public static let MessengerAddress = "0x0000000000000000000000000000000000008008"
    
    public static func isAddressEq(a: String, b: String) -> Bool{
        return a.lowercased() == b.lowercased()
    }
    
    public static func isEth(a: String) -> Bool{
        return (self.isAddressEq(a: a, b: LEGACY_ETH_ADDRESS)) ||
               (self.isAddressEq(a: a, b: L2_BASE_TOKEN_ADDRESS)) ||
               (self.isAddressEq(a: a, b: ETH_ADDRESS_IN_CONTRACTS))    
    }
}
