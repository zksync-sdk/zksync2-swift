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
    
    var maxFeePerGas: BigUInt
    
    var maxPriorityFeePerGas: BigUInt
    
    enum CodingKeys: String, CodingKey {
        case gasLimit = "gas_limit"
        case gasPerPubdataLimit = "gas_per_pubdata_limit"
        case maxFeePerGas = "max_fee_per_gas"
        case maxPriorityFeePerGas = "max_priority_fee_per_gas"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let gasLimit = try values.decode(String.self, forKey: .gasLimit)
        self.gasLimit = BigUInt(fromHex: gasLimit)!
        
        let gasPerPubdataLimit = try values.decode(String.self, forKey: .gasPerPubdataLimit)
        self.gasPerPubdataLimit = BigUInt(fromHex: gasPerPubdataLimit)!
        
        let maxFeePerGas = try values.decode(String.self, forKey: .maxFeePerGas)
        self.maxFeePerGas = BigUInt(fromHex: maxFeePerGas)!
        
        let maxPriorityFeePerGas = try values.decode(String.self, forKey: .maxPriorityFeePerGas)
        self.maxPriorityFeePerGas = BigUInt(fromHex: maxPriorityFeePerGas)!
    }
}
