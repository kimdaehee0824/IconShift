import SwiftUI

/// Root split-view: app list on the left, per-app icon configuration on the right.
struct MainView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selection: AppIconRule.ID?
    @State private var showingAdd = false

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection, showingAdd: $showingAdd)
        } detail: {
            if let id = selection, model.rules.contains(where: { $0.id == id }) {
                AppDetailView(ruleID: id)
            } else {
                ContentUnavailableView(
                    "No App Selected",
                    systemImage: "app.dashed",
                    description: Text("Select an app from the sidebar, or add one with the + button.")
                )
            }
        }
        .frame(minWidth: 760, minHeight: 460)
        .sheet(isPresented: $showingAdd) { AddAppSheet() }
        .safeAreaInset(edge: .top) {
            if model.permissionGranted == false {
                permissionBanner
            }
        }
    }

    private var permissionBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text("App Management permission required")
                    .font(.headline)
                Text("EasyIcon can't change app icons until you allow it under Privacy & Security › App Management.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Open Settings") { model.openAppManagementSettings() }
                .buttonStyle(.borderedProminent)
        }
        .padding(12)
        .background(.orange.opacity(0.12))
    }
}
