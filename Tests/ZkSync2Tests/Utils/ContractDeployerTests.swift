//
//  ContractDeployerTests.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/8/22.
//

import XCTest
@testable import ZkSync2

class ContractDeployerTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testComputeL2Create2AddressActual() {
        
    }
    
    func testComputeL2CreateAddressActual() {
        
    }
    
    func testHashBytecode() {
        let result = ContractDeployer.hashBytecode(Data(fromHex: CounterContract.Binary)!)
        
        let expected = "0x010000517112c421df08d7b49e4dc1312f4ee62268ee4f5683b11d9e2d33525a"
        XCTAssertEqual(result.toHexString().addHexPrefix(), expected)
    }
}
