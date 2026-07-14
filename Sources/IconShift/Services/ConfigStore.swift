import AppKit

// Stored under Application Support to avoid the TCC prompts of Pictures/Desktop/Documents/Downloads.
final class ConfigStore {
    static let shared = ConfigStore()

    let baseURL: URL
    let iconsURL: URL
    let configURL: URL

    private let imageCache = NSCache<NSString, NSImage>()

    private init() {
        baseURL = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("IconShift", isDirectory: true)
        iconsURL = baseURL.appendingPathComponent("icons", isDirectory: true)
        configURL = baseURL.appendingPathComponent("config.json")
        try? FileManager.default.createDirectory(at: iconsURL, withIntermediateDirectories: true)
    }

    func load() -> AppConfig {
        guard let data = try? Data(contentsOf: configURL),
              let config = try? JSONDecoder().decode(AppConfig.self, from: data) else {
            return AppConfig()
        }
        return config
    }

    func save(_ config: AppConfig) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(config) else { return }
        try? data.write(to: configURL, options: .atomic)
    }

    func importIcon(from url: URL, bundleIdentifier: String, variant: String) -> String? {
        let ext = url.pathExtension.isEmpty ? "png" : url.pathExtension
        let safeID = bundleIdentifier.replacingOccurrences(of: "/", with: "_")
        let fileName = "\(safeID)-\(variant).\(ext)"
        let destination = iconsURL.appendingPathComponent(fileName)
        do {
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.copyItem(at: url, to: destination)
            // File names are deterministic, so a re-import must evict the stale image.
            imageCache.removeObject(forKey: fileName as NSString)
            return fileName
        } catch {
            AppLogger.shared.log("Failed to import icon from \(url.path): \(error.localizedDescription)")
            return nil
        }
    }

    func removeIcon(fileName: String) {
        try? FileManager.default.removeItem(at: iconsURL.appendingPathComponent(fileName))
        imageCache.removeObject(forKey: fileName as NSString)
    }

    func iconURL(_ fileName: String) -> URL {
        iconsURL.appendingPathComponent(fileName)
    }

    func iconImage(_ fileName: String) -> NSImage? {
        if let cached = imageCache.object(forKey: fileName as NSString) { return cached }
        guard let image = NSImage(contentsOf: iconURL(fileName)) else { return nil }
        imageCache.setObject(image, forKey: fileName as NSString)
        return image
    }

    func revealConfigInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([configURL])
    }
}
