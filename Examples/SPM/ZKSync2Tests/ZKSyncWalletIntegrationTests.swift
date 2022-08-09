//
//  ZKSyncWalletIntegrationTests.swift
//  ZKSync2Tests
//
//  Created by Maxim Makhun on 7/26/22.
//

import XCTest
@testable import ZKSync2

class ZKSyncWalletIntegrationTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
//    public void sendTestMoney() {
//        Web3j web3j = Web3j.build(new HttpService("http://206.189.96.247:8545"));
//
//        String account = web3j.ethAccounts().sendAsync().join().getAccounts().get(0);
//
//        EthSendTransaction sent = web3j.ethSendTransaction(
//                        Transaction.createEtherTransaction(account, null, BigInteger.ZERO, BigInteger.valueOf(21_000L),
//                                this.credentials.getAddress(), Convert.toWei("1000", Convert.Unit.ETHER).toBigInteger()))
//                .sendAsync().join();
//
//        assertResponse(sent);
//    }
    
    func testSendMoney() {
        //        String account = web3j.ethAccounts().sendAsync().join().getAccounts().get(0);
        // Look at: getAccountsPromise
    }
    
//    public void testDeposit() {
//        TransactionReceipt receipt = EthereumProvider
//                .load(wallet.getZksync(), Web3j.build(new HttpService("http://206.189.96.247:8545")), this.credentials).join()
//                .deposit(Token.ETH, Convert.toWei("999", Convert.Unit.ETHER).toBigInteger(), credentials.getAddress()).join();
//
//        System.out.println(receipt);
//    }
    
    func testDeposit() {
        
    }
    
//    public void testTransfer() throws Exception {
//        BigInteger amount = Token.ETH.toBigInteger(0.5);
//        BigInteger desiredFee = BigInteger.valueOf(10560L).multiply(BigInteger.valueOf(28572L)); // Only for test
//        EthGetBalance balance = wallet.getZksync()
//                .ethGetBalance(this.credentials.getAddress(), ZkBlockParameterName.COMMITTED, Token.ETH.getAddress())
//                .send();
//
//        assertResponse(balance);
//
//        TransactionReceipt receipt = wallet.transfer(new Address(BigInteger.ONE).getValue(), amount).send();
//
//        assertTrue(receipt.isStatusOK());
//
//        EthGetBalance balanceNew = wallet.getZksync()
//                .ethGetBalance(this.credentials.getAddress(), ZkBlockParameterName.COMMITTED, Token.ETH.getAddress())
//                .send();
//
//        assertResponse(balanceNew);
//
//        assertEquals(balance.getBalance().subtract(amount).subtract(desiredFee), balanceNew.getBalance());
//    }
    
    func testTransfer() {
        
    }
    
//    public void testWithdraw() throws Exception {
//        BigInteger amount = Token.ETH.toBigInteger(0.5);
//        BigInteger desiredFee = BigInteger.valueOf(10560L).multiply(BigInteger.valueOf(28572L)); // Only for test
//        EthGetBalance balance = wallet.getZksync()
//                .ethGetBalance(this.credentials.getAddress(), ZkBlockParameterName.COMMITTED, Token.ETH.getAddress())
//                .send();
//
//        assertResponse(balance);
//
//        TransactionReceipt receipt = wallet.withdraw(this.credentials.getAddress(), amount).send();
//
//        assertTrue(receipt.isStatusOK());
//
//        EthGetBalance balanceNew = wallet.getZksync()
//                .ethGetBalance(this.credentials.getAddress(), ZkBlockParameterName.COMMITTED, Token.ETH.getAddress())
//                .send();
//
//        assertResponse(balanceNew);
//
//        assertEquals(balance.getBalance().subtract(amount).subtract(desiredFee), balanceNew.getBalance());
//    }
    
    func testWithdraw() {
        
    }
    
//    public void testDeploy() throws Exception {
//
//        BigInteger nonce = wallet.getNonce().send();
//        String contractAddress = ContractUtils.generateContractAddress(this.credentials.getAddress(), nonce);
//
//        EthGetCode code = wallet.getZksync().ethGetCode(contractAddress, DefaultBlockParameterName.PENDING).send();
//
//        assertResponse(code);
//        assertEquals("0x", code.getCode());
//
//        TransactionReceipt receipt = wallet.deploy(Numeric.hexStringToByteArray(CounterContract.BINARY)).send();
//
//        assertTrue(receipt.isStatusOK());
//
//        EthGetCode codeDeployed = wallet.getZksync().ethGetCode(contractAddress, DefaultBlockParameterName.PENDING).send();
//
//        assertResponse(codeDeployed);
//        assertNotEquals("0x", codeDeployed.getCode());
//    }
    
    func testDeploy() {
        
    }
    
//    testDeployWithConstructor ???
    
//    public void testExecute() throws Exception {
//        TransactionReceipt deployed = wallet.deploy(Numeric.hexStringToByteArray(CounterContract.BINARY)).send();
//
//        assertTrue(deployed.isStatusOK());
//        String contractAddress = deployed.getContractAddress();
//
//        TransactionManager transactionManager = new ZkSyncTransactionManager(wallet.getZksync(), wallet.getSigner(), wallet.getFeeProvider());
//        CounterContract contract = CounterContract.load(contractAddress, wallet.getZksync(), transactionManager, new DefaultGasProvider());
//
//        BigInteger before = contract.get().send();
//        assertEquals(BigInteger.ZERO, before);
//
//        TransactionReceipt receipt = wallet.execute(contractAddress, CounterContract.encodeIncrement(BigInteger.TEN)).send();
//        assertTrue(receipt.isStatusOK());
//
//        BigInteger after = contract.get().send();
//        assertEquals(BigInteger.TEN, after);
//    }
    
    func testExecute() {
        
    }
}
