//
//  Token.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt

public struct Token: TokenId, Decodable {
    
    static let DefaultAddress = "0x0000000000000000000000000000000000000000"
    
    static var ETH: Token {
        return Token(address: Token.DefaultAddress,
                     symbol: "ETH",
                     decimals: 18)
    }
    
//    let id: UInt32
    let address: String
    let symbol: String
    let decimals: Int
    
    func intoDecimal(_ amount: BigUInt) -> Decimal {
        let sourceDecimal = Decimal(string: "\(amount)")!
        return sourceDecimal / pow(Decimal(10), decimals)
    }
    
    var isETH: Bool {
        return (address == Token.DefaultAddress && symbol == "ETH")
    }
}
