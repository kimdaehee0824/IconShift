import AppKit

// Detection order, most to least reliable: effectiveAppearance KVO → AppleInterfaceThemeChangedNotification → poll.
final class AppearanceMonitor {

    private(set) var current: SystemAppearance
    var onChange: ((SystemAppearance) -> Void)?

    private var observation: NSKeyValueObservation?
    private var timer: Timer?

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
                self?.evaluate()
            }
        }

        DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { self?.evaluate() }
        }

        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.evaluate()
        }
    }

    func stop() {
        observation?.invalidate()
        observation = nil
        timer?.invalidate()
        timer = nil
    }

    private func evaluate() {
        let resolved = AppearanceMonitor.read()
        guard resolved != current else { return }
        current = resolved
        onChange?(resolved)
    }
}
