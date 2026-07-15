import SwiftUI

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
            .frame(minWidth: 420)
            // safeAreaInset here breaks NSToolbar bridging (title/toolbar collapse); overlay doesn't.
            .overlay(alignment: .bottom) {
                if model.permissionGranted == false {
                    permissionBanner
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)
                }
            }
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
        .frame(minWidth: 760, idealWidth: 880, minHeight: 500, idealHeight: 560)
        .onAppear {
            if selection == nil { selection = model.rules.first?.id }
        }
        .sheet(isPresented: $showingAdd) { AddAppSheet() }
    }

    private var permissionBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text("App Management permission required")
                    .font(.headline)
                Text("IconShift can't change app icons until you allow it under Privacy & Security › App Management.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 16)
            Button("Open Settings") { model.openAppManagementSettings() }
                .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: 640)
        .modifier(FloatingBannerSurface())
    }
}

private struct FloatingBannerSurface: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content.glassEffect(.regular, in: .rect(cornerRadius: 16))
        } else {
            content
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(.separator.opacity(0.5)))
                .shadow(color: .black.opacity(0.18), radius: 12, y: 4)
        }
    }
}
