// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "snark-swift",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "snark-swift",
            targets: ["snark-swift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-format.git", branch:("release/5.8")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "snark-swift"),
        .testTarget(
            name: "snark-swiftTests",
            dependencies: ["snark-swift"]),
    ]
)
