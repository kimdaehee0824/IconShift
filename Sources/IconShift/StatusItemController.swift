import AppKit
import Sparkle

@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
    private let model: AppModel
    private let updater: SPUStandardUpdaterController
    private let onOpen: () -> Void
    private let onOpenSettings: () -> Void
    private var statusItem: NSStatusItem?

    init(model: AppModel,
         updater: SPUStandardUpdaterController,
         onOpen: @escaping () -> Void,
         onOpenSettings: @escaping () -> Void) {
        self.model = model
        self.updater = updater
        self.onOpen = onOpen
        self.onOpenSettings = onOpenSettings
        super.init()
    }

    func setVisible(_ visible: Bool) {
        if visible {
            guard statusItem == nil else { return }
            let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            item.button?.image = NSImage(systemSymbolName: "circle.lefthalf.filled",
                                         accessibilityDescription: "IconShift")
            let menu = NSMenu()
            menu.delegate = self
            item.menu = menu
            statusItem = item
        } else if let item = statusItem {
            NSStatusBar.system.removeStatusItem(item)
            statusItem = nil
        }
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        let header = NSMenuItem(
            title: String(format: NSLocalizedString("Appearance: %@", comment: ""), model.appearance.label),
            action: nil, keyEquivalent: ""
        )
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(.separator())

        addItem(to: menu, title: NSLocalizedString("Open IconShift…", comment: ""), action: #selector(openMain), key: "o")
        addItem(to: menu, title: NSLocalizedString("Re-apply Now", comment: ""), action: #selector(reapply), key: "r")
        addItem(to: menu, title: NSLocalizedString("Open Log", comment: ""), action: #selector(openLog), key: "")
        menu.addItem(.separator())

        addItem(to: menu, title: NSLocalizedString("Settings…", comment: ""), action: #selector(openSettings), key: ",")
        let checkForUpdates = NSMenuItem(title: NSLocalizedString("Check for Updates…", comment: ""),
                                         action: #selector(SPUStandardUpdaterController.checkForUpdates(_:)),
                                         keyEquivalent: "")
        checkForUpdates.target = updater
        menu.addItem(checkForUpdates)
        menu.addItem(.separator())
        addItem(to: menu, title: NSLocalizedString("Quit IconShift", comment: ""), action: #selector(quit), key: "q")
    }

    @discardableResult
    private func addItem(to menu: NSMenu, title: String, action: Selector, key: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        menu.addItem(item)
        return item
    }

    @objc private func openMain() { onOpen() }
    @objc private func reapply() { model.applyAll(reason: "manual-reapply") }
    @objc private func openLog() { NSWorkspace.shared.open(model.logFileURL) }
    @objc private func openSettings() { onOpenSettings() }
    @objc private func quit() { NSApp.terminate(nil) }
}
