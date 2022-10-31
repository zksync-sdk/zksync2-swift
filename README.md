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
