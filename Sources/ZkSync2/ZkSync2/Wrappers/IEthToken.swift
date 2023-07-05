//
//  IEthToken.swift
//  ZkSync2
//
//  Created by Bojan on 5.7.23..
//

import Foundation
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync
#endif

public extension Web3.Utils {
    
    static var IEthToken: String {
        guard let path = Bundle.main.path(forResource: "IEthToken", ofType: "json") else { return "" }
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let jsonResult = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        guard let json = jsonResult as? [String: Any], let abi = json["abi"] as? [[String: Any]] else { return "" }
        
        guard let abiData = try? JSONSerialization.data(withJSONObject: abi, options: []) else { return "" }
        let abiString = String(data: abiData, encoding: .utf8)!
        
        return abiString
    }
}
