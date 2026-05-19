import SwiftUI

public enum ZenThemeScheme: String, CaseIterable, Identifiable, Sendable {
    case automatic
    case light
    case dark

    public var id: String { rawValue }
}

public struct ZenThemeColor: Equatable, Sendable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

extension ZenThemeColor {
    public init(hex: UInt32, alpha: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            alpha: alpha
        )
    }

    public var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }

    public var hexString: String {
        let r = Int((red * 255).rounded())
        let g = Int((green * 255).rounded())
        let b = Int((blue * 255).rounded())
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

public struct ZenThemeColorDot: Identifiable, Equatable, Sendable {
    public var id: UUID
    public var color: ZenThemeColor
    public var x: Double
    public var y: Double

    public init(id: UUID = UUID(), color: ZenThemeColor, x: Double, y: Double) {
        self.id = id
        self.color = color
        self.x = x
        self.y = y
    }
}

public struct ZenThemePickerValue: Equatable, Sendable {
    public var scheme: ZenThemeScheme
    public var dots: [ZenThemeColorDot]
    public var opacity: Double
    public var customColors: [ZenThemeColor]

    public init(
        scheme: ZenThemeScheme = .automatic,
        dots: [ZenThemeColorDot] = Self.defaultDots,
        opacity: Double = 0.42,
        customColors: [ZenThemeColor] = []
    ) {
        self.scheme = scheme
        self.dots = dots
        self.opacity = opacity
        self.customColors = customColors
    }
}

extension ZenThemePickerValue {
    public static let defaultDots = [
        ZenThemeColorDot(color: ZenThemeColor(hex: 0xF2E9D1), x: 226, y: 232)
    ]
}

public struct ZenThemeBackground: View {
    private let value: ZenThemePickerValue

    public init(value: ZenThemePickerValue) {
        self.value = value
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(red: 0.985, green: 0.982, blue: 0.976)

                LinearGradient(
                    colors: backgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.86)

                ForEach(value.dots) { dot in
                    Circle()
                        .fill(dot.color.color.opacity(backgroundNodeOpacity))
                        .blur(radius: min(proxy.size.width, proxy.size.height) * 0.16)
                    .frame(
                        width: proxy.size.width * 0.58,
                        height: proxy.size.width * 0.58
                    )
                    .position(backgroundPoint(for: dot, in: proxy.size))
                }
            }
            .clipped()
        }
        .allowsHitTesting(false)
    }

    private var backgroundColors: [Color] {
        guard let first = value.dots.first?.color.color else {
            return [
                Color(red: 0.96, green: 0.97, blue: 0.99),
                Color(red: 0.99, green: 0.95, blue: 0.98)
            ]
        }

        let last = value.dots.last?.color.color ?? first
        return [
            first.opacity(max(0.24, value.opacity * 0.72)),
            last.opacity(max(0.28, value.opacity * 0.86))
        ]
    }

    private var backgroundNodeOpacity: Double {
        max(0.22, min(0.58, value.opacity * 0.92))
    }

    private func backgroundPoint(for dot: ZenThemeColorDot, in size: CGSize) -> CGPoint {
        CGPoint(
            x: size.width * dot.x / 360,
            y: size.height * dot.y / 360
        )
    }
}

public struct ZenThemeColorPicker: View {
    @Binding private var value: ZenThemePickerValue
    private let showsCustomColors: Bool
    @State private var currentPage = 0
    @State private var customColor = ZenThemeColor(hex: 0xA588FF)
    @State private var customOpacity = 1.0
    @State private var draggingDotID: UUID?

    /// Creates a reusable Zen-style theme color picker.
    ///
    /// Example:
    /// ```swift
    /// @State private var theme = ZenThemePickerValue()
    /// ZenThemeColorPicker(value: $theme)
    /// ```
    public init(value: Binding<ZenThemePickerValue>, showsCustomColors: Bool = true) {
        self._value = value
        self.showsCustomColors = showsCustomColors
    }

    public var body: some View {
        VStack(spacing: Metrics.controlGap) {
            gradientEditor
            palettePager
            controls

            if showsCustomColors {
                customColorControls
            }
        }
        .frame(width: Metrics.panelWidth)
        .padding(.top, Metrics.panelPadding)
        .padding(.bottom, Metrics.panelPadding + 1)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Metrics.panelRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Metrics.panelRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.09))
        }
    }
}

