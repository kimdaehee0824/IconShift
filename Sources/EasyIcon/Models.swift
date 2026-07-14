import Foundation

enum SystemAppearance: String, Codable, Sendable {
    case light
    case dark

    var label: String {
        self == .dark ? NSLocalizedString("Dark", comment: "") : NSLocalizedString("Light", comment: "")
    }
}

enum IconMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case auto
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .auto:  return NSLocalizedString("Auto", comment: "")
        case .light: return NSLocalizedString("Light", comment: "")
        case .dark:  return NSLocalizedString("Dark", comment: "")
        }
    }
}

struct AppIconRule: Codable, Identifiable, Hashable {
    var bundleIdentifier: String
    var appPath: String
    var displayName: String

    var lightIconFileName: String?
    var darkIconFileName: String?

    var mode: IconMode = .auto
    var enabled: Bool = true

    var id: String { bundleIdentifier }

    var hasLightIcon: Bool { lightIconFileName != nil }
    var hasDarkIcon: Bool { darkIconFileName != nil }
}

struct AppSettings: Codable, Hashable {
    var showMenuBarIcon: Bool = true
    var launchAtLogin: Bool = false
}

struct AppConfig: Codable {
    var rules: [AppIconRule] = []
    var settings: AppSettings = AppSettings()
}

struct InstalledApp: Identifiable, Hashable {
    let name: String
    let path: String
    let bundleIdentifier: String

    var id: String { path }
}
