// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TealiumAdjust",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "TealiumAdjust", targets: ["TealiumAdjust"])
    ],
    dependencies: [
        .package(name: "TealiumSwift", url: "https://github.com/tealium/tealium-swift", .upToNextMajor(from: "2.18.1")),
        .package(name: "AdjustSdk", url: "https://github.com/adjust/ios_sdk", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        .target(
            name: "TealiumAdjust",
            dependencies: [
                .product(name: "AdjustSdk", package: "AdjustSdk"),
                .product(name: "TealiumCore", package: "TealiumSwift"),
                .product(name: "TealiumRemoteCommands", package: "TealiumSwift")
            ],
            path: "./Sources",
            exclude: ["Support"]),
        .testTarget(
            name: "TealiumAdjustTests",
            dependencies: ["TealiumAdjust"],
            path: "./Tests",
            exclude: ["Support"])
    ]
)
