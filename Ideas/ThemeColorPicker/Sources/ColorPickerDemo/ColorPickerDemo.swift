import SwiftUI
import ThemeColorPicker

@main
struct ColorPickerDemo: App {
    var body: some Scene {
        WindowGroup {
            ColorPickerDemoView()
                .frame(minWidth: 700, minHeight: 620)
        }
    }
}

private struct ColorPickerDemoView: View {
    @State private var theme = ThemeColorPickerValue()
    @State private var showsThemePicker = true

    var body: some View {
        ZStack {
            ThemeColorBackground(value: theme)
                .ignoresSafeArea()

            HStack(spacing: 0) {
                SidebarPreview(showsThemePicker: $showsThemePicker)
                    .frame(width: 170)

                Spacer(minLength: 0)
            }

            if showsThemePicker {
                ThemeColorPicker(value: $theme)
                    .shadow(color: .black.opacity(0.18), radius: 26, y: 18)
                    .transition(.scale(scale: 0.98).combined(with: .opacity))
            }
        }
        .animation(.snappy(duration: 0.2), value: showsThemePicker)
    }
}

private struct SidebarPreview: View {
    @Binding var showsThemePicker: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Circle()
                    .fill(.primary.opacity(0.12))
                    .frame(width: 34, height: 34)

                Text("Default")
                    .font(.system(size: 13, weight: .semibold))
            }

            VStack(spacing: 8) {
                SidebarRow(title: "Pinned", isSelected: false)
                SidebarRow(title: "Workspace", isSelected: true)
                SidebarRow(title: "New Tab", isSelected: false)
            }

            Spacer()
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .contentShape(Rectangle())
        .contextMenu {
            Button("Edit Theme") {
                showsThemePicker = true
            }
        }
    }
}

private struct SidebarRow: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(.primary.opacity(isSelected ? 0.18 : 0.1))
                .frame(width: 24, height: 24)

            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))

            Spacer()
        }
        .padding(.horizontal, 9)
        .frame(height: 36)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.primary.opacity(0.08))
            }
        }
    }
}
