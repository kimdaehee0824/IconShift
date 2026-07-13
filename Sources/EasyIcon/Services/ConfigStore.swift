import AppKit

/// Persists configuration and stores copies of user-selected icon files under
/// ~/Library/Application Support/EasyIcon. This location avoids the TCC prompts
/// triggered by Pictures/Desktop/Documents/Downloads, and keeps the config
/// self-contained (icons survive the user moving or deleting the originals).
final class ConfigStore {
    static let shared = ConfigStore()

    let baseURL: URL
    let iconsURL: URL
    let configURL: URL

    private init() {
        baseURL = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("EasyIcon", isDirectory: true)
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

    /// Copies a user-chosen icon file into the store, returning the stored file name.
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
            return fileName
        } catch {
            EasyLogger.shared.log("Failed to import icon from \(url.path): \(error.localizedDescription)")
            return nil
        }
    }

    func removeIcon(fileName: String) {
        try? FileManager.default.removeItem(at: iconsURL.appendingPathComponent(fileName))
    }

    func iconURL(_ fileName: String) -> URL {
        iconsURL.appendingPathComponent(fileName)
    }

    func revealConfigInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([configURL])
    }
}
