//
//  MessageProof.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 8/30/22.
//

import Foundation

struct MessageProof: Decodable {
    
    var proof: [String]
    var id: Int
    var root: String
}
