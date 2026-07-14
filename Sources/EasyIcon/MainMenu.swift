import AppKit

@MainActor
enum MainMenu {
    static func install() {
        let appName = "EasyIcon"

        let appMenu = NSMenu()
        appMenu.addItem(withTitle: String(format: NSLocalizedString("About %@", comment: ""), appName),
                        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
                        keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: String(format: NSLocalizedString("Hide %@", comment: ""), appName),
                        action: #selector(NSApplication.hide(_:)),
                        keyEquivalent: "h")
        let hideOthers = appMenu.addItem(withTitle: NSLocalizedString("Hide Others", comment: ""),
                                         action: #selector(NSApplication.hideOtherApplications(_:)),
                                         keyEquivalent: "h")
        hideOthers.keyEquivalentModifierMask = [.command, .option]
        appMenu.addItem(withTitle: NSLocalizedString("Show All", comment: ""),
                        action: #selector(NSApplication.unhideAllApplications(_:)),
                        keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: String(format: NSLocalizedString("Quit %@", comment: ""), appName),
                        action: #selector(NSApplication.terminate(_:)),
                        keyEquivalent: "q")

        let editMenu = NSMenu(title: NSLocalizedString("Edit", comment: ""))
        editMenu.addItem(withTitle: NSLocalizedString("Undo", comment: ""), action: Selector(("undo:")), keyEquivalent: "z")
        editMenu.addItem(withTitle: NSLocalizedString("Redo", comment: ""), action: Selector(("redo:")), keyEquivalent: "Z")
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: NSLocalizedString("Cut", comment: ""), action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: NSLocalizedString("Copy", comment: ""), action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: NSLocalizedString("Paste", comment: ""), action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: NSLocalizedString("Select All", comment: ""), action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        let windowMenu = NSMenu(title: NSLocalizedString("Window", comment: ""))
        windowMenu.addItem(withTitle: NSLocalizedString("Close", comment: ""), action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        windowMenu.addItem(withTitle: NSLocalizedString("Minimize", comment: ""), action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: NSLocalizedString("Zoom", comment: ""), action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")

        let main = NSMenu()
        for (title, submenu) in [(appName, appMenu),
                                 (NSLocalizedString("Edit", comment: ""), editMenu),
                                 (NSLocalizedString("Window", comment: ""), windowMenu)] {
            let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            item.submenu = submenu
            main.addItem(item)
        }
        NSApp.mainMenu = main
        NSApp.windowsMenu = windowMenu
    }
}
