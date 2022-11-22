//
//  Fee.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt

public struct Fee: Decodable {
    
    var ergsLimit: BigUInt
    
    var ergsPerPubdataLimit: BigUInt
    
    var maxFeePerErg: BigUInt
    
    var maxPriorityFeePerErg: BigUInt
    
    enum CodingKeys: String, CodingKey {
        case ergsLimit = "ergs_limit"
        case ergsPerPubdataLimit = "ergs_per_pubdata_limit"
        case maxFeePerErg = "max_fee_per_erg"
        case maxPriorityFeePerErg = "max_priority_fee_per_erg"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let ergsLimit = try values.decode(String.self, forKey: .ergsLimit)
        self.ergsLimit = BigUInt(fromHex: ergsLimit)!
        
        let ergsPerPubdataLimit = try values.decode(String.self, forKey: .ergsPerPubdataLimit)
        self.ergsPerPubdataLimit = BigUInt(fromHex: ergsPerPubdataLimit)!
        
        let maxFeePerErg = try values.decode(String.self, forKey: .maxFeePerErg)
        self.maxFeePerErg = BigUInt(fromHex: maxFeePerErg)!
        
        let maxPriorityFeePerErg = try values.decode(String.self, forKey: .maxPriorityFeePerErg)
        self.maxPriorityFeePerErg = BigUInt(fromHex: maxPriorityFeePerErg)!
    }
}
