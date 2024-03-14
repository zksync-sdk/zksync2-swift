//
//  Fee.swift
//  zkSync-Demo
//
//  Created by Bojan on 1.9.23..
//

import Foundation
import BigInt

public struct Fee: Decodable {
    
    public var gasLimit: BigUInt
    
    public var gasPerPubdataLimit: BigUInt
    
    public var maxFeePerGas: BigUInt
    
    public var maxPriorityFeePerGas: BigUInt
    
    enum CodingKeys: String, CodingKey {
        case gasLimit = "gas_limit"
        case gasPerPubdataLimit = "gas_per_pubdata_limit"
        case maxFeePerGas = "max_fee_per_gas"
        case maxPriorityFeePerGas = "max_priority_fee_per_gas"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let gasLimit = try values.decode(String.self, forKey: .gasLimit)
        self.gasLimit = BigUInt(from: gasLimit)!
        
        let gasPerPubdataLimit = try values.decode(String.self, forKey: .gasPerPubdataLimit)
        self.gasPerPubdataLimit = BigUInt(from: gasPerPubdataLimit)!
        
        let maxFeePerGas = try values.decode(String.self, forKey: .maxFeePerGas)
        self.maxFeePerGas = BigUInt(from: maxFeePerGas)!
        
        let maxPriorityFeePerGas = try values.decode(String.self, forKey: .maxPriorityFeePerGas)
        self.maxPriorityFeePerGas = BigUInt(from: maxPriorityFeePerGas)!
    }
}
