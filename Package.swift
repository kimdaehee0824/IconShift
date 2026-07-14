// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IconShift",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "IconShift",
            path: "Sources/IconShift"
        )
    ]
)
