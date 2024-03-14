//
//  JRPCCounter.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation

extension JRPC {
    
    struct Counter {
        
        static var counter = UInt64(1)
        
        static var lockQueue = DispatchQueue(label: "counterQueue")
        
        static func increment() -> UInt64 {
            var nextValue: UInt64 = 0
            lockQueue.sync {
                nextValue = Counter.counter
                Counter.counter += 1
            }
            
            return nextValue
        }
    }
}
