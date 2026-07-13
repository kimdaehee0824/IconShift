import AppKit

/// Result of an icon apply attempt.
struct IconApplyResult {
    let success: Bool
    let message: String
}

/// Core icon-writing logic, proven against macOS 26 App Management protection.
///
/// Key facts established empirically:
///  - `NSWorkspace.setIcon` on an app registered in a protected location
///    (e.g. ~/Applications) fails unless the calling app is code-signed and the
///    user has granted it "App Management" permission.
///  - A *failed* `setIcon` can still flip the FinderInfo custom-icon bit
///    (offset 8, mask 0x04) without writing icon data, leaving the app showing a
///    generic folder icon. We therefore verify and roll that bit back on failure.
enum IconApplier {

    /// Returns whether the FinderInfo custom-icon bit is set, or `nil` if there is
    /// no FinderInfo extended attribute at all.
    static func hasCustomIconBit(_ path: String) -> Bool? {
        var buffer = [UInt8](repeating: 0, count: 32)
        let count = getxattr(path, "com.apple.FinderInfo", &buffer, buffer.count, 0, 0)
        guard count >= 0 else { return nil }
        guard count >= 9 else { return false }
        return (buffer[8] & 0x04) != 0
    }

    /// Removes the FinderInfo extended attribute, clearing the custom-icon bit.
    @discardableResult
    static func clearFinderInfo(_ path: String) -> Bool {
        removexattr(path, "com.apple.FinderInfo", 0) == 0
    }

    /// Applies an icon image file to an app bundle, verifying success and rolling
    /// back a partial write so a failure never corrupts the existing icon.
    static func apply(iconPath: String, toApp appPath: String) -> IconApplyResult {
        let fm = FileManager.default
        guard fm.fileExists(atPath: appPath) else {
            return IconApplyResult(success: false, message: "Target app not found: \(appPath)")
        }
        guard fm.fileExists(atPath: iconPath), let image = NSImage(contentsOfFile: iconPath) else {
            return IconApplyResult(success: false, message: "Icon image could not be loaded: \(iconPath)")
        }

        let before = hasCustomIconBit(appPath)
        let ok = NSWorkspace.shared.setIcon(image, forFile: appPath, options: [])
        if ok {
            return IconApplyResult(success: true, message: "Applied icon to \(appPath)")
        }

        // Partial-write guard: if the bit got set but the write failed, roll it back.
        if hasCustomIconBit(appPath) == true && before != true {
            _ = clearFinderInfo(appPath)
        }
        return IconApplyResult(
            success: false,
            message: "setIcon failed for \(appPath) — App Management permission is likely required."
        )
    }

    /// Removes any custom icon and restores the bundle's default icon.
    @discardableResult
    static func clearIcon(app appPath: String) -> Bool {
        let ok = NSWorkspace.shared.setIcon(nil, forFile: appPath, options: [])
        if hasCustomIconBit(appPath) == true {
            _ = clearFinderInfo(appPath)
        }
        return ok
    }
}
