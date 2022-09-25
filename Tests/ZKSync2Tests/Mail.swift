//
//  Mail.swift
//  ZKSync2Tests
//
//  Created by Maxim Makhun on 8/31/22.
//

import Foundation
import web3swift
@testable import ZKSync2

struct Mail: Structurable {
    
    var from: Person
    var to: Person
    var contents: String
    
    init() {
        self.from = Person(name: "Cow",
                           wallet: "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826")
        
        self.to = Person(name: "Bob",
                         wallet: "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB")
        
        self.contents = "Hello, Bob!"
    }
    
    init(from: Person, to: Person, contents: String) {
        self.from = from
        self.to = to
        self.contents = contents
    }
}
