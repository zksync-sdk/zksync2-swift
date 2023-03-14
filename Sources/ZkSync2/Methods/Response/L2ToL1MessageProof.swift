//
//  L2ToL1MessageProof.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 8/30/22.
//

import Foundation

struct L2ToL1MessageProof: Decodable {
    
    let proof: [String]
    
    let id: Int
    
    let root: String
}
