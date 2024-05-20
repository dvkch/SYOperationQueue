// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SYOperationQueue",
    platforms: [
        .iOS(.v10),
        .tvOS(.v10)
    ],
    products: [
        .library(name: "SYOperationQueue", targets: ["SYOperationQueue"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "SYOperationQueue", dependencies: []),
        .testTarget(name: "SYOperationQueueTests", dependencies: ["SYOperationQueue"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
