//
//  AnimatedFolderIcon.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/19/26.
//

import SwiftUI

struct AnimatedFolderIcon: View {

    @Binding var isOpen: Bool
    let isHovered: Bool

    private var openAmount: CGFloat {
        isOpen ? 1 : 0
    }

    private var tint: Color {
        Color(red: 0.20, green: 0.18, blue: 0.95)
            .opacity(isHovered ? 1 : 0.88)
    }

    var body: some View {
        MorphingFolderShape(openAmount: openAmount)
            .fill(tint)
            .drawingGroup()
            .scaleEffect(1.06)
            .animation(.interpolatingSpring(stiffness: 520, damping: 34), value: isOpen)
            .animation(.easeOut(duration: 0.12), value: isHovered)
    }
}

/// This was only possible by https://svg-to-swiftui.quassum.com/
/// Helped me move my SVG's into this then generate Shape
/// Then I had Codex lerp between
private struct MorphingFolderShape: Shape {

    var openAmount: CGFloat

    nonisolated var animatableData: CGFloat {
        get { openAmount }
        set { openAmount = newValue }
    }

    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        var strokePath = Path()
        let p = FolderPathInterpolator(rect: rect, openAmount: openAmount)

        strokePath.move(to: p.point(closed: .init(x: 0.96667, y: 0.25472), open: .init(x: 0.64399, y: 0.26238)))
        strokePath.addCurve(
            to: p.point(closed: .init(x: 0.96667, y: 0.23113), open: .init(x: 0.57971, y: 0.17327)),
            control1: p.point(closed: .init(x: 0.96667, y: 0.24600), open: .init(x: 0.64399, y: 0.21316)),
            control2: p.point(closed: .init(x: 0.96667, y: 0.23600), open: .init(x: 0.61521, y: 0.17327))
        )
        strokePath.addLine(to: p.point(closed: .init(x: 0.86190, y: 0.12736), open: .init(x: 0.43553, y: 0.17327)))
        strokePath.addCurve(
            to: p.point(closed: .init(x: 0.55000, y: 0.12736), open: .init(x: 0.37397, y: 0.13203)),
            control1: p.point(closed: .init(x: 0.81000, y: 0.12736), open: .init(x: 0.41155, y: 0.17327)),
            control2: p.point(closed: .init(x: 0.64000, y: 0.12736), open: .init(x: 0.38888, y: 0.15808))
        )
        strokePath.addLine(to: p.point(closed: .init(x: 0.50000, y: 0.07783), open: .init(x: 0.33902, y: 0.07094)))
        strokePath.addCurve(
            to: p.point(closed: .init(x: 0.45000, y: 0.02830), open: .init(x: 0.27746, y: 0.02970)),
            control1: p.point(closed: .init(x: 0.50000, y: 0.05048), open: .init(x: 0.32411, y: 0.04489)),
            control2: p.point(closed: .init(x: 0.47761, y: 0.02830), open: .init(x: 0.30144, y: 0.02970))
        )
        strokePath.addLine(to: p.point(closed: .init(x: 0.13333, y: 0.02830), open: .init(x: 0.10009, y: 0.02970)))
        strokePath.addCurve(
            to: p.point(closed: .init(x: 0.02857, y: 0.13208), open: .init(x: 0.02649, y: 0.17674)),
            control1: p.point(closed: .init(x: 0.07547, y: 0.02830), open: .init(x: 0.04527, y: 0.02970)),
            control2: p.point(closed: .init(x: 0.02857, y: 0.07476), open: .init(x: 0.00730, y: 0.10556))
        )
        strokePath.addLine(to: p.point(closed: .init(x: 0.02857, y: 0.86792), open: .init(x: 0.24042, y: 0.97030)))
        strokePath.addLine(to: p.point(closed: .init(x: 0.13333, y: 0.97170), open: .init(x: 0.78034, y: 0.97030)))
        strokePath.addCurve(
            to: p.point(closed: .init(x: 0.86190, y: 0.97170), open: .init(x: 0.85484, y: 0.89604)),
            control1: p.point(closed: .init(x: 0.30000, y: 0.97170), open: .init(x: 0.81411, y: 0.97030)),
            control2: p.point(closed: .init(x: 0.70000, y: 0.97170), open: .init(x: 0.84409, y: 0.94040))
        )
        strokePath.addLine(to: p.point(closed: .init(x: 0.96667, y: 0.86792), open: .init(x: 0.97351, y: 0.40594)))
        strokePath.addCurve(
            to: p.point(closed: .init(x: 0.96667, y: 0.25472), open: .init(x: 0.89903, y: 0.26238)),
            control1: p.point(closed: .init(x: 0.96667, y: 0.70000), open: .init(x: 0.99060, y: 0.33538)),
            control2: p.point(closed: .init(x: 0.96667, y: 0.42000), open: .init(x: 0.95273, y: 0.26238))
        )
        strokePath.addLine(to: p.point(closed: .init(x: 0.96667, y: 0.25472), open: .init(x: 0.64399, y: 0.26238)))
        strokePath.closeSubpath()

        strokePath.move(to: p.point(closed: .init(x: 0.02857, y: 0.25472), open: .init(x: 0.24042, y: 0.97030)))
        strokePath.addLine(to: p.point(closed: .init(x: 0.35000, y: 0.25472), open: .init(x: 0.38050, y: 0.33926)))
        strokePath.addCurve(
            to: p.point(closed: .init(x: 0.65000, y: 0.25472), open: .init(x: 0.45560, y: 0.26238)),
            control1: p.point(closed: .init(x: 0.45000, y: 0.25472), open: .init(x: 0.39064, y: 0.29356)),
            control2: p.point(closed: .init(x: 0.55000, y: 0.25472), open: .init(x: 0.42110, y: 0.26238))
        )
        strokePath.addLine(to: p.point(closed: .init(x: 0.96667, y: 0.25472), open: .init(x: 0.64399, y: 0.26238)))

        let strokeWidth = (0.05714 + ((0.05200 - 0.05714) * openAmount)) * rect.width
        path.addPath(strokePath.strokedPath(StrokeStyle(
            lineWidth: strokeWidth,
            lineCap: .round,
            lineJoin: .round,
            miterLimit: 4
        )))

        return path
    }
}

private struct FolderPathInterpolator {
    let rect: CGRect
    let openAmount: CGFloat

    nonisolated func point(closed: FolderUnitPoint, open: FolderUnitPoint) -> CGPoint {
        CGPoint(
            x: rect.minX + (interpolate(closed.x, open.x) * rect.width),
            y: rect.minY + (interpolate(closed.y, open.y) * rect.height)
        )
    }

    nonisolated private func interpolate(_ closed: CGFloat, _ open: CGFloat) -> CGFloat {
        closed + ((open - closed) * openAmount)
    }
}

private struct FolderUnitPoint {
    let x: CGFloat
    let y: CGFloat
}
