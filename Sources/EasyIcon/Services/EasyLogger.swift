import Foundation

/// Minimal append-only file logger. Writes to
/// ~/Library/Application Support/EasyIcon/easyicon.log
final class EasyLogger: @unchecked Sendable {
    static let shared = EasyLogger()

    let fileURL: URL
    private let queue = DispatchQueue(label: "com.easyicon.logger")

    private init() {
        let base = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("EasyIcon", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        fileURL = base.appendingPathComponent("easyicon.log")
    }

    func log(_ message: String) {
        let line = "[\(Self.timestamp())] \(message)\n"
        queue.async { [fileURL] in
            guard let data = line.data(using: .utf8) else { return }
            if let handle = try? FileHandle(forWritingTo: fileURL) {
                defer { try? handle.close() }
                _ = try? handle.seekToEnd()
                try? handle.write(contentsOf: data)
            } else {
                try? data.write(to: fileURL, options: .atomic)
            }
        }
        #if DEBUG
        print(line, terminator: "")
        #endif
    }

    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
}
