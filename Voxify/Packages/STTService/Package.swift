// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "STTService",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "STTService", targets: ["STTService"])
    ],
    dependencies: [
        .package(path: "../AudioEngine")
    ],
    targets: [
        .target(name: "STTService", dependencies: ["AudioEngine"])
    ]
)
