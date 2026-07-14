import ProjectDescription

let project = Project(
    name: "IconShift",
    options: .options(defaultKnownRegions: ["en", "ko", "ja"], developmentRegion: "en"),
    targets: [
        .target(
            name: "IconShift",
            destinations: .macOS,
            product: .app,
            bundleId: "com.iconshift.IconShift",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .file(path: "Resources/Info.plist"),
            sources: ["Sources/IconShift/**"],
            resources: ["Resources/Localizable.xcstrings"],
            dependencies: [],
            settings: .settings(base: [
                "CODE_SIGN_STYLE": "Manual",
                "CODE_SIGN_IDENTITY": "-",
                "MARKETING_VERSION": "0.1.0",
                "CURRENT_PROJECT_VERSION": "1",
                "SWIFT_EMIT_LOC_STRINGS": "YES"
            ])
        )
    ]
)
