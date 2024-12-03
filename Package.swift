// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "zkSync2-swift",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "ZkSync2",
            targets: ["ZkSync2"]),
    ],
    dependencies: [
        .package(url: "https://github.com/zksync-sdk/web3swift", .exact("3.1.2")),
        .package(url: "https://github.com/mxcl/PromiseKit", .exact("6.16.2")),
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            from: "5.4.3"
        )
    ],
    targets: [
        .target(
            name: "ZkSync2",
            dependencies: [
                .product(name: "web3swift", package: "Web3swift"),
                "Alamofire",
                "PromiseKit",
            ]),
        .testTarget(
            name: "ZkSync2Tests",
            dependencies: ["ZkSync2"],
            resources: [
                .process("Resources")
            ]),
    ]
)
