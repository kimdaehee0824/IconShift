# IconShift

A tiny macOS menu-bar app that **automatically swaps app icons when you switch between Light and Dark mode.**

macOS has no built-in way to give an app two Finder/Dock icons — one for Light appearance and one for Dark. IconShift adds exactly that: assign a light icon and a dark icon to any app, and it re-applies the right one whenever the system appearance changes.

> Works great for Safari/Chrome web apps (PWAs) whose stock icons don't fit a dark menu bar or Dock.

## Features

- 🌗 **Automatic light/dark icon switching** — the core feature.
- 📌 **Per-app mode** — follow the system automatically, or pin an app to always-light / always-dark.
- 🔍 **Search** your configured apps, and search installed apps when adding new ones.
- 🖼️ **Drag & drop** a `.png`/`.icns` onto a slot, or pick a file.
- 🧭 **Menu-bar first, or invisible** — run with a menu-bar icon, or hide it entirely and keep IconShift alive purely in the background.
- 🚀 **Launch at login** (via `SMAppService`).
- ♻️ **Self-healing** — re-applies icons on launch, recovering from PWA/browser updates that reset them.
- 🛟 **Safe** — a failed write never corrupts an app's existing icon (see [How it works](#how-it-works)).

## Requirements

- macOS 14 or later
- Xcode / Swift toolchain
- [Tuist](https://tuist.dev) for the Xcode project — `mise install` (a `.mise.toml` is provided) or `brew install tuist`. Optional if you only use the CLI build.

## Develop in Xcode (Tuist)

The Xcode project is generated with [Tuist](https://tuist.dev); only `Project.swift` is
committed — never the `.xcodeproj` (it's git-ignored).

```bash
tuist generate        # generates IconShift.xcworkspace and opens it in Xcode
```

Pick the **IconShift** scheme and press **Cmd+R**. This runs the real signed `.app`
(menu bar, permissions, and login item all behave correctly — unlike running a bare
SwiftPM executable).

> **Signing:** ad-hoc by default, so it builds with zero setup. Because an ad-hoc
> signature changes every build, the macOS App Management grant resets each run.
> For a grant that *persists* across rebuilds, run `scripts/make-signing-cert.sh`
> once, then set the identity to **IconShift Self-Signed** in
> Xcode › Signing & Capabilities.

## Build a distributable .app (CLI)

```bash
scripts/make-signing-cert.sh   # optional: stable signing identity (see above)
scripts/build.sh               # assembles dist/IconShift.app
open dist/IconShift.app
```

`swift build` also works for a plain compile.

## Grant "App Management" permission

Changing another app's icon requires macOS's **App Management** permission (this is a hard OS requirement, not an IconShift setting). On first use:

1. Add an app and assign it an icon.
2. macOS shows a prompt — click **Allow**. If you miss it, open
   **System Settings › Privacy & Security › App Management** and enable **IconShift**.
3. Hit **Apply Now** (or just toggle appearance).

IconShift shows a banner and an "Open Settings" button whenever a write is blocked.

## Usage

1. Click **+** and pick an app.
2. Drop a **Light** icon and a **Dark** icon onto the two slots.
3. Leave **Follow system appearance** on for automatic switching, or turn it off to pin one icon.

> **Dock note:** the Finder icon updates immediately. An app that is *already running* keeps its old Dock tile until you quit and relaunch it — this is how the macOS Dock works, not an IconShift bug.

Icons and config live in `~/Library/Application Support/IconShift/` (config.json, icons/, iconshift.log).

## How it works

- **Appearance detection** — KVO on `NSApp.effectiveAppearance` (primary), the
  `AppleInterfaceThemeChangedNotification` distributed notification (backup), and a
  10-second poll (safety net). Icons are only re-applied when the mode actually changes.
- **Applying icons** — `NSWorkspace.setIcon(_:forFile:)`. On apps registered in
  protected locations (`/Applications`, `~/Applications`) macOS gates this behind
  **App Management**, which is why IconShift must be code-signed and granted permission.
- **Crash/partial-write safety** — a failed `setIcon` can leave the FinderInfo
  custom-icon bit set without icon data, which shows a blank/generic icon. IconShift
  detects and rolls this back so a failure never damages the original icon.

## Project layout

```
Sources/IconShift/
  main.swift, AppDelegate.swift          # AppKit shell (agent lifecycle)
  StatusItemController.swift             # menu-bar item + menu
  MainWindowController.swift             # hosts the SwiftUI window
  AppModel.swift                         # state + orchestration
  Models.swift                           # data types
  Services/                              # appearance, icon writing, config, scan, login, log
  Views/                                 # SwiftUI: sidebar, detail, icon well, add sheet
Project.swift                            # Tuist manifest (generates the Xcode project)
Package.swift                            # SwiftPM manifest (CLI builds)
scripts/                                 # build + signing helpers
Resources/Info.plist
```

## Contributing

Issues and PRs welcome. Keep it small and dependency-free.

## License

[MIT](LICENSE) © 2026 IconShift Contributors
