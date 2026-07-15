import SwiftUI
import UniformTypeIdentifiers

struct IconWell: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let image: NSImage?
    let placeholder: NSImage?
    let isActive: Bool
    let onPick: (URL) -> Void
    let onClear: () -> Void

    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 10) {
            well
            caption
            controls
        }
    }

    private var well: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.quaternary)
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(borderColor, lineWidth: isTargeted ? 3 : (isActive ? 3 : 0))

            if let image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(16)
            } else if let placeholder {
                VStack(spacing: 8) {
                    Image(nsImage: placeholder)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 76, height: 76)
                        .grayscale(1)
                        .opacity(0.4)
                    Text("Keeps original icon").font(.caption)
                }
                .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 6) {
                    Image(systemName: "plus.viewfinder").font(.largeTitle)
                    Text("Drop image\nor Choose…").multilineTextAlignment(.center).font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .frame(minWidth: 168, maxWidth: .infinity)
        .frame(height: 168)
        .dropDestination(for: URL.self) { urls, _ in
            guard let url = urls.first else { return false }
            onPick(url)
            return true
        } isTargeted: { isTargeted = $0 }
    }

    private var caption: some View {
        VStack(spacing: 2) {
            HStack(spacing: 6) {
                Text(title).font(.headline)
                if isActive {
                    Text("ACTIVE")
                        .font(.caption2).bold()
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.18), in: Capsule())
                        .foregroundStyle(Color.accentColor)
                }
            }
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
    }

    private var controls: some View {
        HStack {
            Menu("Choose…") {
                Button("Choose File…") { choosePanel() }
                Link("Download from macOSicons…", destination: URL(string: "https://macosicons.com")!)
            }
            if image != nil {
                Button(role: .destructive) { onClear() } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }

    private var borderColor: Color {
        if isTargeted { return .accentColor }
        return isActive ? .accentColor : .clear
    }

    private func choosePanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image, .icns]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            onPick(url)
        }
    }
}
