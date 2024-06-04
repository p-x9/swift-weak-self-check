// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-weak-self-check",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "weak-self-check",
            targets: ["WeakSelfCheck"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.2.0"
        ),
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            "509.0.0"..<"511.0.0"
        ),
    ],
    targets: [
        .executableTarget(
            name: "WeakSelfCheck",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "WeakSelfCheckCore"
            ]
        ),
        .target(
            name: "WeakSelfCheckCore",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ]
        )
    ]
)
