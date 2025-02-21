// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UselessEngine",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UselessEngine",
            targets: ["UselessEngine"]),
    ],
    dependencies: [
        .package(path: "../UselessCommon")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UselessEngine",
            dependencies: [
                .product(name: "UselessCommon", package: "UselessCommon")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "UselessEngineTests",
            dependencies: ["UselessEngine"],
            path: "Tests"
        ),
    ],
    swiftLanguageModes: [
        .v5
    ]
)
