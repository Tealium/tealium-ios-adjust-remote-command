// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "TealiumAdjust",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "TealiumAdjust", targets: ["TealiumAdjust"])
    ],
    dependencies: [
        .package(url: "https://github.com/tealium/tealium-swift", from: "2.2.0"),
        .package(url: "https://github.com/adjust/ios_sdk", from: "4.6.0")
    ],
    targets: [
        .target(
            name: "TealiumAdjust",
            dependencies: ["Adjust", "TealiumCore", "TealiumRemoteCommands"],
            path: "./Sources"),
        .testTarget(
            name: "TealiumAdjustTests",
            dependencies: ["TealiumAdjust"],
            path: "./Tests")
    ]
)