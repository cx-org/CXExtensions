// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CXExtensions",
    products: [
        .library(name: "CXExtensions", targets: ["CXExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CXShim", .branch("master")),
        .package(url: "https://github.com/cx-org/CXTest", .branch("master")),
    ],
    targets: [
        .target(name: "CXExtensions", dependencies: ["CXShim"]),
        .testTarget(name: "CXExtensionsTests", dependencies: ["CXExtensions", "CXTest"]),
    ]
)

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
}

import Foundation

let combineImpl = ProcessInfo.processInfo.combineImplementation

if combineImpl == .combine {
    package.platforms = [.macOS("10.15"), .iOS("13.0"), .tvOS("13.0"), .watchOS("6.0")]
}