private extension ZenThemeColorPicker {
    enum Metrics {
        static let panelWidth: CGFloat = 372
        static let panelPadding: CGFloat = 12
        static let panelRadius: CGFloat = 13
        static let gradientSize: CGFloat = 346
        static let sourceSize: CGFloat = 360
        static let controlGap: CGFloat = 11
        static let dotSize: CGFloat = 21
        static let firstDotSize: CGFloat = 36
        static let iconButtonSize: CGFloat = 29
        static let swatchSize: CGFloat = 25
    }
}

private extension ZenThemeColorPicker {
    var gradientEditor: some View {
        ZStack {
            ZenDottedWell()

            HStack(spacing: 5) {
                schemeButton(.automatic, systemImage: "circle.grid.cross")
                schemeButton(.light, systemImage: "sun.min")
                schemeButton(.dark, systemImage: "moon.fill")
            }
            .position(x: Metrics.gradientSize / 2, y: 30)

            HStack(spacing: 5) {
                actionButton(systemImage: "plus", disabled: value.dots.count >= 3) {
                    addDot()
                }
                actionButton(systemImage: "arrow.triangle.2.circlepath", disabled: value.dots.count < 2) {
                    rotateAlgorithm()
                }
            }
            .position(x: Metrics.gradientSize / 2, y: Metrics.gradientSize - 24)

            Text("Right click a node to remove it")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary.opacity(0.82))
                .allowsHitTesting(false)
                .position(x: Metrics.gradientSize / 2, y: Metrics.gradientSize - 50)

            if value.dots.isEmpty {
                Text("Click to add")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .allowsHitTesting(false)
            }

            ForEach(Array(value.dots.enumerated()), id: \.element.id) { index, dot in
                colorDot(dot, isPrimary: index == 0)
            }
        }
        .frame(width: Metrics.gradientSize, height: Metrics.gradientSize)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.panelRadius - 4, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture(coordinateSpace: .local) { point in
            addDot(at: point)
        }
    }

    func schemeButton(_ scheme: ZenThemeScheme, systemImage: String) -> some View {
        Button {
            value.scheme = scheme
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .frame(width: Metrics.iconButtonSize, height: Metrics.iconButtonSize)
                .foregroundStyle(value.scheme == scheme ? Color.primary : Color.primary.opacity(0.72))
        }
        .buttonStyle(.plain)
        .background {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(value.scheme == scheme ? Color.primary.opacity(0.13) : Color.clear)
        }
        .contentShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .help(scheme.rawValue.capitalized)
    }

    func actionButton(systemImage: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .frame(width: Metrics.iconButtonSize, height: Metrics.iconButtonSize)
                .foregroundStyle(Color.primary.opacity(disabled ? 0.38 : 0.82))
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .background {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.primary.opacity(0.0001))
        }
        .contentShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }

    func colorDot(_ dot: ZenThemeColorDot, isPrimary: Bool) -> some View {
        let size = isPrimary ? Metrics.firstDotSize : Metrics.dotSize
        let borderWidth: CGFloat = isPrimary ? 6 : 3

        return Circle()
            .fill(dot.color.color)
            .frame(width: size, height: size)
            .overlay {
                Circle().strokeBorder(.white, lineWidth: borderWidth)
            }
            .shadow(color: .black.opacity(0.16), radius: 2, x: 0, y: 1)
            .scaleEffect(draggingDotID == dot.id ? 1.2 : 1)
            .position(point(for: dot))
            .zIndex(isPrimary ? 10 : 2)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        draggingDotID = dot.id
                        moveDot(dot.id, to: gesture.location)
                    }
                    .onEnded { _ in
                        draggingDotID = nil
                    }
            )
            .contextMenu {
                Button("Remove Node") {
                    removeDot(dot.id)
                }
                .disabled(value.dots.count <= 1)
            }
    }
}

private extension ZenThemeColorPicker {
    var palettePager: some View {
        HStack(spacing: 9) {
            pageButton(systemImage: "chevron.left", disabled: currentPage == 0) {
                currentPage = max(0, currentPage - 1)
            }

            HStack(spacing: paletteSpacing) {
                ForEach(Self.palettePages[currentPage]) { swatch in
                    Button {
                        apply(swatch)
                    } label: {
                        ZenPaletteSwatchView(swatch: swatch)
                            .frame(width: Metrics.swatchSize, height: Metrics.swatchSize)
                    }
                    .buttonStyle(.plain)
                    .help(swatch.label)
                }
            }
            .frame(maxWidth: .infinity)

            pageButton(systemImage: "chevron.right", disabled: currentPage == Self.palettePages.count - 1) {
                currentPage = min(Self.palettePages.count - 1, currentPage + 1)
            }
        }
        .frame(width: Metrics.gradientSize)
    }

