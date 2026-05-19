// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

@main
struct FolderOpening: App {

    @State private var open: Bool = false

    var body: some Scene {
        WindowGroup {
            VStack {
                FolderShape(progress: open ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: open)
                    .aspectRatio(1, contentMode: .fit)
                    .onTapGesture { open.toggle() }
            }
        }
    }
}

import SwiftUI

struct OpenFolderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        var strokePath2 = Path()
        strokePath2.move(to: CGPoint(x: 0.64399*width, y: 0.26238*height))
        strokePath2.addCurve(to: CGPoint(x: 0.57971*width, y: 0.17327*height), control1: CGPoint(x: 0.64399*width, y: 0.21316*height), control2: CGPoint(x: 0.61521*width, y: 0.17327*height))
        strokePath2.addLine(to: CGPoint(x: 0.43553*width, y: 0.17327*height))
        strokePath2.addCurve(to: CGPoint(x: 0.37397*width, y: 0.13203*height), control1: CGPoint(x: 0.41155*width, y: 0.17327*height), control2: CGPoint(x: 0.38888*width, y: 0.15808*height))
        strokePath2.addLine(to: CGPoint(x: 0.33902*width, y: 0.07094*height))
        strokePath2.addCurve(to: CGPoint(x: 0.27746*width, y: 0.0297*height), control1: CGPoint(x: 0.32411*width, y: 0.04489*height), control2: CGPoint(x: 0.30144*width, y: 0.0297*height))
        strokePath2.addLine(to: CGPoint(x: 0.10009*width, y: 0.0297*height))
        strokePath2.addCurve(to: CGPoint(x: 0.02649*width, y: 0.17674*height), control1: CGPoint(x: 0.04527*width, y: 0.0297*height), control2: CGPoint(x: 0.0073*width, y: 0.10556*height))
        strokePath2.addLine(to: CGPoint(x: 0.24042*width, y: 0.9703*height))
        strokePath2.addLine(to: CGPoint(x: 0.78034*width, y: 0.9703*height))
        strokePath2.addCurve(to: CGPoint(x: 0.85484*width, y: 0.89604*height), control1: CGPoint(x: 0.81411*width, y: 0.9703*height), control2: CGPoint(x: 0.84409*width, y: 0.9404*height))
        strokePath2.addLine(to: CGPoint(x: 0.97351*width, y: 0.40594*height))
        strokePath2.addCurve(to: CGPoint(x: 0.89903*width, y: 0.26238*height), control1: CGPoint(x: 0.9906*width, y: 0.33538*height), control2: CGPoint(x: 0.95273*width, y: 0.26238*height))
        strokePath2.addLine(to: CGPoint(x: 0.64399*width, y: 0.26238*height))
        strokePath2.closeSubpath()
        strokePath2.move(to: CGPoint(x: 0.24042*width, y: 0.9703*height))
        strokePath2.addLine(to: CGPoint(x: 0.3805*width, y: 0.33926*height))
        strokePath2.addCurve(to: CGPoint(x: 0.4556*width, y: 0.26238*height), control1: CGPoint(x: 0.39064*width, y: 0.29356*height), control2: CGPoint(x: 0.4211*width, y: 0.26238*height))
        strokePath2.addLine(to: CGPoint(x: 0.64399*width, y: 0.26238*height))
        path.addPath(strokePath2.strokedPath(StrokeStyle(lineWidth: 0.04286*width, lineCap: .butt, lineJoin: .round, miterLimit: 4)))
        return path
    }
}

struct ClosedFolderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        var strokePath2 = Path()
        strokePath2.move(to: CGPoint(x: 0.96667*width, y: 0.25472*height))
        strokePath2.addLine(to: CGPoint(x: 0.96667*width, y: 0.86792*height))
        strokePath2.addCurve(to: CGPoint(x: 0.8619*width, y: 0.9717*height), control1: CGPoint(x: 0.96667*width, y: 0.92524*height), control2: CGPoint(x: 0.91976*width, y: 0.9717*height))
        strokePath2.addLine(to: CGPoint(x: 0.13333*width, y: 0.9717*height))
        strokePath2.addCurve(to: CGPoint(x: 0.02857*width, y: 0.86792*height), control1: CGPoint(x: 0.07547*width, y: 0.9717*height), control2: CGPoint(x: 0.02857*width, y: 0.92524*height))
        strokePath2.addLine(to: CGPoint(x: 0.02857*width, y: 0.25472*height))
        strokePath2.move(to: CGPoint(x: 0.96667*width, y: 0.25472*height))
        strokePath2.addLine(to: CGPoint(x: 0.02857*width, y: 0.25472*height))
        strokePath2.move(to: CGPoint(x: 0.96667*width, y: 0.25472*height))
        strokePath2.addLine(to: CGPoint(x: 0.96667*width, y: 0.23113*height))
        strokePath2.addCurve(to: CGPoint(x: 0.8619*width, y: 0.12736*height), control1: CGPoint(x: 0.96667*width, y: 0.17382*height), control2: CGPoint(x: 0.91976*width, y: 0.12736*height))
        strokePath2.addLine(to: CGPoint(x: 0.55*width, y: 0.12736*height))
        strokePath2.addCurve(to: CGPoint(x: 0.5*width, y: 0.07783*height), control1: CGPoint(x: 0.52239*width, y: 0.12736*height), control2: CGPoint(x: 0.5*width, y: 0.10518*height))
        strokePath2.addCurve(to: CGPoint(x: 0.45*width, y: 0.0283*height), control1: CGPoint(x: 0.5*width, y: 0.05048*height), control2: CGPoint(x: 0.47761*width, y: 0.0283*height))
        strokePath2.addLine(to: CGPoint(x: 0.13333*width, y: 0.0283*height))
        strokePath2.addCurve(to: CGPoint(x: 0.02857*width, y: 0.13208*height), control1: CGPoint(x: 0.07547*width, y: 0.0283*height), control2: CGPoint(x: 0.02857*width, y: 0.07476*height))
        strokePath2.addLine(to: CGPoint(x: 0.02857*width, y: 0.25472*height))
        path.addPath(strokePath2.strokedPath(StrokeStyle(lineWidth: 0.05714*width, lineCap: .butt, lineJoin: .miter, miterLimit: 4)))
        return path
    }
}


