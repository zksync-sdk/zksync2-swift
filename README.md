# 🚀 zksync2-swift Swift SDK 🚀

![Era Logo](https://github.com/matter-labs/era-contracts/raw/main/eraLogo.svg)

In order to provide easy access to all the features of zkSync Era, the `zksync2-swift` Swift SDK was created,
which is made in a way that has an interface very similar to those of [web3swift](https://github.com/web3swift-team/web3swift). In
fact, `web3swift` is a peer dependency of our library is inherited from the corresponding `web3swift`.

While most of the existing SDKs should work out of the box, deploying smart contracts or using unique zkSync features,
like account abstraction, requires providing additional fields to those that Ethereum transactions have by default.

The library is made in such a way that after replacing `web3swift` with `zksync2-swift` most client apps will work out of
box.

🔗 For a detailed walkthrough, refer to the [official documentation](https://docs.zksync.io/sdk/swift/getting-started).

## 📌 Overview

To begin, it is useful to have a basic understanding of the types of objects available and what they are responsible for, at a high level:

-   `ZkSyncClient` provides connection to the zkSync Era blockchain, which allows querying the blockchain state, such as account, block or transaction details,
    querying event logs or evaluating read-only code using call. Additionally, the client facilitates writing to the blockchain by sending
    transactions.
-   `Wallet` wraps all operations that interact with an account. An account generally has a private key, which can be used to sign a variety of
    types of payloads. It provides easy usage of the most common features.

## 🛠 Prerequisites

- `IOS: >=13.0`
- `MacOS: >=11.0`

## 📥 Installation & Setup

### CocoaPods Integration

To install zkSync via CocoaPods, add zkSync2 pod to the Podfile:

```
 pod 'zkSync2-swift'
```

### Swift Package Manager Integration

To install zkSync via Swift Package Manager, add zkSync2 to the Package Dependencies:

```
 'github.com/zksync-sdk/zksync2-swift'
```

### Connect to the zkSync Era network:

Once you have integrated zkSync2 dependencies, connect to zkSync using the endpoint of the operator node.

```swift
var zkSync: ZkSyncClient= BaseClient(URL(string: "https://sepolia.era.zksync.dev"))
```

### Get the latest block number

```swift
var blockNumber = try await zkSync.web3.eth.blockNumber()
```

### Get the latest block

```swift
var block = try await zkSync.web3.eth.block(by: .latest)
```

### Create a wallet

```ts
let walletL1 = WalletL1(self.zkSync, ethClient: self.l1Web3, web3: self.l1Web3.web3, ethSigner: self.signer)
let walletL2 = WalletL2(self.zkSync, ethClient: self.l1Web3, web3: self.zkSync.web3, ethSigner: self.signerL2)
let baseDeployer = BaseDeployer(adapterL2: walletL2, signer: self.signerL2)
let wallet = wallet = Wallet(walletL1: walletL1, walletL2: walletL2, deployer: baseDeployer)
```

### Check account balances

```ts
let balanceL1 = await wallet.walletL1.balanceL1()

let balanceL2 = try! await wallet.walletL2.getBalance()
```

### Transfer funds

Transfer funds among accounts on L2 network.

```ts
let result = await wallet.walletL2.transfer("<RECEIVER_ADDRESS>", amount: BigUInt(10000000))
```

### Deposit funds

Transfer funds from L1 to L2 network.

```ts
let tx = DepositTransaction(token: ZkSyncAddresses.EthAddress, 
    amount: BigUInt(10000000))
        
let result = try! await wallet.walletL1.deposit(transaction: tx)
```

### Withdraw funds

Transfer funds from L2 to L1 network.

```ts
let result = try! await wallet.walletL2.withdraw(amount, to: nil, token: ZkSyncAddresses.EthAddress)
```

## 🤖 Running tests

In order to run test you need to run [local-setup](https://github.com/matter-labs/local-setup) on your machine.
For running tests, use:

```shell
swift test --filter EIP712EncoderTests --skip EIP712EncoderTests.testEncodeDomainMemberValues;
swift test --filter Transaction712Tests --skip Transaction712Tests.testSerializeToEIP712Message;
swift test --filter ContractDeployerTests;
swift test --filter EthereumKeystoreV3Tests;
swift test --filter ZKSyncWeb3RpcIntegrationTests;
swift test --filter ZkSyncWalletIntegrationTests;
```

## 🤝 Contributing

We welcome contributions from the community! If you're interested in contributing to the `zksync2-swift` Swift SDK,
please take a look at our [CONTRIBUTING.md](./.github/CONTRIBUTING.md) for guidelines and details on the process.

Thank you for making `zksync2-swift` Swift SDK better! 🙌
