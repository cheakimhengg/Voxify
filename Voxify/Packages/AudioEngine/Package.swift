// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AudioEngine",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "AudioEngine", targets: ["AudioEngine"])
    ],
    targets: [
        .target(name: "AudioEngine")
    ]
)
