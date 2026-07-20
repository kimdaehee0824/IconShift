# Contributing to IconShift

Thank you for helping improve IconShift. The project is intentionally small, dependency-free, and focused on reliable icon switching for macOS.

## Requirements

- macOS 14 or later
- Xcode with the Swift 6.2 toolchain
- Tuist 4, installed through the included `.mise.toml` or with `brew install tuist`

## Develop in Xcode

The Xcode project is generated from `Project.swift`; generated project and workspace files are not committed.

```bash
tuist generate
```

Open `IconShift.xcworkspace`, choose the IconShift scheme, and press Command-R. Regenerate the workspace only when files are added or removed.

For a command-line compile, run:

```bash
swift build
```

## Build the app bundle

`scripts/build.sh` builds arm64 and x86_64 executables, combines them into a Universal Binary, compiles the localization catalog and the Icon Composer app icon, assembles `dist/IconShift.app`, and signs it. `scripts/make-dmg.sh` then packages the built app into a distributable disk image with an Applications shortcut and a volume icon.

```bash
scripts/build.sh
scripts/build.sh debug
scripts/make-dmg.sh
```

The script uses `ICONSHIFT_SIGN_ID` when set, then looks for an `IconShift Self-Signed` identity, and otherwise falls back to ad-hoc signing.

For a stable local identity, run:

```bash
scripts/make-signing-cert.sh
```

Use the resulting `IconShift Self-Signed` identity in Xcode or the build script. App Management associates its grant with the app's code identity, so a stable signature keeps the permission across rebuilds. An ad-hoc signature changes with the binary and can require permission again.

## How it works

IconShift observes `NSApp.effectiveAppearance` through KVO as its primary signal. It also listens for `AppleInterfaceThemeChangedNotification` and polls every ten seconds as fallbacks. Icons are reapplied only when the effective Light or Dark mode changes, and once at launch to recover icons reset by browser updates.

Icon changes use `NSWorkspace.setIcon`. For apps registered in protected locations such as `/Applications` and `~/Applications`, macOS requires IconShift to be code-signed and allowed under System Settings > Privacy & Security > App Management.

A failed `setIcon` call can leave the FinderInfo custom-icon bit enabled without writing icon data. That state appears as a blank or generic icon, so `IconApplier` verifies the result and removes the partial FinderInfo attribute when the write fails. Keep this rollback transactional when changing the icon application path.

Finder reflects a successful change immediately. A running app keeps its existing Dock tile until it quits and relaunches; IconShift does not restart Dock.

## Project layout

```text
Sources/IconShift/
  main.swift, AppDelegate.swift       AppKit lifecycle and dependency wiring
  StatusItemController.swift          Menu bar item and menu
  MainWindowController.swift          SwiftUI main window hosting
  SettingsWindowController.swift      General and About settings window
  MainMenu.swift                      Standard macOS application menus
  AppModel.swift, Models.swift        State, orchestration, and data types
  Services/                           Appearance, icons, storage, scanning, permissions, login, logging
  Views/                              Main view, sidebar, detail, icon wells, app picker, settings
Resources/
  Info.plist
  Localizable.xcstrings
  IconShift.icon                      Icon Composer app icon
.github/workflows/
  ci.yml                              Compile, app-bundle, and disk-image validation
  release.yml                         Version-tagged GitHub Releases (DMG)
scripts/                              App assembly, disk-image, and signing helpers
Project.swift                         Tuist manifest
Package.swift                         Swift Package Manager manifest
```

## Localization

All user-facing strings belong in `Resources/Localizable.xcstrings`. English is the source language; Korean and Japanese are complete translations. SwiftUI string literals are extracted automatically. When a localized value is passed through a parameter, use `LocalizedStringKey`. AppKit menus and labels use `NSLocalizedString`.

Add English, Korean, and Japanese text together. Keep the terms Light and Dark consistent with the existing translations: `라이트`/`다크` in Korean and `ライト`/`ダーク` in Japanese. If a new language is added, also update `defaultKnownRegions` in `Project.swift` and the three user README files as appropriate.

`macOSicons` is a proper name and keeps this exact spelling in every localization.

The command-line app build compiles the catalog with `xcstringstool`. English uses the source strings and `CFBundleDevelopmentRegion`; translated `ko.lproj` and `ja.lproj` resources are included in the app bundle.

## Before submitting a change

Run `swift build` and `scripts/build.sh`. For icon application changes, also verify the result in Finder and inspect `~/Library/Application Support/IconShift/iconshift.log`. Keep `README.md`, `README_ko.md`, and `README_jp.md` synchronized when user documentation changes.

Please avoid adding third-party dependencies unless there is a compelling reason that cannot be handled clearly with system frameworks.
