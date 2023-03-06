//
//  DateFormatter.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 05.03.2023.
//

import Foundation

extension DateFormatter {
    
    static var `default`: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter
    }
}
