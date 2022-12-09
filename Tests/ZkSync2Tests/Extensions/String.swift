//
//  String.swift
//  ZkSync2Tests
//
//  Created by Maxim Makhun on 12/4/22.
//

import Foundation

extension String {
    
    func trim() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
