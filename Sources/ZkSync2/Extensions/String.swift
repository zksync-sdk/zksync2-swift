//
//  String.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 9/5/22.
//

import Foundation

public extension String {
    
    func hasHexPrefix() -> Bool {
        return self.hasPrefix("0x")
    }
    
    func addHexPrefix() -> String {
        if !hasPrefix("0x") {
            return "0x" + self
        }
        
        return self
    }
    
    func stripHexPrefix() -> String {
        if hasPrefix("0x") {
            let indexStart = index(startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        
        return self
    }
}
