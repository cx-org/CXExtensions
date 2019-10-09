// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CXExtensions",
    products: [
        .library(name: "CXExtensions", targets: ["CXExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CXCompatible", .branch("master")),
    ],
    targets: [
        .target(
            name: "CXExtensions",
            dependencies: [
                .product(name: "CXShim", package: "CXCompatible"),
            ]),
        .testTarget(
            name: "CXExtensionsTests",
            dependencies: ["CXExtensions"]),
    ]
)
