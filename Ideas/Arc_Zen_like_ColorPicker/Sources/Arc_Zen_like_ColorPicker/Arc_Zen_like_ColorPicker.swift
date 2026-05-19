import SwiftUI
import ZenThemeColorPicker

@main
struct Arc_Zen_like_ColorPicker: App {
    var body: some Scene {
        WindowGroup {
            ZenThemeColorPickerPreview()
                .frame(minWidth: 560, minHeight: 620)
        }
    }
}

private struct ZenThemeColorPickerPreview: View {
    @State private var value = ZenThemePickerValue()

    var body: some View {
        ZStack {
            ZenThemeBackground(value: value)
                .ignoresSafeArea()

            ZenThemeColorPicker(value: $value)
        }
    }
}
