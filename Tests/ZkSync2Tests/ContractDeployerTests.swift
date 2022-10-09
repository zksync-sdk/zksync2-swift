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
        
        let expected = "0x00379c09b5568d43b0ac6533a2672ee836815530b412f082f0b2e69915aa50fc"
        XCTAssertEqual(result.toHexString().addHexPrefix(), expected)
    }
}
