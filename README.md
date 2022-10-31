# zksync2-swift

## EthSigner

```swift
import ZkSync2

let chainId = BigUInt(123)

let credentials = Credentials("0x<private_key>")

let signer: EthSigner = PrivateKeyEthSigner(credentials, chainId: chainId)
```

## ZKSyncWallet

```swift
import ZkSync2

let zkSync: ZkSync // Initialize client
let signer: EthSigner // Initialize client

let wallet = ZKSyncWallet(zkSync, ethSigner: signer, feeToken: Token.ETH)
```

## Execute contract via ZkSyncWallet

```swift
import ZkSync2
import web3swift

let wallet: ZKSyncWallet // Initialize wallet

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

## Withdraw funds via ZkSyncWallet

```swift
import ZkSync2

let wallet: ZKSyncWallet // Initialize wallet

let amount = BigUInt(500000000000000000)

// ETH By default
let transactionSendingResult = try! wallet.withdraw("0x<receiver_address>", amount: amount).wait()

// Also we can withdraw ERC20 token
let token: Token

let transactionSendingResult = try! wallet.withdraw("0x<receiver_address>", amount: amount, token: token).wait()
```
