//
//  JsonRpc2_0ZkSync.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/19/22.
//

import Foundation
import web3swift
import BigInt

//public class JsonRpc2_0ZkSync extends JsonRpc2_0Web3j implements ZkSync {
//
//    public static final int DEFAULT_BLOCK_COMMIT_TIME = 800;
//
//    public JsonRpc2_0ZkSync(Web3jService web3jService) {
//        super(web3jService);
//    }
//
//    @Override
//    public Request<?, ZksEstimateFee> zksEstimateFee(Transaction transaction) {
//        return new Request<>(
//                "zks_estimateFee", Collections.singletonList(transaction), web3jService, ZksEstimateFee.class);
//    }
//
//    @Override
//    public Request<?, ZksMainContract> zksMainContract() {
//        return new Request<>("zks_getMainContract", Collections.emptyList(), web3jService, ZksMainContract.class);
//    }
//
//    @Override
//    public Request<?, EthSendRawTransaction> zksGetL1WithdrawalTx(String transactionHash) {
//        return new Request<>(
//                "zks_getL1WithdrawalTx", Collections.singletonList(transactionHash), web3jService, EthSendRawTransaction.class);
//    }
//
//    @Override
//    public Request<?, ZksTokens> zksGetConfirmedTokens(Integer from, Short limit) {
//        return new Request<>(
//                "zks_getConfirmedTokens", Arrays.asList(from, limit), web3jService, ZksTokens.class);
//    }
//
//    @Override
//    public Request<?, ZksIsTokenLiquid> zksIsTokenLiquid(String tokenAddress) {
//        return new Request<>(
//                "zks_isTokenLiquid", Collections.singletonList(tokenAddress), web3jService, ZksIsTokenLiquid.class);
//    }
//
//    @Override
//    public Request<?, ZksTokenPrice> zksGetTokenPrice(String tokenAddress) {
//        return new Request<>(
//                "zks_getTokenPrice", Collections.singletonList(tokenAddress), web3jService, ZksTokenPrice.class);
//    }
//
//    @Override
//    public Request<?, ZksL1ChainId> zksL1ChainId() {
//        return new Request<>("zks_L1ChainId", Collections.emptyList(), web3jService, ZksL1ChainId.class);
//    }
//
//    @Override
//    public Request<?, ZksContractDebugInfo> zksGetContractDebugInfo(String contractAddress) {
//        return new Request<>(
//                "zks_getContractDebugInfo", Collections.singletonList(contractAddress), web3jService, ZksContractDebugInfo.class);
//    }
//
//    @Override
//    public Request<?, ZksTransactionTrace> zksGetTransactionTrace(String transactionHash) {
//        return new Request<>(
//                "zks_getTransactionTrace", Collections.singletonList(transactionHash), web3jService, ZksTransactionTrace.class);
//    }
//
//    @Override
//    public Request<?, ZksAccountBalances> zksGetAllAccountBalances(String address) {
//        return new Request<>("zks_getAllAccountBalances", Collections.singletonList(address), web3jService, ZksAccountBalances.class);
//    }
//
//    @Override
//    public Request<?, ZksBridgeAddresses> zksGetBridgeContracts() {
//        return new Request<>("zks_getBridgeContracts", Collections.emptyList(), web3jService, ZksBridgeAddresses.class);
//    }
//
//    @Override
//    public Request<?, ZksMessageProof> zksGetL2ToL1MsgProof(Integer block, String sender, String message, @Nullable Long l2LogPosition) {
//        return new Request<>("zks_getL2ToL1MsgProof", Arrays.asList(block, sender, message), web3jService, ZksMessageProof.class);
//    }
//
//    @Override
//    public Request<?, EthEstimateGas> ethEstimateGas(Transaction transaction) {
//        return new Request<>(
//                "eth_estimateGas", Collections.singletonList(transaction), web3jService, EthEstimateGas.class);
//    }
//}

class JsonRpc2_0ZkSync: ZKSync {
    
    let transport: Transport
    
    init(transport: Transport) {
        self.transport = transport
    }
    
    func zksEstimateFee(_ transaction: Transaction,
                        completion: @escaping (Result<Fee>) -> Void) {
        transport.send(method: "zks_estimateFee",
                       params: [transaction],
                       completion: completion)
    }
    
    func zksMainContract(completion: @escaping (Result<MainContract>) -> Void) {
        transport.send(method: "zks_getMainContract",
                       params: [String](),
                       completion: completion)
    }
    
    func zksGetL1WithdrawalTx(_ transactionHash: String,
                              completion: @escaping (Result<EthSendRawTransaction>) -> Void) {
        transport.send(method: "zks_getL1WithdrawalTx",
                       params: [transactionHash],
                       completion: completion)
    }
    
    func zksGetConfirmedTokens(_ from: Int,
                               limit: Int,
                               completion: @escaping (Result<[Token]>) -> Void) {
        transport.send(method: "zks_getConfirmedTokens",
                       params: [from, limit],
                       completion: completion)
    }
    
    func zksIsTokenLiquid(_ tokenAddress: String,
                          completion: @escaping (Result<Bool>) -> Void) {
        transport.send(method: "zks_isTokenLiquid",
                       params: [tokenAddress],
                       completion: completion)
    }
    
    func zksGetTokenPrice(_ tokenAddress: String,
                          completion: @escaping (Result<Decimal>) -> Void) {
        transport.send(method: "zks_getTokenPrice",
                       params: [tokenAddress],
                       completion: { result in
            completion(result.map({ Decimal(string: $0)! }))
        })
    }
    
    func zksL1ChainId(completion: @escaping (Result<BigUInt>) -> Void) {
        transport.send(method: "zks_L1ChainId",
                       params: [String](),
                       completion: { (result: Result<String>) in
            completion(result.map({ BigUInt($0.stripHexPrefix(), radix: 16)! }))
        })
    }
    
    func zksGetContractDebugInfo(_ contractAddress: String,
                                 completion: @escaping (Result<ContractDebugInfo>) -> Void) {
        transport.send(method: "zks_getContractDebugInfo",
                       params: [contractAddress],
                       completion: completion)
    }
    
    func zksGetTransactionTrace(_ transactionHash: String,
                                completion: @escaping (Result<TransactionTrace>) -> Void) {
        transport.send(method: "zks_getTransactionTrace",
                       params: [transactionHash],
                       completion: completion)
    }
    
    func zksGetAllAccountBalances(_ address: String,
                                  completion: @escaping (Result<Dictionary<String, String>>) -> Void) {
        transport.send(method: "zks_getAllAccountBalances",
                       params: [address],
                       completion: completion)
    }
    
    func zksGetBridgeContracts(_ completion: @escaping (Result<BridgeAddresses>) -> Void) {
        transport.send(method: "zks_getBridgeContracts",
                       params: [String](),
                       completion: completion)
    }
    
    func zksGetL2ToL1MsgProof(_ block: Int,
                              sender: String,
                              message: String,
                              l2LogPosition: Int64, // FIXME: Should l2LogPosition be used?
                              completion: @escaping (Result<MessageProof>) -> Void) {
        transport.send(method: "zks_getL2ToL1MsgProof",
                       params: [String(block), sender, message],
                       completion: completion)
    }
    
    func ethEstimateGas(_ transaction: Transaction,
                        completion: @escaping (Result<EthEstimateGas>) -> Void) {
        transport.send(method: "eth_estimateGas",
                       params: [String](), // TODO: Add transaction support.
                       completion: completion)
    }
}
