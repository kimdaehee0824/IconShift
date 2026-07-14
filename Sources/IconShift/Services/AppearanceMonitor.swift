import AppKit

// Detection order, most to least reliable: effectiveAppearance KVO → AppleInterfaceThemeChangedNotification → poll.
final class AppearanceMonitor {

    private(set) var current: SystemAppearance
    var onChange: ((SystemAppearance) -> Void)?

    private var observation: NSKeyValueObservation?
    private var themeTask: Task<Void, Never>?
    private var pollTask: Task<Void, Never>?

    init() {
        current = AppearanceMonitor.read()
    }

    static func read() -> SystemAppearance {
        if let app = NSApp,
           let name = app.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) {
            return name == .darkAqua ? .dark : .light
        }
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark" ? .dark : .light
    }

    func start() {
        if let app = NSApp {
            observation = app.observe(\.effectiveAppearance, options: [.new]) { [weak self] _, _ in
                MainActor.assumeIsolated { self?.evaluate() }
            }
        }

        themeTask = Task { [weak self] in
            let name = Notification.Name("AppleInterfaceThemeChangedNotification")
            for await _ in DistributedNotificationCenter.default().notifications(named: name) {
                guard (try? await Task.sleep(for: .seconds(0.3))) != nil else { break }
                self?.evaluate()
            }
        }

        pollTask = Task { [weak self] in
            while (try? await Task.sleep(for: .seconds(10))) != nil {
                self?.evaluate()
            }
        }
    }

    func stop() {
        observation?.invalidate()
        observation = nil
        themeTask?.cancel()
        themeTask = nil
        pollTask?.cancel()
        pollTask = nil
    }

    private func evaluate() {
        let resolved = AppearanceMonitor.read()
        guard resolved != current else { return }
        current = resolved
        onChange?(resolved)
    }
}
