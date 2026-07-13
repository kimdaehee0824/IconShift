import AppKit

/// Helpers around the macOS "App Management" permission, which gates modifying
/// other apps' bundles — required for `setIcon` on apps in /Applications and
/// ~/Applications. EasyIcon must be code-signed and granted this permission.
enum PermissionManager {
    /// Opens System Settings › Privacy & Security › App Management.
    /// Tries multiple URLs because the anchor identifier has changed across macOS versions.
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
