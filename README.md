# zksync2-swift

## Using examples

The complete examples with various use cases are available [here](https://github.com/zksync-sdk/zksync2-examples/tree/main/swift).

## EthSigner

```swift
import ZkSync2

let chainId = BigUInt(123)

let credentials = Credentials("0x<private_key>")

let signer: EthSigner = PrivateKeyEthSigner(credentials, chainId: chainId)
```

## ZkSyncWallet

```swift
import ZkSync2

let zkSync: ZkSync // Initialize client
let signer: EthSigner // Initialize signer

let wallet = ZkSyncWallet(zkSync, ethSigner: signer, feeToken: Token.ETH)
```

## Deploy contract (Create 2) [EIP-1014](https://eips.ethereum.org/EIPS/eip-1014)

```swift
import ZkSync2

```

## Deploy contract (Create)

```swift
import ZkSync2

```

## Deploy contract via ZkSyncWallet

```swift
import ZkSync2

let wallet: ZkSyncWallet // Initialize wallet

let transactionSendingResult = try! wallet.deploy(Data.fromHex("0x<bytecode_of_the_contract>")!).wait()
```

## Execute contract

```swift
import ZkSync2

```

## Execute contract via ZkSyncWallet

```swift
import ZkSync2
import web3swift

let wallet: ZkSyncWallet // Initialize wallet

let contractAddress: String = "0x<contract_address>"

func incrementFunction(_ value: BigUInt) -> Data {
    let inputs = [
        ABI.Element.InOut(name: "_value", type: .uint(bits: 256))
    ]
    
    let function = ABI.Element.Function(name: "increment",
                                        inputs: inputs,
                                        outputs: [],
                                        constant: false,
                                        payable: false)
    
    let elementFunction: ABI.Element = .function(function)
    
    let parameters: [AnyObject] = [
        value as AnyObject
    ]
    
    guard let encodedFunction = elementFunction.encodeParameters(parameters) else {
        fatalError("Failed to encode function.")
    }
    
    return encodedFunction
}

let transactionSendingResult = try! wallet.execute(contractAddress, encodedFunction: incrementFunction(BigUInt.zero)).wait()
```

## Transfer funds (Native coins)

```swift
import ZkSync2

let zkSync: ZkSync // Initialize client
let signer: EthSigner // Initialize signer

let chainId = try! zkSync.web3.eth.getChainIdPromise().wait()

let amountInWei = Web3.Utils.parseToBigUInt("1", units: .eth)!

let nonce = try! zkSync.web3.eth.getTransactionCountPromise(address: EthereumAddress(signer.address)!,
                                                            onBlock: ZkBlockParameterName.committed.rawValue).wait()

var estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!,
                                                                 to: EthereumAddress("0x<receiver_address>")!,
                                                                 gasPrice: BigUInt.zero,
                                                                 gasLimit: BigUInt.zero,
                                                                 data: Data(hex: "0x"))

let fee = try! zkSync.zksEstimateFee(estimate).wait()

let gasPrice = try! zkSync.web3.eth.getGasPricePromise().wait()

estimate.parameters.EIP712Meta?.gasPerPubdata = fee.gasPerPubdataLimit

var transactionOptions = TransactionOptions.defaultOptions
transactionOptions.type = .eip712
transactionOptions.from = EthereumAddress(signer.address)!
transactionOptions.to = estimate.to
transactionOptions.gasLimit = .manual(fee.gasLimit)
transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
transactionOptions.value = value
transactionOptions.nonce = .manual(nonce)
transactionOptions.chainID = chainId

var ethereumParameters = EthereumParameters(from: transactionOptions)
ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta

var transaction = EthereumTransaction(type: .eip712,
                                      to: estimate.to,
                                      nonce: nonce,
                                      chainID: chainId,
                                      value: value,
                                      data: estimate.data,
                                      parameters: ethereumParameters)

let signature = signer.signTypedData(signer.domain, typedData: transaction).addHexPrefix()

let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
transaction.envelope.v = BigUInt(unmarshalledSignature.v)

let result = try! zkSync.web3.eth.sendRawTransactionPromise(transaction).wait()
```

## Transfer funds (ERC20 tokens)

```swift
import ZkSync2

```

## Transfer funds via ZkSyncWallet

```swift
import ZkSync2

let wallet: ZkSyncWallet // Initialize wallet

let amount = BigUInt(500000000000000000)

let transactionSendingResult = try! wallet.transfer("0x<receiver_address>", amount: amount).wait()

// You can check balance
let balance = try! wallet.getBalance().wait()

// Also, you can convert amount number to decimal
let decimalBalance = Token.ETH.intoDecimal(balance)
```

## Withdraw funds (Native coins)

```swift
import ZkSync2

let zkSync: ZkSync // Initialize client
let signer: EthSigner // Initialize signer

let chainId = try! zkSync.web3.eth.getChainIdPromise().wait()

let nonce = try! zkSync.web3.eth.getTransactionCount(address: signer.ethereumAddress,
                                                     onBlock: ZkBlockParameterName.committed.rawValue)
                                                     
let l2EthBridge = try! EthereumAddress(zkSync.zksGetBridgeContracts().wait().l2EthDefaultBridge)!

let inputs = [
    ABI.Element.InOut(name: "_l1Receiver", type: .address),
    ABI.Element.InOut(name: "_l2Token", type: .address),
    ABI.Element.InOut(name: "_amount", type: .uint(bits: 256))
]

let withdrawFunction = ABI.Element.Function(name: "withdraw",
                                            inputs: inputs,
                                            outputs: [],
                                            constant: false,
                                            payable: false)

let elementFunction: ABI.Element = .function(withdrawFunction)

let amount = BigUInt(1000000000000000000)

let parameters: [AnyObject] = [
    EthereumAddress(signer.address)! as AnyObject,
    EthereumAddress(Token.ETH.l2Address)! as AnyObject,
    amount as AnyObject
]

let calldata = elementFunction.encodeParameters(parameters)!

var estimate = EthereumTransaction.createFunctionCallTransaction(from: EthereumAddress(signer.address)!,
                                                                 to: l2EthBridge,
                                                                 gasPrice: BigUInt.zero,
                                                                 gasLimit: BigUInt.zero,
                                                                 data: calldata)

let fee = try! zkSync.zksEstimateFee(estimate).wait()

let gasPrice = try! zkSync.web3.eth.getGasPricePromise().wait()

estimate.parameters.EIP712Meta?.gasPerPubdata = fee.gasPerPubdataLimit

var transactionOptions = TransactionOptions.defaultOptions
transactionOptions.type = .eip712
transactionOptions.from = EthereumAddress(signer.address)!
transactionOptions.to = estimate.to
transactionOptions.gasLimit = .manual(fee.gasLimit)
transactionOptions.maxPriorityFeePerGas = .manual(fee.maxPriorityFeePerGas)
transactionOptions.maxFeePerGas = .manual(fee.maxFeePerGas)
transactionOptions.value = estimate.value
transactionOptions.nonce = .manual(nonce)
transactionOptions.chainID = chainId

var ethereumParameters = EthereumParameters(from: transactionOptions)
ethereumParameters.EIP712Meta = estimate.parameters.EIP712Meta

var transaction = EthereumTransaction(type: .eip712,
                                      to: estimate.to,
                                      nonce: nonce,
                                      chainID: chainId,
                                      value: estimate.value,
                                      data: estimate.data,
                                      parameters: ethereumParameters)

let signature = signer.signTypedData(signer.domain, typedData: transaction).addHexPrefix()

let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: Data(fromHex: signature)!)!
transaction.envelope.r = BigUInt(fromHex: unmarshalledSignature.r.toHexString().addHexPrefix())!
transaction.envelope.s = BigUInt(fromHex: unmarshalledSignature.s.toHexString().addHexPrefix())!
transaction.envelope.v = BigUInt(unmarshalledSignature.v)

let result = try! zkSync.web3.eth.sendRawTransactionPromise(transaction).wait()
```

## Withdraw funds (ERC20 tokens)

```swift
import ZkSync2

let zkSync: ZkSync // Initialize client
let signer: EthSigner // Initialize signer

let chainId = try! zkSync.web3.eth.getChainIdPromise().wait()

let nonce = try! zkSync.web3.eth.getTransactionCount(address: signer.ethereumAddress,
                                                     onBlock: ZkBlockParameterName.committed.rawValue)
```

## Withdraw funds via ZkSyncWallet

```swift
import ZkSync2

let wallet: ZkSyncWallet // Initialize wallet

let amount = BigUInt(500000000000000000)

// ETH By default
let transactionSendingResult = try! wallet.withdraw("0x<receiver_address>", amount: amount).wait()

// Also we can withdraw ERC20 token
let token: Token

let transactionSendingResult = try! wallet.withdraw("0x<receiver_address>", amount: amount, token: token).wait()
```
