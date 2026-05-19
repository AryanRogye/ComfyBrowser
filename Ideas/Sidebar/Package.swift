// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sidebar",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .executable(name: "Sidebar", targets: ["Sidebar"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Sidebar"
        ),
    ]
)
