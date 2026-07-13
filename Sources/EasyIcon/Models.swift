import Foundation

/// The current system-wide interface appearance.
enum SystemAppearance: String, Codable, Sendable {
    case light
    case dark

    var label: String { self == .dark ? "Dark" : "Light" }
}

/// How a given app's icon should track (or ignore) the system appearance.
enum IconMode: String, Codable, CaseIterable, Identifiable, Sendable {
    /// Follow the system: use the light icon in Light mode, dark icon in Dark mode.
    case auto
    /// Always use the light icon regardless of system appearance.
    case light
    /// Always use the dark icon regardless of system appearance.
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .auto:  return "Auto"
        case .light: return "Light"
        case .dark:  return "Dark"
        }
    }
}

/// A single app's icon-switching configuration.
struct AppIconRule: Codable, Identifiable, Hashable {
    /// Bundle identifier is the stable identity; falls back to the path when unavailable.
    var bundleIdentifier: String
    var appPath: String
    var displayName: String

    /// File names (not full paths) of the stored icon copies inside the app-support icons folder.
    var lightIconFileName: String?
    var darkIconFileName: String?

    var mode: IconMode = .auto
    var enabled: Bool = true

    var id: String { bundleIdentifier }

    var hasLightIcon: Bool { lightIconFileName != nil }
    var hasDarkIcon: Bool { darkIconFileName != nil }
}

/// Global application settings.
struct AppSettings: Codable, Hashable {
    var showMenuBarIcon: Bool = true
    var launchAtLogin: Bool = false
}

/// Root persisted document.
struct AppConfig: Codable {
    var rules: [AppIconRule] = []
    var settings: AppSettings = AppSettings()
}

/// A macOS application discovered on disk, used by the "add app" picker.
struct InstalledApp: Identifiable, Hashable {
    let name: String
    let path: String
    let bundleIdentifier: String

    var id: String { path }
}
