// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Push",
  platforms: [.iOS(.v14), .macOS(.v11)],
  products: [
    .library(name: "Push", targets: ["Push"])
  ],
  dependencies: [
    .package(url: "https://github.com/krzyzanowskim/ObjectivePGP.git", from: "0.99.4"),
    .package(
      url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.5.1")),
    .package(url: "https://github.com/Boilertalk/Web3.swift.git", from: "0.5.3")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Push",
      dependencies: [
        .product(name: "ObjectivePGP", package: "ObjectivePGP"),
         .product(name: "Web3", package: "Web3.swift"),
            .product(name: "Web3PromiseKit", package: "Web3.swift"),
            .product(name: "Web3ContractABI", package: "Web3.swift"),
        // "web3.swift",
        "CryptoSwift",
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
