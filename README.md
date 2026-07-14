# IconShift

> You can view the document in different languages: [English](README.md), [한국어](README_ko.md), [日本語](README_jp.md)

**IconShift** is a small macOS menu bar app that **swaps app icons to match Light and Dark Mode**. Assign each app one icon per appearance, and IconShift keeps its Finder and Dock icon in sync whenever the system appearance changes.

It is especially handy for Safari and Chrome web apps, whose icons are usually drawn for a single background and end up clashing with the other mode.

- **Automatic switching**: Applies the matching Light or Dark icon the moment the system appearance changes
- **Per-app control**: Follow the system, or pin an app to Always Light or Always Dark
- **Simple setup**: Drop a PNG or ICNS file onto each icon slot, or pick one from a file dialog
- **Launch at login**: Starts quietly in the background and keeps icons in sync
- **Optional menu bar icon**: Hide it entirely; IconShift keeps working in the background
- **Self-healing**: Reapplies your icons at every launch, restoring ones reset by a browser update

## Requirements

| Item  | Requirement                         |
| ----- | ----------------------------------- |
| macOS | 14 or later                         |
| Mac   | Apple silicon and Intel (Universal) |

You do not need Xcode or any developer tools to use IconShift.

## Install

1. Download the latest `IconShift-<version>.zip` from [GitHub Releases](https://github.com/kimdaehee0824/IconShift/releases).
2. Unzip it and move `IconShift.app` into your Applications folder.
3. Open IconShift once. Releases are not notarized yet, so macOS may block the first launch. If it does, go to **System Settings > Privacy & Security**, scroll down to **Security**, click **Open Anyway**, then confirm with **Open**.
4. The first time IconShift changes an app icon, macOS asks for **App Management** access. Click **Allow**. If you missed the prompt, enable IconShift under **System Settings > Privacy & Security > App Management**.

Until releases are notarized, macOS may ask for these approvals again after you update IconShift.

## Usage

1. Open IconShift and click **Add App** in the sidebar.
2. Pick an installed app, then drop an image onto the **Light Icon** and **Dark Icon** slots.
3. Leave **Follow system appearance** on for automatic switching, or turn it off and choose **Always Light** or **Always Dark**.
4. Click **Apply Now** whenever you want to reapply the selected icon right away.

Open **Settings > General** to toggle **Launch at Login** and **Show Menu Bar Icon**. With the menu bar icon hidden, IconShift keeps running in the background; launch it again from the Applications folder to bring the window back. **Settings > About** shows the version and license.

Finder picks up icon changes immediately. An app that is already running keeps its old Dock tile until you quit and reopen it, which is normal macOS behavior. IconShift also reapplies your icons every time it starts, so web app icons reset by a Safari or Chrome update come back on their own.

## Contributing

Development setup and contribution guidelines are in [CONTRIBUTING.md](CONTRIBUTING.md).

## License

IconShift is available under the [MIT License](LICENSE).
