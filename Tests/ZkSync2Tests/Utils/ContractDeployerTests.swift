//
//  ContractDeployerTests.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 10/8/22.
//

import XCTest
import web3swift
import Web3Core
import BigInt
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
                                                              bytecode: Data(from: CounterContract.Binary)!,
                                                              constructor: Data(),
                                                              salt: salt)
        
        XCTAssertEqual(expected, result)
    }
    
    func testComputeL2CreateAddressActual() {
        let expected = EthereumAddress("0x5107b7154dfc1d3b7f1c4e19b5087e1d3393bcf4")!
        
        let sender = EthereumAddress("0x7e5f4552091a69125d5dfcb7b8c2659029395bdf")!
        
        let result = ContractDeployer.computeL2CreateAddress(sender, nonce: BigUInt(3))
        
        XCTAssertEqual(expected, result)
    }
    
    func testHashBytecode() {
        let result = ContractDeployer.hashBytecode(Data(from: CounterContract.Binary)!)
        
        let expected = "0x010000517112c421df08d7b49e4dc1312f4ee62268ee4f5683b11d9e2d33525a"
        XCTAssertEqual(result.toHexString(), expected)
    }
}
