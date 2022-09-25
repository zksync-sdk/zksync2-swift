// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZkSync2",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ZkSync2",
            targets: ["ZkSync2"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/skywinder/web3swift.git",
            from: "2.6.5"
        ),
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
                "Alamofire"
            ]),
        .testTarget(
            name: "ZkSync2Tests",
            dependencies: ["ZkSync2"]),
    ]
)
