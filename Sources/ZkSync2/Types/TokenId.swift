//
//  TokenId.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt

protocol TokenId {
    
    var symbol: String { get }
    
    func intoDecimal(_ amount: BigUInt) -> Decimal
}
