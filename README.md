# zksync2-swift

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
let signer: EthSigner // Initialize client

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
let signer: EthSigner // Initialize client

let chainID = try! zkSync.web3.eth.getChainIdPromise().wait()

let nonce = try! zkSync.web3.eth.getTransactionCount(address: signer.ethereumAddress,
                                                     onBlock: ZkBlockParameterName.committed.rawValue)
```

## Withdraw funds (ERC20 tokens)

```swift
import ZkSync2

let zkSync: ZkSync // Initialize client
let signer: EthSigner // Initialize client

let chainID = try! zkSync.web3.eth.getChainIdPromise().wait()

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
