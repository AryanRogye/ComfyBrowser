// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ThemeColorPicker",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .library(name: "ThemeColorPicker", targets: ["ThemeColorPicker"]),
        .executable(name: "ColorPickerDemo", targets: ["ColorPickerDemo"])
    ],
    targets: [
        .target(
            name: "ThemeColorPicker"
        ),
        .executableTarget(
            name: "ColorPickerDemo",
            dependencies: ["ThemeColorPicker"]
        ),
    ]
)
