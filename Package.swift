// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "CXExtensions",
    platforms: [
        .macOS(.v10_10),
        .iOS(.minimalToolChainSupported),
        .tvOS(.v9),
        .watchOS(.v2),
    ],
    products: [
        .library(name: "CXExtensions", targets: ["CXExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CombineX", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/Quick/Quick.git", from: "3.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0"),
    ],
    targets: [
        .target(
            name: "CXExtensions",
            dependencies: [
                .product(name: "CXShim", package: "CombineX")
            ]),
        .testTarget(
            name: "CXExtensionsTests",
            dependencies: [
                "CXExtensions",
                "Quick",
                "Nimble",
                .product(name: "CXTest", package: "CombineX"),
            ]),
    ]
)

extension SupportedPlatform.IOSVersion {
    #if compiler(>=5.3)
    static var minimalToolChainSupported = SupportedPlatform.IOSVersion.v9
    #else
    static var minimalToolChainSupported = SupportedPlatform.IOSVersion.v8
    #endif
}

enum CombineImplementation {
    
    case combine
    case combineX
    case openCombine
    
    static var `default`: CombineImplementation {
        #if canImport(Combine)
        return .combine
        #else
        return .combineX
        #endif
    }
    
    init?(_ description: String) {
        let desc = description.lowercased().filter { $0.isLetter }
        switch desc {
        case "combine":     self = .combine
        case "combinex":    self = .combineX
        case "opencombine": self = .openCombine
        default:            return nil
        }
    }
}

extension ProcessInfo {

    var combineImplementation: CombineImplementation {
        return environment["CX_COMBINE_IMPLEMENTATION"].flatMap(CombineImplementation.init) ?? .default
    }
    
    var isCI: Bool {
        return (environment["CX_CONTINUOUS_INTEGRATION"] as NSString?)?.boolValue ?? false
    }
}

import Foundation

let info = ProcessInfo.processInfo
if info.combineImplementation == .combine {
    package.platforms = [.macOS("10.15"), .iOS("13.0"), .tvOS("13.0"), .watchOS("6.0")]
}
