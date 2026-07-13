import AppKit
import SwiftUI

@MainActor
final class MainWindowController: NSObject, NSWindowDelegate {
    private let model: AppModel
    private var window: NSWindow?

    init(model: AppModel) {
        self.model = model
        super.init()
    }

    func show() {
        if window == nil {
            let hosting = NSHostingController(rootView: MainView().environmentObject(model))
            let window = NSWindow(contentViewController: hosting)
            window.title = "EasyIcon"
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.setContentSize(NSSize(width: 880, height: 560))
            window.isReleasedWhenClosed = false
            window.delegate = self
            window.center()
            self.window = window
        }
        // Act as a regular app while the window is open so it layers, activates, and
        // participates in Stage Manager like a normal app (not a background agent).
        NSApp.setActivationPolicy(.regular)
        NSApp.activate()
        window?.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
