//
//  Numeric.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 9/24/22.
//

import Foundation

extension Numeric {
    
    var data: Data {
        var source = self
        return .init(bytes: &source, count: MemoryLayout<Self>.size)
    }
}
