import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let model = AppModel()
    private var statusController: StatusItemController?
    private var windowController: MainWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        MainMenu.install()

        model.refreshLoginItemStatus()

        let windowController = MainWindowController(model: model)
        self.windowController = windowController

        let statusController = StatusItemController(model: model) { [weak windowController] in
            windowController?.show()
        }
        self.statusController = statusController

        model.onSettingsChanged = { [weak statusController] settings in
            statusController?.setVisible(settings.showMenuBarIcon)
        }
        statusController.setVisible(model.settings.showMenuBarIcon)

        model.startMonitoring()
        // Re-apply on launch self-heals icons reset by a PWA/browser update.
        model.applyAll(reason: "launch")

        if model.rules.isEmpty {
            windowController.show()
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
