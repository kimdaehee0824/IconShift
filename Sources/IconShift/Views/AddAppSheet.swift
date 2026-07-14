import SwiftUI

struct AddAppSheet: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var apps: [InstalledApp] = []
    @State private var loading = true

    private var filtered: [InstalledApp] {
        let existing = Set(model.rules.map(\.id))
        return apps.filter { app in
            !existing.contains(app.bundleIdentifier) &&
            (searchText.isEmpty || app.name.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Add App").font(.headline)
                Spacer()
                Button("Done") { dismiss() }
            }
            .padding()
            Divider()

            if loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filtered) { app in
                    Button {
                        model.addRule(for: app)
                        dismiss()
                    } label: {
                        HStack(spacing: 10) {
                            Image(nsImage: InstalledAppsScanner.icon(forApp: app.path))
                                .resizable()
                                .frame(width: 26, height: 26)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(app.name)
                                Text(app.bundleIdentifier)
                                    .font(.caption2).foregroundStyle(.secondary)
                                    .lineLimit(1).truncationMode(.middle)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .searchable(text: $searchText, prompt: "Search installed apps")
            }
        }
        .frame(width: 460, height: 520)
        .task {
            apps = InstalledAppsScanner.scan()
            loading = false
        }
    }
}
