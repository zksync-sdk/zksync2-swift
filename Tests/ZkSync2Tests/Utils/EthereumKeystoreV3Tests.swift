//
//  EthereumKeystoreV3Tests.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 9/29/22.
//

import XCTest
import BigInt
import web3swift
import ZkSync2

final class EthereumKeystoreV3Tests: XCTestCase {

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {

    }
    
    func testCredentials() {
        let oneDataString = BigUInt.one.data16.toHexString().addHexPrefix()
        XCTAssertEqual(oneDataString, "0x00000000000000000000000000000001")
        
        var credentials = Credentials(BigUInt.one.data32)
        XCTAssertEqual(credentials.address.lowercased(), "0x7e5f4552091a69125d5dfcb7b8c2659029395bdf")
        
        credentials = Credentials(BigUInt.one)
        XCTAssertEqual(credentials.address.lowercased(), "0x7e5f4552091a69125d5dfcb7b8c2659029395bdf")
    }
}
