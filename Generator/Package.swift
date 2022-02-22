// swift-tools-version:5.1
import PackageDescription

// Define the SwiftSyntax release to use based on the version of Swift in use
#if swift(>=5.6)
// Xcode 13.3 / Swift 5.6
let swiftSyntaxRequirement: Package.Dependency.Requirement = .revision("0.50600.0-SNAPSHOT-2022-01-24")
let swiftSyntaxProducts: [Target.Dependency] = [
    .init(stringLiteral: "SwiftSyntax"),
    .init(stringLiteral: "SwiftSyntaxParser"),
]

#elseif swift(>=5.5) && swift(<5.6)
// Xcode 13.0 / Swift 5.5
let swiftSyntaxRequirement: Package.Dependency.Requirement = .exact("0.50500.0")
let swiftSyntaxProducts: [Target.Dependency] = [
    .init(stringLiteral: "SwiftSyntax"),
]

#else
// Xcode 12.5 / Swift 5.4
let swiftSyntaxRequirement: Package.Dependency.Requirement = .exact("0.50400.0")
let swiftSyntaxProducts: [Target.Dependency] = [
    .init(stringLiteral: "SwiftSyntax"),
]
#endif

let package = Package(
    name: "Needle",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "needle", targets: ["needle"]),
        .library(name: "NeedleFramework", targets: ["NeedleFramework"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", swiftSyntaxRequirement),
        .package(url: "https://github.com/apple/swift-tools-support-core", .upToNextMajor(from: "0.2.5")),
        .package(url: "https://github.com/uber/swift-concurrency.git", .upToNextMajor(from: "0.6.5")),
        .package(url: "https://github.com/uber/swift-common.git", .exact("0.5.0")),
    ],
    targets: [
        .target(
            name: "NeedleFramework",
            dependencies: [
                "SwiftToolsSupport-auto",
                "Concurrency",
                "SourceParsingFramework",
            ] + swiftSyntaxProducts
        ),
        .testTarget(
            name: "NeedleFrameworkTests",
            dependencies: ["NeedleFramework"],
            exclude: [
                "Fixtures",
            ]),
        .target(
            name: "needle",
            dependencies: [
                "NeedleFramework",
                "CommandFramework",
            ]),
    ],
    swiftLanguageVersions: [.v5]
)
