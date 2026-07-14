import AppKit

enum PermissionManager {
    // The settings anchor id has changed across macOS versions, so several URLs are tried in order.
    static func openAppManagementSettings() {
        let candidates = [
            "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_AppBundles",
            "x-apple.systempreferences:com.apple.preference.security?Privacy_AppBundles",
            "x-apple.systempreferences:com.apple.preference.security"
        ]
        for string in candidates {
            if let url = URL(string: string), NSWorkspace.shared.open(url) { return }
        }
    }
}
