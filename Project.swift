import ProjectDescription

// Tuist manifest for the Xcode app project.
// Generate with `tuist generate` — the .xcodeproj/.xcworkspace are not committed
// (see .gitignore). The Swift Package (Package.swift) is kept for plain `swift build`
// and scripts/build.sh; both drive the same sources under Sources/EasyIcon.
let project = Project(
    name: "EasyIcon",
    targets: [
        .target(
            name: "EasyIcon",
            destinations: .macOS,
            product: .app,
            bundleId: "com.easyicon.EasyIcon",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .file(path: "Resources/Info.plist"),
            sources: ["Sources/EasyIcon/**"],
            dependencies: [],
            settings: .settings(base: [
                // Ad-hoc by default so `tuist generate && build` works with no setup.
                // For a persistent App Management grant across rebuilds, run
                // scripts/make-signing-cert.sh and set the identity to
                // "EasyIcon Self-Signed" in Xcode › Signing & Capabilities.
                "CODE_SIGN_STYLE": "Manual",
                "CODE_SIGN_IDENTITY": "-",
                "MARKETING_VERSION": "0.1.0",
                "CURRENT_PROJECT_VERSION": "1"
            ])
        )
    ]
)
