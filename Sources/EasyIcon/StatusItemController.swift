import AppKit

@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
    private let model: AppModel
    private let onOpen: () -> Void
    private var statusItem: NSStatusItem?

    init(model: AppModel, onOpen: @escaping () -> Void) {
        self.model = model
        self.onOpen = onOpen
        super.init()
    }

    func setVisible(_ visible: Bool) {
        if visible {
            guard statusItem == nil else { return }
            let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            item.button?.image = NSImage(systemSymbolName: "circle.lefthalf.filled",
                                         accessibilityDescription: "EasyIcon")
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

        addItem(to: menu, title: NSLocalizedString("Open EasyIcon…", comment: ""), action: #selector(openMain), key: "o")
        addItem(to: menu, title: NSLocalizedString("Re-apply Now", comment: ""), action: #selector(reapply), key: "r")
        addItem(to: menu, title: NSLocalizedString("Open Log", comment: ""), action: #selector(openLog), key: "")
        menu.addItem(.separator())

        let login = addItem(to: menu, title: NSLocalizedString("Launch at Login", comment: ""), action: #selector(toggleLogin), key: "")
        login.state = model.settings.launchAtLogin ? .on : .off

        addItem(to: menu, title: NSLocalizedString("Hide Menu Bar Icon", comment: ""), action: #selector(hideIcon), key: "")
        menu.addItem(.separator())
        addItem(to: menu, title: NSLocalizedString("Quit EasyIcon", comment: ""), action: #selector(quit), key: "q")
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
    @objc private func toggleLogin() { model.setLaunchAtLogin(!model.settings.launchAtLogin) }
    @objc private func hideIcon() { model.setShowMenuBarIcon(false) }
    @objc private func quit() { NSApp.terminate(nil) }
}
