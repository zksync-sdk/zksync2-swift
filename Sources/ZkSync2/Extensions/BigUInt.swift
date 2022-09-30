//
//  BigUInt.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/24/22.
//

import Foundation
import BigInt

public extension BigUInt {
    
    var isZero: Bool {
        return self == BigUInt.zero
    }
    
    static var zero: BigUInt {
        return BigUInt(0)
    }
    
    static var one: BigUInt {
        return BigUInt(1)
    }
    
    static var two: BigUInt {
        return BigUInt(2)
    }
    
    var data: Data {
        serialize()
    }
    
    var data16: Data {
        serialize().setLengthLeft(16)
    }
    
    var data32: Data {
        serialize().setLengthLeft(32)
    }
    
    var data64: Data {
        serialize().setLengthLeft(64)
    }
    
    func toHexString() -> String {
        return data.toHexString()
    }
}
