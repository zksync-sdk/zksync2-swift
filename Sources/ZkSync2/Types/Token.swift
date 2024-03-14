//
//  Token.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt

public struct Token: TokenId, Decodable {
    
    public static let DefaultAddress = "0x0000000000000000000000000000000000000000"
    
    public static var ETH: Token {
        return Token(l1Address: Token.DefaultAddress,
                     l2Address: Token.DefaultAddress,
                     symbol: "ETH",
                     decimals: 18)
    }
    
    public let l1Address: String
    public let l2Address: String
    public let symbol: String
    public let decimals: Int
    
    public init(l1Address: String, l2Address: String, symbol: String, decimals: Int) {
        self.l1Address = l1Address
        self.l2Address = l2Address
        self.symbol = symbol
        self.decimals = decimals
    }
    
    public func intoDecimal(_ amount: BigUInt) -> Decimal {
        let sourceDecimal = Decimal(string: "\(amount)")!
        return sourceDecimal / pow(Decimal(10), decimals)
    }
    
    var isETH: Bool {
        return l2Address == Token.DefaultAddress && symbol == "ETH"
    }
}
