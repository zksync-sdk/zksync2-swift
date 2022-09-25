//
//  Eip712EncoderTests.swift
//  ZKSync2Tests
//
//  Created by Maxim Makhun on 8/16/22.
//

import XCTest
@testable import ZKSync2
import web3swift

class Eip712EncoderTests: XCTestCase {
    
    let message = Mail()
    
    let domain = EIP712Domain("Ether Mail",
                              version: "1",
                              chainId: .mainnet,
                              address: "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC")
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testEncodeType() {
        let encodedMessage = message.encodeType()
        XCTAssertEqual(encodedMessage, "Mail(Person from,Person to,string contents)Person(string name,address wallet)")
    }
    
    func testHashEncodedType() {
        let hash = message.typehash.toHexString().addHexPrefix()
        XCTAssertEqual(hash, "0xa0cedeb2dc280ba39b857546d74f5549c3a1d7bdc2dd96bf881f76108e23dac2")
    }
    
    func testEncodeContentsValue() {
        let hash = EIP712Encoder.encodeValue(message.contents).toHexString().addHexPrefix()
        XCTAssertEqual(hash, "0xb5aadf3154a261abdd9086fc627b61efca26ae5702701d05cd2305f7c52a2fc8")
    }
    
    func testEncodePersonData() {
        let fromHash = EIP712Encoder.encodeValue(message.from).toHexString().addHexPrefix()
        let toHash = EIP712Encoder.encodeValue(message.to).toHexString().addHexPrefix()
        
        XCTAssertEqual(fromHash, "0xfc71e5fa27ff56c350aa531bc129ebdf613b772b6604664f5d8dbe21b85eb0c8")
        XCTAssertEqual(toHash, "0xcd54f074a4af31b4411ff6a60c9719dbd559c221c8ac3492d9d872b041d703d1")
    }
    
    func testEncodeMailData() {
        let messageHash = EIP712Encoder.encodeValue(message).toHexString().addHexPrefix()
        
        XCTAssertEqual(messageHash, "0xc52c0ee5d84264471806290a3f2c4cecfc5490626bf912d01f240d7a274b371e")
    }
    
    func testEncodeDomainMemberValues() {
        let domainNameHash = EIP712Encoder.encodeValue(domain.name).toHexString().addHexPrefix()
        XCTAssertEqual(domainNameHash, "0xc70ef06638535b4881fafcac8287e210e3769ff1a8e91f1b95d6246e61e4d3c6")
        
        let domainVersionHash = EIP712Encoder.encodeValue(domain.version).toHexString().addHexPrefix()
        XCTAssertEqual(domainVersionHash, "0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6")
        
        let domainChainIdHash = EIP712Encoder.encodeValue(domain.chainId).toHexString().addHexPrefix()
        XCTAssertEqual(domainChainIdHash, "0x0000000000000000000000000000000000000000000000000000000000000001")
        
        guard let verifyingContract = domain.verifyingContract else {
            XCTFail("Verifying contract should be valid.")
            return
        }
        let domainVerifyingContractHash = EIP712Encoder.encodeValue(verifyingContract).toHexString().addHexPrefix()
        XCTAssertEqual(domainVerifyingContractHash, "0x000000000000000000000000cccccccccccccccccccccccccccccccccccccccc")
    }
    
    func testEncodeDomainType() {
        let encodedDomainType = domain.encodeType()
        XCTAssertEqual(encodedDomainType, "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
    }
    
    func testEncodeDomainData() {
        let domainHash = EIP712Encoder.encodeValue(domain).toHexString().addHexPrefix()
        XCTAssertEqual(domainHash, "0xf2cee375fa42b42143804025fc449deafd50cc031ca257e0b194a650a912090f")
    }
    
    func testTypedDataToSignedBytes() {
        let typedDataHash = EIP712Encoder.typedDataToSignedBytes(domain, typedData: message).toHexString().addHexPrefix()
        XCTAssertEqual(typedDataHash, "0xbe609aee343fb3c4b28e1df9e632fca64fcfaede20f02e86244efddf30957bd2")
    }
    
    func testEncodeTypes() {
        let address = EthereumAddress("0xe1fab3efd74a77c23b426c302d96372140ff7d0c")!
        let encodedAddress = EIP712Encoder.encodeValue(address).toHexString().addHexPrefix()
        XCTAssertEqual(encodedAddress, "0x000000000000000000000000e1fab3efd74a77c23b426c302d96372140ff7d0c")
        
        let number = UInt8(123)
        let encodedNumber = EIP712Encoder.encodeValue(number).toHexString().addHexPrefix()
        XCTAssertEqual(encodedNumber, "0x000000000000000000000000000000000000000000000000000000000000007b")
    }
}
