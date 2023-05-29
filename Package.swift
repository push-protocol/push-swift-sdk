// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Push",
  platforms: [.iOS(.v14), .macOS(.v11)],
  products: [
    .library(name: "Push", targets: ["Push"]),
  ],
  dependencies: [
    .package(url: "https://github.com/krzyzanowskim/ObjectivePGP.git", from: "0.99.4"),
    .package(url: "https://github.com/GigaBitcoin/secp256k1.swift.git", exact: "0.10.0"),
    .package(url: "https://github.com/argentlabs/web3.swift", from: "1.1.0"),
    .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.7.1"))
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Push",
      dependencies: [
        .product(name: "ObjectivePGP", package: "ObjectivePGP"),
        .product(name: "secp256k1", package: "secp256k1.swift"),
				"web3.swift",
        "CryptoSwift"
      ],
      path: "Sources"
    ),

    .testTarget(
      name: "PushTests",
      dependencies: [
        "Push"
      ], path: "Tests"),
  ]
)
