//
//  File.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 8/16/22.
//

import Foundation

//public interface Structurable {
//    
//    String getType();
//
//    List<Pair<String, Type<?>>> eip712types();
//
//    default Eip712Struct intoEip712Struct() {
//        return new Eip712Struct(this);
//    }
//}

// ZKSync2 (Java): Structurable.java
protocol Structurable {
    
    var type: String { get }
    
    func eip712types() -> Dictionary<String, Any?>
    
    func intoEip712Struct() -> Eip712Struct
}
