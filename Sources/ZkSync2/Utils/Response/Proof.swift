//
//  File.swift
//  
//
//  Created by Petar Kopestinskij on 15.3.24..
//

import Foundation
import Web3Core

public struct Proof: Codable{
    let address: EthereumAddress
    let storageProof: [StorageProof]
}

public struct StorageProof: Codable{
    let key: String
    let value: String
    let index: Int
    let proof: [String]
}
