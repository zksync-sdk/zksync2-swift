//
//  String.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 9/5/22.
//

import Foundation

extension String {
    
    func addHexPrefix() -> String {
        if !hasPrefix("0x") {
            return "0x" + self
        }
        
        return self
    }
}
