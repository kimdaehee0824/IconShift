// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EasyIcon",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "EasyIcon",
            path: "Sources/EasyIcon"
        )
    ]
)
