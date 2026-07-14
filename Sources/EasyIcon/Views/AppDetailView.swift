import SwiftUI

struct AppDetailView: View {
    @EnvironmentObject private var model: AppModel
    let ruleID: AppIconRule.ID

    private var rule: AppIconRule? { model.rules.first { $0.id == ruleID } }

    var body: some View {
        if let rule {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header(rule)
                    Divider()
                    modeSection(rule)
                    iconsSection(rule)
                }
                .padding(28)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(rule.displayName)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        model.applyRule(id: rule.id)
                    } label: {
                        Label("Apply Now", systemImage: "checkmark.circle")
                    }
                }
            }
        } else {
            ContentUnavailableView("No App Selected", systemImage: "app.dashed")
        }
    }

    private func header(_ rule: AppIconRule) -> some View {
        HStack(spacing: 16) {
            Image(nsImage: InstalledAppsScanner.icon(forApp: rule.appPath))
                .resizable()
                .frame(width: 76, height: 76)
                .padding(-6)
            VStack(alignment: .leading, spacing: 4) {
                Text(rule.displayName).font(.title2).bold()
                Text(rule.appPath)
                    .font(.callout).foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .lineLimit(1).truncationMode(.middle)
            }
            Spacer()
            Toggle("Enabled", isOn: Binding(
                get: { rule.enabled },
                set: { model.setEnabled(id: rule.id, $0) }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
        }
    }

    private func modeSection(_ rule: AppIconRule) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle("Follow system appearance", isOn: Binding(
                get: { rule.mode == .auto },
                set: { newValue in
                    let fallback: IconMode = model.appearance == .dark ? .dark : .light
                    model.setMode(id: rule.id, newValue ? .auto : fallback)
                }
            ))
            .font(.headline)

            if rule.mode == .auto {
                Text("Switches between the two icons automatically when macOS switches between Light and Dark.")
                    .font(.callout).foregroundStyle(.secondary)
            } else {
                Picker("Fixed icon", selection: Binding(
                    get: { rule.mode },
                    set: { model.setMode(id: rule.id, $0) }
                )) {
                    Text("Always Light").tag(IconMode.light)
                    Text("Always Dark").tag(IconMode.dark)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(maxWidth: 280)
            }
        }
    }

    private func iconsSection(_ rule: AppIconRule) -> some View {
        let active = model.activeIconFileName(for: rule)
        return HStack(alignment: .top, spacing: 28) {
            IconWell(
                title: "Light Icon",
                subtitle: "Shown in Light mode",
                image: loadImage(rule.lightIconFileName),
                isActive: rule.lightIconFileName != nil && active == rule.lightIconFileName,
                onPick: { model.setIcon(id: rule.id, variant: .light, from: $0) },
                onClear: { model.clearIcon(id: rule.id, variant: .light) }
            )
            IconWell(
                title: "Dark Icon",
                subtitle: "Shown in Dark mode",
                image: loadImage(rule.darkIconFileName),
                isActive: rule.darkIconFileName != nil && active == rule.darkIconFileName,
                onPick: { model.setIcon(id: rule.id, variant: .dark, from: $0) },
                onClear: { model.clearIcon(id: rule.id, variant: .dark) }
            )
        }
    }

    private func loadImage(_ fileName: String?) -> NSImage? {
        guard let fileName else { return nil }
        return NSImage(contentsOf: ConfigStore.shared.iconURL(fileName))
    }
}
