// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-weak-self-check",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "weak-self-check",
            targets: ["weak-self-check"]
        ),
        .plugin(
            name: "WeakSelfCheckBuildToolPlugin",
            targets: ["WeakSelfCheckBuildToolPlugin"]
        ),
        .plugin(
            name: "WeakSelfCheckCommandPlugin",
            targets: ["WeakSelfCheckCommandPlugin"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.2.0"
        ),
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            "509.0.0"..<"602.0.0"
        ),
        .package(
            url: "https://github.com/kateinoigakukun/swift-indexstore.git",
            from: "0.3.0"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "5.0.1"
        ),
        .package(
            url: "https://github.com/p-x9/swift-source-reporter.git",
            from: "0.2.0"
        ),
    ],
    targets: [
        .executableTarget(
            name: "weak-self-check",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "SwiftIndexStore", package: "swift-indexstore"),
                "WeakSelfCheckCore"
            ]
        ),
        .target(
            name: "WeakSelfCheckCore",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftIndexStore", package: "swift-indexstore"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SourceReporter", package: "swift-source-reporter"),
            ]
        ),
        .plugin(
            name: "WeakSelfCheckBuildToolPlugin",
            capability: .buildTool(),
            dependencies: [
                "weak-self-check"
            ]
        ),
        .plugin(
            name: "WeakSelfCheckCommandPlugin",
            capability: .command(
                intent: .custom(
                    verb: "weak-self-check",
                    description: "Check whether `self` is captured by weak reference in Closure."
                ),
                permissions: []
            ),
            dependencies: [
                "weak-self-check"
            ]
        ),
        .testTarget(
            name: "WeakSelfCheckCoreTests",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                "WeakSelfCheckCore"
            ]
        )
    ]
)
