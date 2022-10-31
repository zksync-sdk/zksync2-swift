//
//  Token.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt

public struct Token: TokenId, Decodable {
    
    static let DefaultAddress = "0x0000000000000000000000000000000000000000"
    
    public static var ETH: Token {
        return Token(l1Address: Token.DefaultAddress,
                     l2Address: Token.DefaultAddress,
                     symbol: "ETH",
                     decimals: 18)
    }
    
    let l1Address: String
    let l2Address: String
    let symbol: String
    let decimals: Int
    
    public func intoDecimal(_ amount: BigUInt) -> Decimal {
        let sourceDecimal = Decimal(string: "\(amount)")!
        return sourceDecimal / pow(Decimal(10), decimals)
    }
    
    var isETH: Bool {
        return l2Address == Token.DefaultAddress && symbol == "ETH"
    }
}
