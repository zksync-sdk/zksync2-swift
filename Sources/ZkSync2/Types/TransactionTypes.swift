//
//  File.swift
//  
//
//  Created by Petar Kopestinskij on 4.3.24..
//

import Foundation
import Web3Core
import BigInt

public struct RequestExecuteTransaction {
    var contractAddress: Address
    var calldata: Data
    var from: Address?
    var l2Value: BigUInt?
    var l2GasLimit: BigUInt?
    var operatorTip: BigUInt?
    var gasPerPubdataByte: BigUInt?
    var refundRecipient: Address?
    var factoryDeps: [Data]?
    var options: TransactionOption?
}

public struct DepositTransaction {
    var token: Address
    var amount: BigUInt
    var to: Address?
    var approveERC20: Bool?
    var operatorTip: BigUInt?
    var bridgeAddress: Address?
    var l2GasLimit: BigUInt?
    var gasPerPubdataByte: BigUInt?
    var customBridgeData: Data?
    var refundRecipient: Address?
    var options: TransactionOption?
}

public struct TransactionOption {
    var from: Address?
    var maxPriorityFeePerGas: BigUInt?
    var maxFeePerGas: BigUInt?
    var gasPrice: BigUInt?
    var value: BigUInt?
    var chainID: BigUInt?
    var gasLimit: BigUInt?
    var nonce: BigUInt?
}

