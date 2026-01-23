// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ContextDetector",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "ContextDetector", targets: ["ContextDetector"])
    ],
    targets: [
        .target(name: "ContextDetector")
    ]
)
