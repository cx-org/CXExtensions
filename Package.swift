// swift-tools-version:5.0

import Foundation
import PackageDescription

let package = Package(
    name: "CXExtensions",
    products: [
        .library(name: "CXExtensions", targets: ["CXExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CXCompatible", .branch("master")),
        .package(url: "https://github.com/cx-org/CXFoundation", .branch("master"))
    ],
    targets: [
        .target(name: "CXExtensions", dependencies: ["CXCompatible", "CXFoundation"]),
        .testTarget(name: "CXExtensionsTests", dependencies: ["CXExtensions"]),
    ]
)
