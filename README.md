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

## Withdraw funds via ZkSyncWallet

```swift
let wallet: ZKSyncWallet // Initialize wallet

let amount = BigUInt(500000000000000000)

// ETH By default
let transactionSendingResult = try! wallet.withdraw("0x<receiver_address>", amount: amount).wait()

// Also we can withdraw ERC20 token
let token: Token

let transactionSendingResult = try! wallet.withdraw("0x<receiver_address>", amount: amount, token: token).wait()
```
