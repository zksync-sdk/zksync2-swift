//
//  L2ToL1MessageProof.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 8/30/22.
//

import Foundation

public struct L2ToL1MessageProof: Decodable {
    
    public let proof: [String]
    
    public let id: Int
    
    public let root: String
}
