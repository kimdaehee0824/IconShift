import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let model = AppModel()
    private var statusController: StatusItemController?
    private var windowController: MainWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu-bar / background agent: never show a Dock icon.
        NSApp.setActivationPolicy(.accessory)

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
        // Re-apply on launch: recovers icons that were reset (e.g. a PWA/browser update).
        model.applyAll(reason: "launch")

        // First run (no rules yet): open the window so the user can configure.
        if model.rules.isEmpty {
            windowController.show()
        }
    }

    /// Re-launching the app (e.g. when the menu bar icon is hidden) reopens the window.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        windowController?.show()
        return true
    }

    /// Keep running in the background after the window closes.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
