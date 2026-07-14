import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Form {
            Section {
                Toggle("Launch at Login", isOn: Binding(
                    get: { model.settings.launchAtLogin },
                    set: { model.setLaunchAtLogin($0) }
                ))
                Text("Starts IconShift in the background at login so icons stay in sync.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Section {
                Toggle("Show Menu Bar Icon", isOn: Binding(
                    get: { model.settings.showMenuBarIcon },
                    set: { model.setShowMenuBarIcon($0) }
                ))
                Text("If the icon is hidden, launch IconShift again to open the app window.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 440, height: 240)
    }
}

struct AboutSettingsView: View {
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    var body: some View {
        VStack(spacing: 8) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)
            Text(verbatim: "IconShift")
                .font(.title2).bold()
            Text("Version \(version)")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text("Swaps app icons to match Light and Dark Mode.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
            Text(verbatim: "MIT License · © 2026 IconShift Contributors")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.top, 8)
        }
        .padding(32)
        .frame(width: 440)
    }
}
