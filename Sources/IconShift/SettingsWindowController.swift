import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSObject, NSWindowDelegate {
    private let model: AppModel
    private var window: NSWindow?
    var onWindowClosed: (() -> Void)?

    init(model: AppModel) {
        self.model = model
        super.init()
    }

    var isVisible: Bool { window?.isVisible ?? false }

    func show() {
        if window == nil {
            let tabs = SettingsTabViewController()
            tabs.tabStyle = .toolbar
            tabs.addTabViewItem(makeTab(GeneralSettingsView().environmentObject(model),
                                        label: NSLocalizedString("General", comment: ""),
                                        symbol: "gearshape"))
            tabs.addTabViewItem(makeTab(AboutSettingsView(),
                                        label: NSLocalizedString("About", comment: ""),
                                        symbol: "info.circle"))

            let window = NSWindow(contentViewController: tabs)
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.title = tabs.tabViewItems[0].label
            window.isReleasedWhenClosed = false
            window.delegate = self
            window.center()
            self.window = window
        }
        NSApp.setActivationPolicy(.regular)
        NSApp.activate()
        window?.makeKeyAndOrderFront(nil)
    }

    private func makeTab(_ root: some View, label: String, symbol: String) -> NSTabViewItem {
        let hosting = NSHostingController(rootView: root)
        hosting.sizingOptions = .preferredContentSize
        // The window syncs its title from the selected child's title; nil resets it to "Untitled".
        hosting.title = label
        let item = NSTabViewItem(viewController: hosting)
        item.label = label
        item.image = NSImage(systemSymbolName: symbol, accessibilityDescription: label)
        return item
    }

    func windowWillClose(_ notification: Notification) {
        onWindowClosed?()
    }
}

private final class SettingsTabViewController: NSTabViewController {
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)
        view.window?.title = tabViewItem?.label ?? ""
    }
}
