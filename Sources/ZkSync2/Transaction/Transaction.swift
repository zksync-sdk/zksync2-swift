//
//  Transaction.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/17/22.
//

import Foundation
import BigInt
import web3swift

struct EIP712Meta {
    
    var ergsPerPubdata: BigInt
}

// ZkSync2 (Java): Transaction.java
struct Transaction: Encodable {
    
//    var from: String
//
//    var to: String
//
//    var gas: BigInt
//
//    var gasPrice: BigInt
//
//    var value: BigInt
//
//    var data: String
//
//    var transactionType: UInt
//
////    AccessListObject
////    var accessListEntry: AccessListEntry
//
//    var eip712Meta: EIP712Meta
//
//    init(from: String,
//         to: String,
//         gas: BigInt,
//         gasPrice: BigInt,
//         value: BigInt,
//         data: String,
//         transactionType: UInt,
////         accessListEntry: AccessListEntry,
//         eip712Meta: EIP712Meta) {
//        self.from = from
//        self.to = to
//        self.gas = gas
//        self.gasPrice = gasPrice
//        self.value = value
//        self.data = data
//        self.transactionType = 0x71
////        self.accessListEntry = accessListEntry
//        self.eip712Meta = eip712Meta
//    }
//
////    public static Transaction createFunctionCallTransaction(
////            String from,
////            String to,
////            BigInteger ergsPrice,
////            BigInteger ergsLimit,
////            BigInteger value,
////            String data
////    ) {
////        Eip712Meta meta = new Eip712Meta(BigInteger.valueOf(160000L), null, null, null);
////        return new Transaction(from, to, ergsPrice, ergsLimit, value, data, meta);
////    }
//
//    static func createFunctionCallTransaction(from: String,
//                                              to: String,
//                                              ergsPrice: BigInt,
//                                              ergsLimit: BigInt,
//                                              value: BigInt,
//                                              data: String) -> Transaction {
//        let eip712Meta = EIP712Meta(ergsPerPubdata: BigInt(16000))
//        return Transaction(from: from,
//                           to: to,
//                           gas: ergsPrice,
//                           gasPrice: ergsLimit,
//                           value: value,
//                           data: data,
//                           transactionType: 0x71,
////                           accessListEntry: <#T##AccessListEntry#>,
//                           eip712Meta: eip712Meta)
//    }
}
