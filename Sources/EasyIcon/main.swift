import AppKit

// EasyIcon runs as a menu-bar / background agent (see LSUIElement in Info.plist).
// Program entry runs on the main thread, so we can assume main-actor isolation
// to construct the (main-actor-isolated) AppDelegate.
MainActor.assumeIsolated {
    let application = NSApplication.shared
    let delegate = AppDelegate()
    application.delegate = delegate
    application.run()
}
