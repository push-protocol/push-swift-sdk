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
    .package(url: "https://github.com/web3swift-team/web3swift.git",.upToNextMajor(from: "3.0.0")),

  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Push",
      dependencies: [
        .product(name: "ObjectivePGP", package: "ObjectivePGP"),
        "CryptoSwift",
        .product(name: "web3swift", package: "web3swift")
      ],
      path: "Sources"
    ),
    .testTarget(
      name: "PushTests",
      dependencies: [
        "Push",
        .product(name: "web3swift", package: "web3swift"),
      ], path: "Tests"),
  ]
)
