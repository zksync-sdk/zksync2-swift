//
//  TransactionDetails.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 05.03.2023.
//

import Foundation

public struct TransactionDetails: Decodable {
    
    let isL1Originated: Bool
    
    let status: TransactionDetails.Status
    
    let fee: String
    
    let initiatorAddress: String
    
    let receivedAt: Date
    
    let ethCommitTxHash: String
    
    let ethProveTxHash: String
    
    let ethExecuteTxHash: String
}
