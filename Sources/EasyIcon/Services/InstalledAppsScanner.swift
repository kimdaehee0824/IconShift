import AppKit

enum InstalledAppsScanner {
    static let searchPaths: [String] = [
        "/Applications",
        "/Applications/Utilities",
        "\(NSHomeDirectory())/Applications",
        "/System/Applications",
        "/System/Applications/Utilities"
    ]

    static func scan() -> [InstalledApp] {
        let fm = FileManager.default
        var seen = Set<String>()
        var apps: [InstalledApp] = []

        for directory in searchPaths {
            guard let items = try? fm.contentsOfDirectory(atPath: directory) else { continue }
            for item in items where item.hasSuffix(".app") {
                let path = "\(directory)/\(item)"
                guard seen.insert(path).inserted else { continue }
                let name = (item as NSString).deletingPathExtension
                let bundleID = Bundle(path: path)?.bundleIdentifier ?? path
                apps.append(InstalledApp(name: name, path: path, bundleIdentifier: bundleID))
            }
        }

        return apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    static func icon(forApp path: String) -> NSImage {
        NSWorkspace.shared.icon(forFile: path)
    }
}
