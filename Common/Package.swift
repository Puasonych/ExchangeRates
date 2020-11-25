// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Common",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "Common", targets: ["Common"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Common",
            dependencies: [],
            resources: [
                .process("Resources")
            ]),
        .testTarget(name: "CommonTests", dependencies: ["Common"])
    ]
)
