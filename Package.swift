// swift-tools-version:5.0

import PackageDescription

#if USE_COMBINE
let cxDep = Package.Dependency.package(url: "https://github.com/cx-org/CXCompatible", .branch("master"))
let cxDepName: Target.Dependency = "CXCompatible"
#else
let cxDep = Package.Dependency.package(url: "https://github.com/cx-org/CXFoundation", .branch("master"))
let cxDepName: Target.Dependency = "CXFoundation"
#endif

let package = Package(
    name: "CXExtensions",
    products: [
        .library(name: "CXExtensions", targets: ["CXExtensions"]),
    ],
    dependencies: [
        cxDep
    ],
    targets: [
        .target(name: "CXExtensions", dependencies: [cxDepName]),
        .testTarget(name: "CXExtensionsTests", dependencies: ["CXExtensions"]),
    ]
)
