// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Arc_Zen_like_ColorPicker",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .library(name: "ZenThemeColorPicker", targets: ["ZenThemeColorPicker"]),
        .executable(name: "Arc_Zen_like_ColorPicker", targets: ["Arc_Zen_like_ColorPicker"])
    ],
    targets: [
        .target(
            name: "ZenThemeColorPicker"
        ),
        .executableTarget(
            name: "Arc_Zen_like_ColorPicker",
            dependencies: ["ZenThemeColorPicker"]
        ),
    ]
)
