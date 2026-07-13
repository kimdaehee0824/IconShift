import AppKit
import SwiftUI

/// Hosts the SwiftUI settings window inside an AppKit window so the shell keeps
/// full control over show/hide/reopen independent of the menu bar state.
@MainActor
final class MainWindowController {
    private let model: AppModel
    private var window: NSWindow?

    init(model: AppModel) {
        self.model = model
    }

    func show() {
        if window == nil {
            let hosting = NSHostingController(rootView: MainView().environmentObject(model))
            let window = NSWindow(contentViewController: hosting)
            window.title = "EasyIcon"
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.setContentSize(NSSize(width: 880, height: 560))
            window.isReleasedWhenClosed = false
            window.center()
            self.window = window
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
