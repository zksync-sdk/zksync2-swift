//
//  Web3Eth.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 9/29/22.
//

import web3swift
import BigInt
import PromiseKit

extension web3.Eth {
    
    func getChainIdPromise() -> Promise<BigUInt> {
        let request = JSONRPCRequestFabric.prepareRequest(.chainId, parameters: [])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue) { response in
            guard let value: BigUInt = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(desc: response.error!.message)
                }
                throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
            }
            return value
        }
    }
    
    func createRequest(_ method: JSONRPCmethod, transaction: EthereumTransaction) -> JSONRPCrequest? {
        guard transaction.sender != nil else { return nil }
        guard let encodedData = transaction.encode() else { return nil }
        let hex = encodedData.toHexString().addHexPrefix().lowercased()
        var request = JSONRPCrequest()
        request.method = method
        let params = [hex] as [Encodable]
        let pars = JSONRPCparams(params: params)
        request.params = pars
        if !request.isValid { return nil }
        
        return request
    }
    
    func estimateFeePromise(_ transaction: EthereumTransaction) -> Promise<Fee> {
        fatalError("Not implemented")
        
//        let queue = web3.requestDispatcher.queue
//        do {
//            guard let request = createRequest(.estimateFee, transaction: transaction) else {
//                throw Web3Error.processingError(desc: "Transaction is invalid")
//            }
//
//            let rp = web3.dispatch(request)
//
//            return rp.map(on: queue) { response in
//
//                print("!!! \(response)")
//
//                //                guard let value: BigUInt = response.getValue() else {
//                //                    if response.error != nil {
//                //                        throw Web3Error.nodeError(desc: response.error!.message)
//                //                    }
//                //                    throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
//                //                }
//            }
//        } catch {
//            let returnPromise = Promise<Fee>.pending()
//            queue.async {
//                returnPromise.resolver.reject(error)
//            }
//            return returnPromise.promise
//        }
    }
}
