import AppKit
import SwiftUI

@MainActor
final class MainWindowController: NSObject, NSWindowDelegate {
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
            let hosting = NSHostingController(rootView: MainView().environmentObject(model))
            hosting.sceneBridgingOptions = [.toolbars, .title]
            let window = NSWindow(contentViewController: hosting)
            window.title = "IconShift"
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
            window.toolbarStyle = .unified
            window.isReleasedWhenClosed = false
            window.delegate = self
            // Size comes from MainView's frame (ideal = first-launch size); autosave persists user resizes.
            window.setFrameAutosaveName("MainWindow")
            if !window.setFrameUsingName("MainWindow") {
                window.center()
            }
            self.window = window
        }
        // .regular only while a window is open (layering, activation, Stage Manager);
        // AppDelegate drops back to .accessory once the last window closes.
        NSApp.setActivationPolicy(.regular)
        NSApp.activate()
        window?.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        onWindowClosed?()
    }
}
