//
//  DepositManager.swift
//  zkSync-Demo
//
//  Created by Bojan on 14.5.23..
//

import Foundation
import BigInt
#if canImport(web3swift)
import web3swift
#else
import web3swift_zksync
#endif

class DepositManager: BaseManager {
    func deposit(callback: @escaping (() -> Void)) {
        let value: BigUInt = 1
        
        // deposit on l1
        // get hash from priorityOp
        
        //        self.aaaa = try! DefaultEthereumProvider.load(zkSync, web3: zkSync.web3, gasProvider: DefaultGasProvider()).wait()
        //
        //        print("dep", self.aaaa)
        
        //        zkSync.zksGetBridgeContracts { result in
        //            switch result {
        //            case .success(let bridgeAddresses):
        let l1ERC20Bridge = zkSync.web3.contract(Web3.Utils.IL1Bridge,
                                                 at: EthereumAddress("0x4ee775658259028d399f4cf9d637b14773472988"))!
        
        zkSync.zksMainContract { result in
            DispatchQueue.global().async {
                switch result {
                case .success(let address):
                    let l1EthBridge = self.eth.contract(Web3.Utils.IZkSync,
                                                                at: EthereumAddress(address))!
                    
                    let defaultEthereumProvider = DefaultEthereumProvider(self.eth, l1ERC20Bridge: l1ERC20Bridge, zkSyncContract: l1EthBridge, gasProvider: DefaultGasProvider())
                    
                    let token = Token(l1Address: "0x36615Cf349d7F6344891B1e7CA7C72883F5dc049", l2Address: Token.DefaultAddress, symbol: "ETH", decimals: 18)
                    
                    let result = try! defaultEthereumProvider.deposit(with: token, amount: value, operatorTips: BigUInt(0.0001), to: "0x36615Cf349d7F6344891B1e7CA7C72883F5dc049").wait()
                    
                    //# Get ZkSync contract on L1 network
                    //zksync_contract = ZkSyncContract(zksync_provider.zksync.main_contract_address, eth_web3, account)
                    let zksync_contract = defaultEthereumProvider.zkSyncContract
                    
                    let parser = zksync_contract?.createEventParser("NewPriorityRequest", filter: nil)
                    let logs = try! parser?.parseTransactionByHash(result.hash.data(using: .utf8)!)
                    
                    
                    //# Get hash of deposit transaction on L2 network
                    //l2_hash = zksync_provider.zksync.get_l2_hash_from_priority_op(l1_tx_receipt, zksync_contract)
                    let hash = ""//111 zkSync.get_l2_hash_from_priority_op()
                    
                    //# Wait for deposit transaction on L2 network to be finalized (5-7 minutes)
                    //            print("Waiting for deposit transaction on L2 network to be finalized (5-7 minutes)")
                    //l2_tx_receipt = zksync_provider.zksync.wait_for_transaction_receipt(transaction_hash=l2_hash,
                    //                                                                                timeout=360,
                    //                                                                                poll_latency=10)
                    //            let l2 = zkSync.wait_for_transaction_receipt(0, limit: 0) { result in
                    //
                    //            }
                    //
                    //            zkSync.web3.eth
                    
                    //# return deposit transaction hashes from L1 and L2 networks
                    //return l1_tx_receipt['transactionHash'].hex(), l2_tx_receipt['transactionHash'].hex()
                    
                    callback()
                default: return
                }
            }
        }
    }
}
