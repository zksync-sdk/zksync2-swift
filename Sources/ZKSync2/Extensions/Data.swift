//
//  Data.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 9/24/22.
//

import Foundation

extension Data {
    
    func setLengthLeft(_ toBytes: UInt64, isNegative: Bool = false) -> Data? {
        let existingLength = UInt64(self.count)
        if existingLength == toBytes {
            return Data(self)
        } else if existingLength > toBytes {
            return nil
        }
        
        var data: Data
        if isNegative {
            data = Data(repeating: UInt8(255), count: Int(toBytes - existingLength))
        } else {
            data = Data(repeating: UInt8(0), count: Int(toBytes - existingLength))
        }
        
        data.append(self)
        
        return data
    }
    
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}
