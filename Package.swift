// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Push",
  platforms: [.iOS(.v14), .macOS(.v11)],
  dependencies: [
    .package(url: "https://github.com/Boilertalk/Web3.swift.git", from: "0.6.0"),
    .package(url: "https://github.com/krzyzanowskim/ObjectivePGP.git", from: "0.99.4")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .executableTarget(
      name: "Push",
      dependencies: [
        .product(name: "Web3", package: "Web3.swift"),
        .product(name: "Web3PromiseKit", package: "Web3.swift"),
        .product(name: "Web3ContractABI", package: "Web3.swift"),
        .product(name: "ObjectivePGP", package: "ObjectivePGP")
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
