//
//  Eip712Domain.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 8/14/22.
//

import Foundation
import BigInt
import web3swift

//@Data
//@AllArgsConstructor
//public class Eip712Domain implements Structurable {
//
//    public static final String NAME = "zkSync";
//    public static final String VERSION = "2";
//
//    public static Eip712Domain defaultDomain(ZkSyncNetwork chainId) {
//        return new Eip712Domain(new Utf8String(NAME), new Utf8String(VERSION), new Uint256(chainId.getChainId()), Address.DEFAULT);
//    }
//
//    public static Eip712Domain defaultDomain(Long chainId) {
//        return new Eip712Domain(new Utf8String(NAME), new Utf8String(VERSION), new Uint256(chainId), Address.DEFAULT);
//    }
//
//    public Eip712Domain(String name, String version, ZkSyncNetwork chainId, String address) {
//        this(new Utf8String(name), new Utf8String(version), new Uint256(chainId.getChainId()), new Address(address));
//    }
//
//    public Eip712Domain(String name, String version, Long chainId, String address) {
//        this(new Utf8String(name), new Utf8String(version), new Uint256(chainId), new Address(address));
//    }
//
//    private Utf8String name;
//
//    private Utf8String version;
//
//    private Uint256 chainId;
//
//    private Address verifyingContract;
//
//    @Override
//    public String getType() {
//        return "EIP712Domain";
//    }
//
//    @Override
//    public List<Pair<String, Type<?>>> eip712types() {
//        return new ArrayList<Pair<String, Type<?>>>() {{
//            add(Pair.of("name", name));
//            add(Pair.of("version", version));
//            add(Pair.of("chainId", chainId));
//            add(Pair.of("verifyingContract", verifyingContract));
//        }};
//    }
//}

// ZKSync2 (Java): Eip712Domain.java
class Eip712Domain {
    
    // public static final String NAME = "zkSync";
    static let name = "zkSync"
    
    // public static final String VERSION = "2";
    static let version = "2"
    
    // private Utf8String name;
    let name: String
    
    // private Utf8String version;
    let version: String
    
    // private Uint256 chainId;
    let chainId: Int
    
    // private Address verifyingContract;
    let verifyingContract: EthereumAddress
    
    //    public static Eip712Domain defaultDomain(ZkSyncNetwork chainId) {
    //        return new Eip712Domain(new Utf8String(NAME), new Utf8String(VERSION), new Uint256(chainId.getChainId()), Address.DEFAULT);
    //    }
    init(_ chainId: ZkSyncNetwork) {
        self.name = Eip712Domain.name
        self.version = Eip712Domain.version
        self.chainId = chainId.rawValue
        self.verifyingContract = EthereumAddress.default!
    }
    
    //    public static Eip712Domain defaultDomain(Long chainId) {
    //        return new Eip712Domain(new Utf8String(NAME), new Utf8String(VERSION), new Uint256(chainId), Address.DEFAULT);
    //    }
}

extension EthereumAddress {
    
    static let `default` = EthereumAddress("")
}
