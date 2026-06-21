// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NeumorphicUIKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "NeumorphicUIKit", targets: ["NeumorphicUIKit"]),
    ],
    targets: [
        .target(name: "NeumorphicUIKit"),
    ]
)