    var paletteSpacing: CGFloat {
        Self.palettePages[currentPage].count > 8 ? 6 : 10
    }

    func pageButton(systemImage: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 28, height: 28)
                .foregroundStyle(Color.primary.opacity(disabled ? 0.35 : 0.82))
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .contentShape(Rectangle())
    }
}

private extension ZenThemeColorPicker {
    var controls: some View {
        ZenOpacityWaveSlider(value: Binding(
            get: { value.opacity },
            set: { value.opacity = min(0.88, max(0.28, $0)) }
        ))
        .frame(height: 40)
        .frame(width: Metrics.gradientSize)
    }

    var customColorControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Custom Color")
                .font(.system(size: 12, weight: .semibold))

            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(customColor.color)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .strokeBorder(Color.primary.opacity(0.13))
                        }

                    ColorPicker("", selection: Binding(
                        get: { customColor.color.opacity(customOpacity) },
                        set: { customColor = ZenThemeColor(nsColor: NSColor($0)); customOpacity = customColor.alpha }
                    ), supportsOpacity: true)
                    .labelsHidden()
                    .opacity(0.001)
                }
                .frame(width: 42, height: 28)

                Text(customColor.hexString)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(customOpacity, format: .number.precision(.fractionLength(2)))
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .frame(width: 52, height: 28)
                    .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 5, style: .continuous))

                Button {
                    addCustomColor()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .background(Color.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            }

            if !value.customColors.isEmpty {
                VStack(spacing: 0) {
                    ForEach(value.customColors.indices, id: \.self) { index in
                        customColorRow(value.customColors[index], index: index)
                    }
                }
                .padding(.top, 7)
            }
        }
        .frame(width: Metrics.gradientSize)
    }

    func customColorRow(_ color: ZenThemeColor, index: Int) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(color.color)
                .frame(width: 18, height: 18)
                .overlay {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.12))
                }

            Text(color.hexString)
                .font(.system(size: 12, weight: .semibold))

            Spacer()

            Button {
                value.customColors.remove(at: index)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .opacity(0.75)
        }
        .padding(5)
    }
}

private extension ZenThemeColorPicker {
    /// Maps preset-space coordinates onto the visible square.
    func point(for dot: ZenThemeColorDot) -> CGPoint {
        CGPoint(
            x: dot.x / Metrics.sourceSize * Metrics.gradientSize,
            y: dot.y / Metrics.sourceSize * Metrics.gradientSize
        )
    }

    /// Converts a visible point back into preset space and clamps it inside the well.
    func sourcePoint(from point: CGPoint) -> CGPoint {
        CGPoint(
            x: min(Metrics.sourceSize, max(0, point.x / Metrics.gradientSize * Metrics.sourceSize)),
            y: min(Metrics.sourceSize, max(0, point.y / Metrics.gradientSize * Metrics.sourceSize))
        )
    }

    func addDot(at visiblePoint: CGPoint? = nil) {
        guard value.dots.count < 3 else { return }

        let source = sourcePoint(from: visiblePoint ?? CGPoint(x: Metrics.gradientSize / 2, y: Metrics.gradientSize / 2))
        value.dots.append(
            ZenThemeColorDot(
                color: color(at: source),
                x: source.x,
                y: source.y
            )
        )
    }

    func moveDot(_ id: UUID, to visiblePoint: CGPoint) {
        guard let index = value.dots.firstIndex(where: { $0.id == id }) else { return }
        let source = sourcePoint(from: visiblePoint)
        value.dots[index].x = source.x
        value.dots[index].y = source.y
        value.dots[index].color = color(at: source)
    }

    func removeDot(_ id: UUID) {
        guard value.dots.count > 1 else { return }
        value.dots.removeAll { $0.id == id }
    }

    func rotateAlgorithm() {
        guard value.dots.count > 1 else { return }
        let first = value.dots[0]
        value.dots = value.dots.enumerated().map { index, dot in
            var next = dot
            let angle = Double(index) * 2 * .pi / Double(value.dots.count)
            next.x = min(Metrics.sourceSize, max(0, first.x + cos(angle) * 68))
            next.y = min(Metrics.sourceSize, max(0, first.y + sin(angle) * 68))
            next.color = color(at: CGPoint(x: next.x, y: next.y))
            return next
        }
    }

