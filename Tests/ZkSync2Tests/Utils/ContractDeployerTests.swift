//
//  ContractDeployerTests.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/8/22.
//

import XCTest
import web3swift
@testable import ZkSync2

class ContractDeployerTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testComputeL2Create2AddressActual() {
        let expected = EthereumAddress("0x0790aff699b38f40929840469a72fb40e9763716")!
        let salt = Data(capacity: 32)
        
        let sender = EthereumAddress("0xa909312acfc0ed4370b8bd20dfe41c8ff6595194")!
        
        let result = ContractDeployer.computeL2Create2Address(sender,
                                                              bytecode: Data(fromHex: CounterContract.Binary)!,
                                                              constructor: Data(),
                                                              salt: salt)
        
        XCTAssertEqual(expected, result)
    }
    
    func testComputeL2CreateAddressActual() {
        
    }
    
    func testHashBytecode() {
        let result = ContractDeployer.hashBytecode(Data(fromHex: CounterContract.Binary)!)
        
        let expected = "0x010000517112c421df08d7b49e4dc1312f4ee62268ee4f5683b11d9e2d33525a"
        XCTAssertEqual(result.toHexString().addHexPrefix(), expected)
    }
}
