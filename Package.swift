// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "IconShift",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "IconShift",
            path: "Sources/IconShift",
            swiftSettings: [
                .defaultIsolation(MainActor.self),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances")
            ]
        )
    ]
)
