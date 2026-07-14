import AppKit
import Combine

@MainActor
final class AppModel: ObservableObject {
    @Published var rules: [AppIconRule] = []
    @Published var settings: AppSettings = AppSettings()
    @Published private(set) var appearance: SystemAppearance = .light

    @Published private(set) var permissionGranted: Bool?

    private let store = ConfigStore.shared
    private let monitor = AppearanceMonitor()
    private let logger = EasyLogger.shared

    var onSettingsChanged: ((AppSettings) -> Void)?

    var logFileURL: URL { logger.fileURL }

    init() {
        let config = store.load()
        rules = config.rules
        settings = config.settings
        appearance = monitor.current
    }

    func startMonitoring() {
        monitor.onChange = { [weak self] appearance in
            guard let self else { return }
            self.appearance = appearance
            self.logger.log("System appearance changed to \(appearance.rawValue)")
            self.applyAll(reason: "appearance-change")
        }
        monitor.start()
    }

    func refreshLoginItemStatus() {
        settings.launchAtLogin = LoginItemManager.isEnabled
    }

    func activeIconFileName(for rule: AppIconRule) -> String? {
        switch rule.mode {
        case .auto:  return appearance == .dark ? rule.darkIconFileName : rule.lightIconFileName
        case .light: return rule.lightIconFileName
        case .dark:  return rule.darkIconFileName
        }
    }

    func applyAll(reason: String) {
        logger.log("Applying all icons (\(reason)); appearance=\(appearance.rawValue)")
        for rule in rules where rule.enabled {
            applyRuleInternal(rule)
        }
    }

    func applyRule(id: AppIconRule.ID) {
        guard let rule = rules.first(where: { $0.id == id }) else { return }
        applyRuleInternal(rule)
    }

    private func applyRuleInternal(_ rule: AppIconRule) {
        guard rule.enabled else { return }
        guard let fileName = activeIconFileName(for: rule) else {
            logger.log("No \(rule.mode.rawValue) icon set for \(rule.displayName); skipping")
            return
        }
        let result = IconApplier.apply(iconPath: store.iconURL(fileName).path, toApp: rule.appPath)
        logger.log(result.message)
        permissionGranted = result.success
    }

    func addRule(for app: InstalledApp) {
        guard !rules.contains(where: { $0.id == app.bundleIdentifier }) else { return }
        rules.append(AppIconRule(bundleIdentifier: app.bundleIdentifier,
                                 appPath: app.path,
                                 displayName: app.name))
        persist()
        logger.log("Added app: \(app.name) [\(app.bundleIdentifier)]")
    }

    func removeRule(id: AppIconRule.ID) {
        guard let index = rules.firstIndex(where: { $0.id == id }) else { return }
        let rule = rules[index]
        _ = IconApplier.clearIcon(app: rule.appPath)
        rule.lightIconFileName.map(store.removeIcon(fileName:))
        rule.darkIconFileName.map(store.removeIcon(fileName:))
        rules.remove(at: index)
        persist()
        logger.log("Removed app: \(rule.displayName)")
    }

    func setMode(id: AppIconRule.ID, _ mode: IconMode) {
        update(id: id) { $0.mode = mode }
        applyRule(id: id)
    }

    func setEnabled(id: AppIconRule.ID, _ enabled: Bool) {
        update(id: id) { $0.enabled = enabled }
        if enabled {
            applyRule(id: id)
        } else if let rule = rules.first(where: { $0.id == id }) {
            _ = IconApplier.clearIcon(app: rule.appPath)
        }
    }

    func setIcon(id: AppIconRule.ID, variant: SystemAppearance, from url: URL) {
        guard let rule = rules.first(where: { $0.id == id }) else { return }
        let variantName = variant == .dark ? "dark" : "light"
        guard let fileName = store.importIcon(from: url,
                                              bundleIdentifier: rule.bundleIdentifier,
                                              variant: variantName) else { return }
        update(id: id) {
            if variant == .dark { $0.darkIconFileName = fileName } else { $0.lightIconFileName = fileName }
        }
        logger.log("Set \(variantName) icon for \(rule.displayName)")
        applyRule(id: id)
    }

    func clearIcon(id: AppIconRule.ID, variant: SystemAppearance) {
        update(id: id) { rule in
            if variant == .dark {
                rule.darkIconFileName.map(store.removeIcon(fileName:))
                rule.darkIconFileName = nil
            } else {
                rule.lightIconFileName.map(store.removeIcon(fileName:))
                rule.lightIconFileName = nil
            }
        }
    }

    private func update(id: AppIconRule.ID, _ mutate: (inout AppIconRule) -> Void) {
        guard let index = rules.firstIndex(where: { $0.id == id }) else { return }
        mutate(&rules[index])
        persist()
    }

    func setShowMenuBarIcon(_ show: Bool) {
        settings.showMenuBarIcon = show
        persist()
        onSettingsChanged?(settings)
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            try LoginItemManager.setEnabled(enabled)
            settings.launchAtLogin = enabled
            persist()
            logger.log("Launch at login = \(enabled)")
        } catch {
            logger.log("Launch-at-login change failed: \(error.localizedDescription)")
        }
        onSettingsChanged?(settings)
    }

    func revealConfig() {
        store.revealConfigInFinder()
    }

    func openAppManagementSettings() {
        PermissionManager.openAppManagementSettings()
    }

    private func persist() {
        store.save(AppConfig(rules: rules, settings: settings))
    }
}
