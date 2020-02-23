// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CXExtensions",
    products: [
        .library(name: "CXExtensions", targets: ["CXExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CombineX", .upToNextMinor(from: "0.2.0")),
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        // TODO: Use "8.0.2" until https://github.com/Quick/Nimble/issues/705 is fixed.
        .package(url: "https://github.com/Quick/Nimble.git", .exact("8.0.2")),
    ],
    targets: [
        .target(
            name: "CXExtensions",
            dependencies: ["CXShim"]),
        .testTarget(
            name: "CXExtensionsTests",
            dependencies: ["CXExtensions", "CXTest", "Quick", "Nimble"]),
    ]
)
