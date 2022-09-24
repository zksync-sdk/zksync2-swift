//
//  PrivateKeyEthSignerTests.swift
//  ZKSync2Tests
//
//  Created by Maxim Makhun on 9/20/22.
//

import XCTest
import web3swift
@testable import ZKSync2

class PrivateKeyEthSignerTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testSignAndVerifyDataWithPrefix() {
        guard let data = "cow".data(using: .utf8),
              let privateKey = Web3.Utils.sha3(data)?.toHexString() else {
            XCTFail("Initial data is not valid.")
            return
        }
        
        let privateKeyEthSigner = PrivateKeyEthSigner(privateKey)
        
        let message = "123".data(using: .ascii)!
        let signatureWithPrefix = privateKeyEthSigner.signMessage(message)
        XCTAssertEqual(signatureWithPrefix, "0x49baa2d8e2b4ca55fb485bdd89b193b9ce7c72987bbc9788972b34bece20067374459dae5a3c5d8c8680501ae8e97fdcbdd650623048eebef637a8650dc4698b1b")
        
        let signatureWithPrefixIsValid = privateKeyEthSigner.verifySignature(signatureWithPrefix,
                                                                             message: message)
        XCTAssertTrue(signatureWithPrefixIsValid)
    }
    
    // TODO: Fix issues with signing and verification of non-prefixed data.
    func disabled_testSignAndVerifyDataWithNoPrefix() {
        guard let data = "cow".data(using: .utf8),
              let privateKey = Web3.Utils.sha3(data)?.toHexString() else {
            XCTFail("Initial data is not valid.")
            return
        }
        
        let privateKeyEthSigner = PrivateKeyEthSigner(privateKey)
        
        let message = "123".data(using: .ascii)!
        let signatureWithNoPrefix = privateKeyEthSigner.signMessage(message, addPrefix: false)
        XCTAssertEqual(signatureWithNoPrefix, "0xe84c3fc9d7a2fb549c7995e97eeec0cd75331acd15edf48f7e94c9576acf2ca7094bc5562d7891e6f2ee33bd08a42a334a4d043e9beeb1830f8a14dbeb9fa5801b")
        
        let signatureWithNoPrefixIsValid = privateKeyEthSigner.verifySignature(signatureWithNoPrefix,
                                                                               message: message,
                                                                               prefixed: false)
        XCTAssertTrue(signatureWithNoPrefixIsValid)
    }
    
    // TODO: Implement tests for signing and verification of typed data.
}