    func apply(_ swatch: ZenPaletteSwatch) {
        value.dots = swatch.dots
    }

    func addCustomColor() {
        let color = ZenThemeColor(
            red: customColor.red,
            green: customColor.green,
            blue: customColor.blue,
            alpha: min(1, max(0, customOpacity))
        )
        value.customColors.append(color)
        value.dots = [ZenThemeColorDot(color: color, x: 180, y: 180)]
    }

    /// Produces a soft browser-theme color from a source-space point for user-added or dragged dots.
    func color(at point: CGPoint) -> ZenThemeColor {
        let hue = max(0, min(1, Double(point.x / Metrics.sourceSize)))
        let saturation = max(0.18, min(0.82, Double(point.y / Metrics.sourceSize)))
        let lightness = value.scheme == .dark ? 0.42 : 0.68
        return ZenThemeColor(hue: hue, saturation: saturation, lightness: lightness)
    }
}

private extension ZenThemeColor {
    init(nsColor: NSColor) {
        let rgb = nsColor.usingColorSpace(.sRGB) ?? nsColor
        self.init(
            red: Double(rgb.redComponent),
            green: Double(rgb.greenComponent),
            blue: Double(rgb.blueComponent),
            alpha: Double(rgb.alphaComponent)
        )
    }

    init(hue: Double, saturation: Double, lightness: Double) {
        let c = (1 - abs(2 * lightness - 1)) * saturation
        let x = c * (1 - abs((hue * 6).truncatingRemainder(dividingBy: 2) - 1))
        let m = lightness - c / 2

        let rgb: (Double, Double, Double)
        switch hue * 6 {
        case 0..<1: rgb = (c, x, 0)
        case 1..<2: rgb = (x, c, 0)
        case 2..<3: rgb = (0, c, x)
        case 3..<4: rgb = (0, x, c)
        case 4..<5: rgb = (x, 0, c)
        default: rgb = (c, 0, x)
        }

        self.init(red: rgb.0 + m, green: rgb.1 + m, blue: rgb.2 + m)
    }
}

private struct ZenDottedWell: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.primary.opacity(0.045)))

            for x in stride(from: CGFloat(-17), through: size.width, by: 7) {
                for y in stride(from: CGFloat(-17), through: size.height, by: 7) {
                    let dot = CGRect(x: x, y: y, width: 0.95, height: 0.95)
                    context.fill(Path(ellipseIn: dot), with: .color(.primary.opacity(0.09)))
                }
            }
        }
    }
}

private struct ZenOpacityWaveSlider: View {
    @Binding var value: Double

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let range = 0.28...0.88
            let progress = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
            let knobX = width * progress

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.primary.opacity(0.08))
                    .frame(height: 18)
                    .padding(.leading, 8)

                WaveLine()
                    .trim(from: 0, to: max(0.001, progress))
                    .stroke(
                        LinearGradient(colors: [.primary.opacity(0.78), .primary.opacity(0.34)], startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round)
                    )
                    .frame(height: 30)
                    .padding(.horizontal, 10)

                Circle()
                    .fill(Color.primary)
                    .frame(width: 18, height: 18)
                    .position(x: knobX, y: proxy.size.height / 2)
                    .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let clamped = min(width, max(0, gesture.location.x))
                        value = range.lowerBound + (clamped / width) * (range.upperBound - range.lowerBound)
                    }
            )
        }
    }
}

private struct WaveLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 6, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - 6, y: rect.midY))
        return path
    }
}

private struct ZenPaletteSwatch: Identifiable {
    var id = UUID()
    var label: String
    var colors: [ZenThemeColor]
    var dots: [ZenThemeColorDot]
}

private struct ZenPaletteSwatchView: View {
    let swatch: ZenPaletteSwatch

    var body: some View {
        Circle()
            .fill(baseFill)
            .overlay {
                if swatch.colors.count >= 3 {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [swatch.colors[0].color, .clear],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 26
                            )
                        )
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [swatch.colors[1].color, .clear],
                                center: .topTrailing,
                                startRadius: 0,
                                endRadius: 26
                            )
                        )
                }
            }
            .overlay {
                Circle().strokeBorder(.black.opacity(0.12), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.1), radius: 1)
            .scaleEffect(1)
            .contentShape(Circle())
    }

    private var baseFill: AnyShapeStyle {
        if swatch.colors.count >= 3 {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [swatch.colors[2].color, .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }

        return AnyShapeStyle(swatch.colors.first?.color ?? .clear)
    }
}

