// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PolishingService",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "PolishingService", targets: ["PolishingService"])
    ],
    targets: [
        .target(name: "PolishingService")
    ]
)
