//
//  ZkTransactionEncoderTests.swift
//  ZkSync2Tests
//
//  Created by Maxim Makhun on 9/24/22.
//

import XCTest
@testable import ZkSync2
import web3swift
import BigInt

class ZkTransactionEncoderTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testEncodeWithdraw() {
        let inputs = [
            ABI.Element.InOut(name: "_l1Receiver", type: .address),
            ABI.Element.InOut(name: "_l2Token", type: .address),
            ABI.Element.InOut(name: "_amount", type: .uint(bits: 256))
        ]
        
        let function = ABI.Element.Function(name: "withdraw",
                                            inputs: inputs,
                                            outputs: [],
                                            constant: false,
                                            payable: false)
        
        let elementFunction: ABI.Element = .function(function)
        
        let parameters: [AnyObject] = [
            "0x7e5f4552091a69125d5dfcb7b8c2659029395bdf" as AnyObject,
            Token.ETH.l2Address as AnyObject,
            BigInt("1000000000000000000") as AnyObject
        ]
        
        guard let calldata = elementFunction.encodeParameters(parameters) else {
            XCTFail("Encoded function should be valid.")
            return
        }
        
        let expectedCalldata = "0xd9caed120000000000000000000000007e5f4552091a69125d5dfcb7b8c2659029395bdf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000de0b6b3a7640000"
        XCTAssertEqual(calldata.toHexString().addHexPrefix(), expectedCalldata)
    }
    
    func testEncodeDeploy() {
        
    }
    
    func testEncodeExecute() {
        
    }
}