private extension ZenThemeColorPicker {
    static let palettePages: [[ZenPaletteSwatch]] = [
        [
            swatch("Porcelain", [0xF2E9D1], position: (226, 232)),
            swatch("Blush", [0xEFA8BD], position: (218, 146)),
            swatch("Orchid mist", [0xDDB1E4], position: (210, 102)),
            swatch("Peony", [0xD86F89], position: (225, 166)),
            swatch("Melon", [0xEF7B67], position: (205, 191)),
            swatch("Hay", [0xD9CA68], position: (238, 227)),
            swatch("Seafoam", [0x66E5A6], position: (138, 205)),
            swatch("Periwinkle", [0x8897B8], position: (76, 92))
        ],
        [
            swatch("Pearl blend", [0xF3E6C8, 0xD9EECF, 0xEFD4DD], position: (222, 232)),
            swatch("Sorbet blend", [0xF1B1D0, 0xF6D4AE, 0xD5BAEA], position: (216, 149)),
            swatch("Violet blend", [0xD9A9DF, 0xEB9FAE, 0xBEB5DD], position: (208, 105)),
            swatch("Festival blend", [0xE77497, 0xE7E96C, 0xC879DA], position: (228, 164)),
            swatch("Bloom blend", [0xEE6D76, 0xA8E86C, 0xDF76E6], position: (203, 188)),
            swatch("Field blend", [0xD5C64A, 0x6DCA5F, 0xCF5677], position: (235, 228)),
            swatch("Lagoon blend", [0x53DFC9, 0x5AA7D9, 0x54EA78], position: (139, 203)),
            swatch("Cloud blend", [0x7280A1, 0x8970A9, 0x71A1A5], position: (78, 91))
        ],
        [
            swatch("Fig", [0x5F526D], position: (164, 76)),
            swatch("Mulberry", [0x9A6A91], position: (252, 86)),
            swatch("Merlot", [0x965963], position: (289, 168)),
            swatch("Terracotta", [0xA6613C], position: (227, 205)),
            swatch("Sage", [0x4E7966], position: (88, 218)),
            swatch("Harbor", [0x506A72], position: (64, 151)),
            swatch("Umber", [0x846655], position: (302, 226)),
            swatch("Juniper", [0x3F705F], position: (114, 208))
        ],
        [
            swatch("Nightfall blend", [0x181323, 0x2B1730, 0x141A27], position: (162, 78)),
            swatch("Plum blend", [0x7B4974, 0x88464C, 0x5D5778], position: (251, 86)),
            swatch("Cask blend", [0x78353E, 0x777735, 0x6A416D], position: (286, 170)),
            swatch("Ember blend", [0x81401D, 0x477928, 0x742855], position: (226, 206)),
            swatch("Moss blend", [0x2D6652, 0x355966, 0x3F7132], position: (89, 218)),
            swatch("Tide blend", [0x2F4851, 0x333756, 0x2E5D45], position: (65, 151)),
            swatch("Bark blend", [0x423126, 0x3F452D, 0x46313A], position: (300, 224)),
            swatch("Cedar blend", [0x1E563F, 0x20485C, 0x2B641F], position: (113, 207))
        ],
        [
            swatch("Mist", [0xECECEC], position: (322, 168)),
            swatch("Pale stone", [0xD4D4D4], position: (303, 170)),
            swatch("Silver ash", [0xBABABA], position: (284, 172)),
            swatch("Nickel", [0x9D9D9D], position: (265, 174)),
            swatch("Smoke", [0x7D7D7D], position: (246, 176)),
            swatch("Graphite", [0x5D5D5D], position: (227, 178)),
            swatch("Charcoal", [0x3D3D3D], position: (208, 180)),
            swatch("Ink", [0x1C1C1C], position: (189, 182))
        ]
    ]

    static func swatch(_ label: String, _ hexes: [UInt32], position: (Double, Double)) -> ZenPaletteSwatch {
        let colors = hexes.map { ZenThemeColor(hex: $0) }
        let dots = colors.enumerated().map { index, color in
            let angle = Double(index) * 2.1
            let radius = Double(index) * 21
            return ZenThemeColorDot(
                color: color,
                x: position.0 + cos(angle) * radius,
                y: position.1 + sin(angle) * radius
            )
        }

        return ZenPaletteSwatch(label: label, colors: colors, dots: dots)
    }
}
