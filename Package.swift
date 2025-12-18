// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Header",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "Header",
            targets: ["Header"]
        ),
    ],
    targets: [
        .target(
            name: "Header"
        ),
        .testTarget(
            name: "HeaderTests",
            dependencies: ["Header"]
        ),
    ]
)
