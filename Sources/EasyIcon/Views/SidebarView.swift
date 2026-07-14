import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var model: AppModel
    @Binding var selection: AppIconRule.ID?
    @Binding var showingAdd: Bool
    @State private var searchText = ""

    private var filteredRules: [AppIconRule] {
        guard !searchText.isEmpty else { return model.rules }
        return model.rules.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            $0.appPath.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(filteredRules) { rule in
                AppRow(rule: rule)
                    .tag(rule.id)
                    .contextMenu {
                        Button(role: .destructive) {
                            model.removeRule(id: rule.id)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
            }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search apps")
        .navigationTitle("EasyIcon")
        .toolbar {
            ToolbarItem {
                Button {
                    showingAdd = true
                } label: {
                    Label("Add App", systemImage: "plus")
                }
            }
        }
    }
}

private struct AppRow: View {
    let rule: AppIconRule

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: InstalledAppsScanner.icon(forApp: rule.appPath))
                .resizable()
                .frame(width: 28, height: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(rule.displayName)
                    .lineLimit(1)
                Text(rule.appPath)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer(minLength: 4)
            if rule.enabled {
                Text(rule.mode.label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "pause.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
