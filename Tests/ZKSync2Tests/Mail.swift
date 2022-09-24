//
//  Mail.swift
//  ZKSync2Tests
//
//  Created by Maxim Makhun on 8/31/22.
//

import Foundation
@testable import ZKSync2

struct Mail: Structurable {
    
    var type: String {
        "Mail"
    }
    
    var from: Person
    var to: Person
    var contents: String
    
    init(from: Person, to: Person, contents: String) {
        self.from = from
        self.to = to
        self.contents = contents
    }
    
    func eip712types() -> KeyValuePairs<String, Any?> {
        return [
            "from": from,
            "to": to,
            "contents": contents
        ]
    }
    
    func intoEip712Struct() -> Eip712Struct {
        return Eip712Struct()
    }
}
