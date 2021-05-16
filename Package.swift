// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Par",
    products: [
        .library(
            name: "Par",
            targets: ["Par"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Par",
            dependencies: []),
        .testTarget(
            name: "ParTests",
            dependencies: ["Par"]),
    ]
)