struct FolderShape: Shape {
    var progress: Double // 0 = closed, 1 = open

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let width = rect.size.width
        let height = rect.size.height

        func lerp(_ a: Double, _ b: Double) -> Double {
            a + (b - a) * progress
        }
        func pt(_ ax: Double, _ ay: Double, _ bx: Double, _ by: Double) -> CGPoint {
            CGPoint(x: lerp(ax, bx) * width, y: lerp(ay, by) * height)
        }

        var strokePath = Path()

        // --- Main body ---
        // Closed starts at top-right, open starts at inner shelf top-right
        strokePath.move(to: pt(0.96667, 0.25472, 0.64399, 0.26238))

        // Top-right curve down to body
        strokePath.addCurve(
            to: pt(0.96667, 0.86792, 0.57971, 0.17327),
            control1: pt(0.96667, 0.25472, 0.64399, 0.21316),
            control2: pt(0.96667, 0.86792, 0.61521, 0.17327)
        )

        // Right side / tab right edge
        strokePath.addCurve(
            to: pt(0.8619, 0.9717, 0.43553, 0.17327),
            control1: pt(0.96667, 0.92524, 0.64399, 0.21316),
            control2: pt(0.91976, 0.9717, 0.41155, 0.17327)
        )

        // Bottom-right
        strokePath.addLine(to: pt(0.13333, 0.9717, 0.78034, 0.9703))

        // Bottom-left curve
        strokePath.addCurve(
            to: pt(0.02857, 0.86792, 0.85484, 0.89604),
            control1: pt(0.07547, 0.9717, 0.81411, 0.9703),
            control2: pt(0.02857, 0.92524, 0.84409, 0.9404)
        )

        // Left side going up
        strokePath.addLine(to: pt(0.02857, 0.25472, 0.97351, 0.40594))

        // Back to start
        strokePath.addCurve(
            to: pt(0.96667, 0.25472, 0.89903, 0.26238),
            control1: pt(0.02857, 0.25472, 0.9906, 0.33538),
            control2: pt(0.96667, 0.25472, 0.95273, 0.26238)
        )
        strokePath.closeSubpath()

        // --- Tab / shelf separator line ---
        strokePath.move(to: pt(0.96667, 0.25472, 0.24042, 0.9703))
        strokePath.addLine(to: pt(0.02857, 0.25472, 0.3805, 0.33926))

        strokePath.addCurve(
            to: pt(0.02857, 0.25472, 0.4556, 0.26238),
            control1: pt(0.02857, 0.25472, 0.39064, 0.29356),
            control2: pt(0.02857, 0.25472, 0.4211, 0.26238)
        )
        strokePath.addLine(to: pt(0.96667, 0.25472, 0.64399, 0.26238))

        // --- Tab top (closed only, fades out) ---
        strokePath.move(to: pt(0.96667, 0.23113, 0.96667, 0.23113))
        strokePath.addCurve(
            to: pt(0.8619, 0.12736, 0.8619, 0.12736),
            control1: pt(0.96667, 0.17382, 0.96667, 0.17382),
            control2: pt(0.91976, 0.12736, 0.91976, 0.12736)
        )
        strokePath.addLine(to: pt(0.55, 0.12736, 0.55, 0.12736))
        strokePath.addCurve(
            to: pt(0.45, 0.0283, 0.45, 0.0283),
            control1: pt(0.52239, 0.12736, 0.52239, 0.12736),
            control2: pt(0.47761, 0.0283, 0.47761, 0.0283)
        )
        strokePath.addLine(to: pt(0.13333, 0.0283, 0.13333, 0.0283))
        strokePath.addCurve(
            to: pt(0.02857, 0.13208, 0.02857, 0.13208),
            control1: pt(0.07547, 0.0283, 0.07547, 0.0283),
            control2: pt(0.02857, 0.07476, 0.02857, 0.07476)
        )
        strokePath.addLine(to: pt(0.02857, 0.25472, 0.02857, 0.25472))

        let lineWidth = lerp(0.05714, 0.04286) * width

        return strokePath.strokedPath(StrokeStyle(
            lineWidth: lineWidth,
            lineCap: .round,
            lineJoin: .round,
            miterLimit: 4
        ))
    }
}

struct FolderView: View {
    @Binding var isOpen: Bool

    var body: some View {
        FolderShape(progress: isOpen ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isOpen)
            .aspectRatio(1, contentMode: .fit)
            .onTapGesture { isOpen.toggle() }
    }
}
