import ProjectDescription

let project = Project(
    name: "IconShift",
    options: .options(defaultKnownRegions: ["en", "ko", "ja"], developmentRegion: "en"),
    packages: [
        .remote(
            url: "https://github.com/sparkle-project/Sparkle",
            requirement: .exact("2.9.4")
        )
    ],
    targets: [
        .target(
            name: "IconShift",
            destinations: .macOS,
            product: .app,
            bundleId: "com.iconshift.IconShift",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .file(path: "Resources/Info.plist"),
            sources: ["Sources/IconShift/**"],
            resources: ["Resources/Localizable.xcstrings", "Resources/IconShift.icon"],
            dependencies: [
                .package(product: "Sparkle")
            ],
            settings: .settings(base: [
                // actool compiles only the icon matching this name, and still succeeds when it finds none.
                "ASSETCATALOG_COMPILER_APPICON_NAME": "IconShift",
                "CODE_SIGN_STYLE": "Manual",
                "CODE_SIGN_IDENTITY": "-",
                "MARKETING_VERSION": "0.1.0",
                "CURRENT_PROJECT_VERSION": "0.1.0",
                "SWIFT_EMIT_LOC_STRINGS": "YES",
                "SWIFT_VERSION": "6.0",
                "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
                "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor"
            ])
        )
    ]
)
