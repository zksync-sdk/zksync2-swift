//
//  Fee.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt

public struct Fee: Decodable {
    
    var gasLimit: BigUInt
    
    var gasPerPubdataLimit: BigUInt
    
    var maxFeePerErg: BigUInt
    
    var maxPriorityFeePerErg: BigUInt
    
    enum CodingKeys: String, CodingKey {
        case gasLimit = "gas_limit"
        case gasPerPubdataLimit = "gas_per_pubdata_limit"
        case maxFeePerErg = "max_fee_per_erg"
        case maxPriorityFeePerErg = "max_priority_fee_per_erg"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let gasLimit = try values.decode(String.self, forKey: .gasLimit)
        self.gasLimit = BigUInt(fromHex: gasLimit)!
        
        let gasPerPubdataLimit = try values.decode(String.self, forKey: .gasPerPubdataLimit)
        self.gasPerPubdataLimit = BigUInt(fromHex: gasPerPubdataLimit)!
        
        let maxFeePerErg = try values.decode(String.self, forKey: .maxFeePerErg)
        self.maxFeePerErg = BigUInt(fromHex: maxFeePerErg)!
        
        let maxPriorityFeePerErg = try values.decode(String.self, forKey: .maxPriorityFeePerErg)
        self.maxPriorityFeePerErg = BigUInt(fromHex: maxPriorityFeePerErg)!
    }
}
