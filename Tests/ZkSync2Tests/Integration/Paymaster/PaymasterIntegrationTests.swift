//
//  PaymasterIntegrationTests.swift
//
//
//  Created by Petar Kopestinskij on 13.3.24..
//

import XCTest
@testable import ZkSync2
import web3swift
import Web3Core
import Foundation
import BigInt

class PaymasterTests: BaseIntegrationEnv {
    
    let SALT = "0x293328ad84b118194c65a0dc0defdb6483740d3163fd99b260907e15f2e2f642"
    let PAYMASTER_ADDRESS = "0xed472c4e64a5e0d62ef755f177eff5165eee1864"
    var TOKEN_ADDRESS = "0xd7C1f346AE39Df4B5909eDb6744FFB2d5086015d"
    
    func deployToken() async {
        let inputs = [
            ABI.Element.InOut(name: "name_", type: .string),
            ABI.Element.InOut(name: "symbol_", type: .string),
            ABI.Element.InOut(name: "decimals_", type: .uint(bits: 256))

        ]
        
        let constructor = ABI.Element.Constructor(inputs: inputs,
                                                  constant: false,
                                                  payable: false)
        
        let elementConstructor: ABI.Element = .constructor(constructor)
        
        let parameters: [AnyObject] = [
            "Ducat" as AnyObject,
            "Ducat" as AnyObject,
            18 as AnyObject
        ]
        
        guard elementConstructor.encodeParameters(parameters) != nil else {
            fatalError("Failed to encode function.")
        }
        
        let ducatTokenURL = Bundle.module.url(forResource: "ducatToken", withExtension: "hex")!
        let ducatTokenBinary = try! String(contentsOf: ducatTokenURL, encoding: .ascii).trim()
                
        let tokenContract = self.zkSync.web3.contract(Web3Utils.IERC20, at: EthereumAddress(TOKEN_ADDRESS))
        let tx = tokenContract?.createWriteOperation("mint", parameters: [self.signer.address, 15])
        
        let nonce = try! await wallet.walletL2.getNonce()
        let mintResult = await AccountsUtil.estimateAndSend(zkSync: self.zkSync, signer: self.signerL2, tx!.transaction, nonce: nonce)
        XCTAssertNotNil(mintResult)

        let mintReceipt = await ZkSyncTransactionReceiptProcessor(zkSync: self.zkSync).waitForTransactionReceipt(hash: mintResult.hash)
        XCTAssertNotNil(mintReceipt)
    }
    
    func testDepolyPaymaster() async {
        await deployToken()
        let inputs = [
            ABI.Element.InOut(name: "_erc20", type: .address)
        ]
        
        let constructor = ABI.Element.Constructor(inputs: inputs,
                                                  constant: false,
                                                  payable: false)
        
        let elementConstructor: ABI.Element = .constructor(constructor)
        
        let parameters: [AnyObject] = [
            EthereumAddress(TOKEN_ADDRESS) as AnyObject
        ]
        
        guard let encodedConstructor = elementConstructor.encodeParameters(parameters) else {
            fatalError("Failed to encode function.")
        }
                
        let customPaymasterBinaryFileURL = Bundle.module.url(forResource: "customPaymasterBinary", withExtension: "hex")!
        let customPaymasterBinaryContents = try! String(contentsOf: customPaymasterBinaryFileURL, encoding: .ascii).trim()
        
        let res = await self.wallet.deployer.deployAccountWithCreate2(Data.fromHex(customPaymasterBinaryContents)!, salt: Data(hex: SALT), calldata: encodedConstructor, nonce: nil)
        
        let receipt = await ZkSyncTransactionReceiptProcessor(zkSync: self.zkSync).waitForTransactionReceipt(hash: res.hash)
        print(receipt?.contractAddress)
        
        let faucetRes = await wallet.walletL2.transfer(PAYMASTER_ADDRESS, amount: 1_000_000_000_000_000_000)
        XCTAssertNotNil(faucetRes)

        let faucetReceipt = await ZkSyncTransactionReceiptProcessor(zkSync: self.zkSync).waitForTransactionReceipt(hash: faucetRes.hash)
        XCTAssertNotNil(faucetReceipt)
    }
}
