import AppKit

struct IconApplyResult {
    let success: Bool
    let message: String
}

// A failed setIcon (blocked without the App Management grant) can still flip the FinderInfo
// custom-icon bit (offset 8, 0x04) without icon data, so writes are verified and rolled back.
enum IconApplier {

    static func hasCustomIconBit(_ path: String) -> Bool? {
        var buffer = [UInt8](repeating: 0, count: 32)
        let count = getxattr(path, "com.apple.FinderInfo", &buffer, buffer.count, 0, 0)
        guard count >= 0 else { return nil }
        guard count >= 9 else { return false }
        return (buffer[8] & 0x04) != 0
    }

    @discardableResult
    static func clearFinderInfo(_ path: String) -> Bool {
        removexattr(path, "com.apple.FinderInfo", 0) == 0
    }

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

        if hasCustomIconBit(appPath) == true && before != true {
            _ = clearFinderInfo(appPath)
        }
        return IconApplyResult(
            success: false,
            message: "setIcon failed for \(appPath) — App Management permission is likely required."
        )
    }

    @discardableResult
    static func clearIcon(app appPath: String) -> Bool {
        let ok = NSWorkspace.shared.setIcon(nil, forFile: appPath, options: [])
        if hasCustomIconBit(appPath) == true {
            _ = clearFinderInfo(appPath)
        }
        return ok
    }
}
