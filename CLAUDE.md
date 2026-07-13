# EasyIcon — Project Guide

EasyIcon is an open-source (MIT) macOS **menu-bar app that automatically swaps an app's
Finder/Dock icon when the system switches between Light and Dark mode.** Each configured app
gets a light icon and a dark icon; EasyIcon applies the right one on appearance change, on
launch, and on demand. Per-app mode can also pin an app to always-light or always-dark.
Primary use case: Safari/Chrome web apps (PWAs) that don't ship appearance-aware icons.

## Build & run

- **Xcode (dev loop):** `tuist generate` → open `EasyIcon.xcworkspace` → EasyIcon scheme → **Cmd+R**.
  Only `Project.swift` is committed; the `.xcodeproj`/`.xcworkspace` are generated and git-ignored.
  Regenerate only when files are added/removed.
- **CLI compile:** `swift build`
- **Distributable app:** `scripts/build.sh` → `dist/EasyIcon.app`
- **Stable signing** (so the App Management grant survives rebuilds): `scripts/make-signing-cert.sh`,
  then sign with the `EasyIcon Self-Signed` identity (Xcode › Signing & Capabilities, or auto-picked
  by `scripts/build.sh`). Ad-hoc signatures change every build and reset the grant.
- Requires macOS 14+, Tuist 4 (`.mise.toml` pins it, or `brew install tuist`). No third-party Swift deps.

## Architecture

Hybrid **AppKit shell + SwiftUI content** — chosen over a pure SwiftUI `MenuBarExtra` app for
robust control over hiding the menu-bar icon and running headless in the background.

- `main.swift`, `AppDelegate.swift` — agent lifecycle (`.accessory`, no Dock icon); wires it together.
- `StatusItemController.swift` — menu-bar `NSStatusItem` + menu; can be shown/hidden at runtime.
- `MainWindowController.swift` — hosts the SwiftUI window inside an `NSWindow`.
- `AppModel.swift` — `@MainActor ObservableObject`, the single source of truth; orchestrates apply.
- `Models.swift` — `AppIconRule`, `IconMode` (auto/light/dark), `AppSettings`, `AppConfig`, `InstalledApp`.
- `Services/` — `AppearanceMonitor`, `IconApplier` (core), `ConfigStore`, `InstalledAppsScanner`,
  `PermissionManager`, `LoginItemManager`, `EasyLogger`.
- `Views/` — SwiftUI: `MainView` (NavigationSplitView), `SidebarView` (searchable), `AppDetailView`,
  `IconWell` (drag & drop), `AddAppSheet` (searchable installed-app picker).

Config, icon copies, and the log live in `~/Library/Application Support/EasyIcon/`.

## Critical macOS constraints (validated empirically on macOS 26)

Non-obvious and central — do not regress:

1. **App Management permission is mandatory.** `NSWorkspace.setIcon` on an app registered in a
   protected location (`/Applications`, `~/Applications`) is blocked unless EasyIcon is code-signed
   **and** the user granted it App Management (System Settings › Privacy & Security › App Management).
   The same app copied elsewhere, or a plain folder, is not gated — the block is location/registration
   based, not a process or signing bug.
2. **Transactional safety is required.** A *failed* `setIcon` can set the FinderInfo custom-icon bit
   (offset 8, mask `0x04`) without writing icon data, leaving a blank/generic icon. `IconApplier`
   verifies the result and rolls this back via `removexattr(com.apple.FinderInfo)`. Never drop this guard.
3. **Dock reflection:** Finder updates immediately; a *running* app keeps its old Dock tile until it is
   quit and relaunched. This is how the Dock works — do not `killall Dock`.
4. **Appearance detection:** primary = KVO on `NSApp.effectiveAppearance`; backups =
   `AppleInterfaceThemeChangedNotification` (distributed notification) + a 10s poll. Re-apply only when
   the mode actually changes. `UserDefaults` `AppleInterfaceStyle` alone is unreliable (cache lag).
5. **Targets are often Safari Web Apps** (`com.apple.Safari.WebApp.*`, ad-hoc signed); their icons can
   reset when Safari/the browser updates them, so EasyIcon re-applies on launch to self-heal.
6. **Storage location:** keep config/icons under Application Support — Pictures/Desktop/Documents/
   Downloads trigger TCC prompts.

## Conventions

- English identifiers, comments, README, and code artifacts (community project).
- No external dependencies; keep it small, readable, dependency-free.
- Verify icon changes by observing Finder and the log at
  `~/Library/Application Support/EasyIcon/easyicon.log` — not just by compiling.
