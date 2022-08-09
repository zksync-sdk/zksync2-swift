//
//  BigUInt.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/24/22.
//

import Foundation
import BigInt

extension BigUInt {
    
    static var two: BigUInt {
        return BigUInt(2)
    }
}

extension String {
    
    func stripHexPrefix() -> String {
        if self.hasPrefix("0x") {
            let indexStart = self.index(self.startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        
        return self
    }
}
