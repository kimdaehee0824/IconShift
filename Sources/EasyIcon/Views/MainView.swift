import SwiftUI

/// Root split-view: app list on the left, per-app icon configuration on the right.
struct MainView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selection: AppIconRule.ID?
    @State private var showingAdd = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selection: $selection, showingAdd: $showingAdd)
                .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 320)
        } detail: {
            Group {
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
            // Two 168pt icon wells + 28pt spacing + 28pt outer padding on both sides.
            .frame(minWidth: 420)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                        withAnimation {
                            columnVisibility = columnVisibility == .detailOnly ? .all : .detailOnly
                        }
                    } label: {
                        Label("Toggle Sidebar", systemImage: "sidebar.leading")
                    }
                    .help("Show or hide the sidebar")
                    .keyboardShortcut("s", modifiers: [.control, .command])
                }
            }
        }
        .frame(minWidth: 760, minHeight: 460)
        .onAppear {
            if selection == nil { selection = model.rules.first?.id }
        }
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
