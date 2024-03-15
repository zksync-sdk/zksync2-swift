//
//  File.swift
//  
//
//  Created by Petar Kopestinskij on 15.3.24..
//

import Foundation
import BigInt

public struct FullDepositFee: Equatable {
    var baseCost: BigUInt
    var l1GasLimit: BigUInt
    var l2GasLimit: BigUInt
    var gasPrice: BigUInt?
    var maxPriorityFeePerGas: BigUInt?
    var maxFeePerGas: BigUInt?
}
