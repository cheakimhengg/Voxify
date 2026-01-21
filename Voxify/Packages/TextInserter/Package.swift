// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TextInserter",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "TextInserter", targets: ["TextInserter"])
    ],
    targets: [
        .target(name: "TextInserter")
    ]
)
