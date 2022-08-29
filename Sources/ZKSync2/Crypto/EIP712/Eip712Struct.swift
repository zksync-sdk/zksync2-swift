//
//  File.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 8/16/22.
//

//@AllArgsConstructor
//public class Eip712Struct implements Type<Structurable>, Comparable<Eip712Struct> {
//
//    private Structurable structure;
//
//    @Override
//    public Structurable getValue() {
//        return structure;
//    }
//
//    @Override
//    public String getTypeAsString() {
//        return structure.getType();
//    }
//
//    @Override
//    public int compareTo(Eip712Struct o) {
//        return this.getTypeAsString().compareTo(o.getTypeAsString());
//    }
//
//    public String encodeType() {
//        return structure.getType() +
//            "(" +
//            structure.eip712types().stream().map((entry) -> entry.getValue().getTypeAsString() + " " + entry.getKey()).collect(Collectors.joining(",")) +
//            ")";
//    }
//}

import Foundation

// ZKSync2 (Java): Eip712Struct.java
class Eip712Struct {
    
}
