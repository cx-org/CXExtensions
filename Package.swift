// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CXExtensions",
    products: [
        .library(name: "CXExtensions", targets: ["CXExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CombineX", .upToNextMinor(from: "0.2.0")),
    ],
    targets: [
        .target(
            name: "CXExtensions",
            dependencies: ["CXShim"]),
        .testTarget(
            name: "CXExtensionsTests",
            dependencies: ["CXExtensions"]),
    ]
)
