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

    private static let iconCache = NSCache<NSString, NSImage>()

    static func icon(forApp path: String) -> NSImage {
        if let cached = iconCache.object(forKey: path as NSString) { return cached }
        let icon = NSWorkspace.shared.icon(forFile: path)
        iconCache.setObject(icon, forKey: path as NSString)
        return icon
    }

    static func invalidateIcon(forApp path: String) {
        iconCache.removeObject(forKey: path as NSString)
    }

    private static let bundleIconCache = NSCache<NSString, NSImage>()

    // NSWorkspace.icon reflects the Finder override (our applied icon); the bundle resource is the true original.
    static func bundleIcon(forApp path: String) -> NSImage? {
        if let cached = bundleIconCache.object(forKey: path as NSString) { return cached }
        guard let bundle = Bundle(path: path) else { return nil }
        var image: NSImage?
        if let iconFile = bundle.object(forInfoDictionaryKey: "CFBundleIconFile") as? String {
            let base = iconFile.hasSuffix(".icns") ? String(iconFile.dropLast(5)) : iconFile
            if let url = bundle.url(forResource: base, withExtension: "icns") {
                image = NSImage(contentsOf: url)
            }
        }
        if image == nil, let iconName = bundle.object(forInfoDictionaryKey: "CFBundleIconName") as? String {
            image = bundle.image(forResource: iconName)
        }
        if let image { bundleIconCache.setObject(image, forKey: path as NSString) }
        return image
    }
}
