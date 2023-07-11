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
    
    func stripLeadingZeroes() -> String? {
        let hex = self.addHexPrefix()
        guard let matcher = try? NSRegularExpression(pattern: "^(?<prefix>0x)0*(?<end>[0-9a-fA-F]*)$", options: NSRegularExpression.Options.dotMatchesLineSeparators) else {return nil}
        let match = matcher.captureGroups(string: hex, options: NSRegularExpression.MatchingOptions.anchored)
        guard let prefix = match["prefix"] else {return nil}
        guard let end = match["end"] else {return nil}
        if (end != "") {
            return prefix + end
        }
        return "0x0"
    }
}
