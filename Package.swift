// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZKSync2",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ZKSync2",
            targets: ["ZKSync2"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/skywinder/web3swift.git",
            from: "2.6.5"
        )
    ],
    targets: [
        .target(
            name: "ZKSync2",
            dependencies: [
                .product(name: "web3swift", package: "Web3swift")
            ]),
        .testTarget(
            name: "ZKSync2Tests",
            dependencies: ["ZKSync2"]),
    ]
)
