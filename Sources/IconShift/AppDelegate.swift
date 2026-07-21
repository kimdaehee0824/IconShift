import AppKit
import Sparkle

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let model = AppModel()
    private let updaterController = SPUStandardUpdaterController(
        startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil
    )
    private var statusController: StatusItemController?
    private var windowController: MainWindowController?
    private var settingsController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        MainMenu.install(updater: updaterController)

        model.refreshLoginItemStatus()

        let windowController = MainWindowController(model: model)
        self.windowController = windowController

        let settingsController = SettingsWindowController(model: model)
        self.settingsController = settingsController

        windowController.onWindowClosed = { [weak self] in self?.dropRegularPolicyIfNoWindows() }
        settingsController.onWindowClosed = { [weak self] in self?.dropRegularPolicyIfNoWindows() }

        let statusController = StatusItemController(
            model: model,
            updater: updaterController,
            onOpen: { [weak windowController] in windowController?.show() },
            onOpenSettings: { [weak self] in self?.showSettings(nil) }
        )
        self.statusController = statusController

        model.onSettingsChanged = { [weak statusController] settings in
            statusController?.setVisible(settings.showMenuBarIcon)
        }
        statusController.setVisible(model.settings.showMenuBarIcon)

        model.startMonitoring()
        // Re-apply on launch self-heals icons reset by a PWA/browser update.
        model.applyAll(reason: "launch")

        // Login-item launches stay in the background; any manual launch means "show me the UI".
        if !launchedAsLoginItem {
            windowController.show()
        }
    }

    // The opening Apple event carries keyAELaunchedAsLogInItem only for login-item launches.
    private var launchedAsLoginItem: Bool {
        guard let event = NSAppleEventManager.shared().currentAppleEvent else { return false }
        return event.eventID == AEEventID(kAEOpenApplication)
            && event.paramDescriptor(forKeyword: AEKeyword(keyAEPropData))?.enumCodeValue == OSType(keyAELaunchedAsLogInItem)
    }

    @objc func showSettings(_ sender: Any?) {
        settingsController?.show()
    }

    // Deferred a turn: the closing window still reports isVisible during windowWillClose.
    private func dropRegularPolicyIfNoWindows() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.windowController?.isVisible != true && self.settingsController?.isVisible != true {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        windowController?.show()
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
