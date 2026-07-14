# IconShift

> [English](README.md), [한국어](README_ko.md), [日本語](README_jp.md)

IconShift is a small macOS menu bar app that changes app icons to match Light and Dark Mode. Give an app one icon for each appearance and IconShift keeps the Finder and Dock icon in sync as the system appearance changes.

It is especially useful for Safari and Chrome web apps whose icons were designed for only one background.

## Features

- **Automatic switching** — Uses the Light or Dark icon that matches the current system appearance.
- **Per-app control** — Follow the system or keep an app on Always Light or Always Dark.
- **Simple icon setup** — Drop a PNG or ICNS file into each icon slot.
- **Launch at login** — Starts quietly after you sign in so icons stay in sync.
- **Optional menu bar icon** — Hide the icon while IconShift continues running in the background.
- **PWA recovery** — Reapplies icons when IconShift starts, including icons reset by a browser update.

## Requirements

| | Requirement |
| --- | --- |
| macOS | 14 or later |
| Mac | Apple silicon or Intel |

You do not need Xcode or any developer tools to use IconShift.

## Install

1. Download the latest `IconShift-<version>.zip` from [GitHub Releases](https://github.com/kimdaehee0824/IconShift/releases).
2. Unzip it and move `IconShift.app` to the Applications folder.
3. Open IconShift once. The current release uses ad-hoc signing, so macOS may block the first launch. After trying to open it, go to **System Settings > Privacy & Security**, scroll to **Security**, click **Open Anyway**, then confirm **Open**.
4. When IconShift first changes an app icon, allow **App Management** access. If the prompt was dismissed, go to **System Settings > Privacy & Security > App Management** and enable IconShift.

Until releases use Developer ID signing and notarization, macOS may ask you to repeat the security or App Management approval after an IconShift update.

## Usage

1. Open IconShift and click **Add App** in the sidebar.
2. Choose an installed app, then drop an image into the **Light Icon** and **Dark Icon** slots.
3. Leave **Follow system appearance** enabled for automatic switching. Turn it off to choose **Always Light** or **Always Dark**.
4. Use **Apply Now** whenever you want to reapply the selected icon immediately.

Open **Settings > General** to control **Launch at Login** and **Show Menu Bar Icon**. If you hide the menu bar icon, launch IconShift again whenever you want to reopen its window. **Settings > About** shows the installed version and license.

Finder updates immediately. If the target app is already running, its old Dock tile remains until you quit and reopen that app; this is normal macOS behavior. IconShift also reapplies configured icons when it starts, which helps restore PWA icons after Safari or Chrome updates.

## Contributing

Development and contribution instructions are in [CONTRIBUTING.md](CONTRIBUTING.md).

## License

IconShift is available under the [MIT License](LICENSE).
