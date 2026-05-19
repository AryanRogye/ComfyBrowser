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
    /// Stroke thickness as a fraction of the icon width.
    var lineWidthRatio: CGFloat = 0.09357

    private var openAmount: CGFloat {
        isOpen ? 1 : 0
    }

    private var tint: Color {
        Color(red: 0.20, green: 0.18, blue: 0.95)
            .opacity(isHovered ? 1 : 0.88)
    }

    var body: some View {
        MorphingFolderShape(
            openAmount: openAmount,
            lineWidthRatio: lineWidthRatio
        )
        .fill(tint)
        .scaleEffect(0.95)
        .drawingGroup()
        .animation(.interpolatingSpring(stiffness: 520, damping: 34), value: isOpen)
        .animation(.easeOut(duration: 0.12), value: isHovered)
    }
}

/// This was only possible by https://svg-to-swiftui.quassum.com/
/// Helped me move my SVG's into this then generate Shape
/// Then I had Codex lerp between
private struct MorphingFolderShape: Shape {

    var openAmount: CGFloat
    var lineWidthRatio: CGFloat

    nonisolated var animatableData: CGFloat {
        get { openAmount }
        set { openAmount = newValue }
    }

    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        var strokePath = Path()
        strokePath.addMorphingCommands(
            closed: closedCommands,
            open: openCommands,
            in: rect,
            openAmount: openAmount
        )

        let openLineWidthRatio = lineWidthRatio * (0.05200 / 0.05714)
        let strokeWidth = (lineWidthRatio + ((openLineWidthRatio - lineWidthRatio) * openAmount)) * rect.width
        path.addPath(strokePath.strokedPath(StrokeStyle(
            lineWidth: strokeWidth,
            lineCap: .round,
            lineJoin: .round,
            miterLimit: 4
        )))

        return path
    }

    nonisolated private var closedCommands: [FolderPathCommand] {
        [
            .move(.init(x: 0.96667, y: 0.35377)),
            .curve(
                to: .init(x: 0.96667, y: 0.23113),
                control1: .init(x: 0.96667, y: 0.32000),
                control2: .init(x: 0.96667, y: 0.26000)
            ),
            .line(.init(x: 0.86190, y: 0.12736)),
            .curve(
                to: .init(x: 0.55000, y: 0.12736),
                control1: .init(x: 0.81000, y: 0.12736),
                control2: .init(x: 0.64000, y: 0.12736)
            ),
            .line(.init(x: 0.50000, y: 0.07783)),
            .curve(
                to: .init(x: 0.45000, y: 0.02830),
                control1: .init(x: 0.50000, y: 0.05048),
                control2: .init(x: 0.47761, y: 0.02830)
            ),
            .line(.init(x: 0.13333, y: 0.02830)),
            .curve(
                to: .init(x: 0.02857, y: 0.13208),
                control1: .init(x: 0.07547, y: 0.02830),
                control2: .init(x: 0.02857, y: 0.07476)
            ),
            .line(.init(x: 0.02857, y: 0.86792)),
            .line(.init(x: 0.13333, y: 0.97170)),
            .curve(
                to: .init(x: 0.86190, y: 0.97170),
                control1: .init(x: 0.30000, y: 0.97170),
                control2: .init(x: 0.70000, y: 0.97170)
            ),
            .line(.init(x: 0.96667, y: 0.86792)),
            .curve(
                to: .init(x: 0.96667, y: 0.35377),
                control1: .init(x: 0.96667, y: 0.70000),
                control2: .init(x: 0.96667, y: 0.50000)
            ),
            .line(.init(x: 0.96667, y: 0.35377)),
            .close,

                .move(.init(x: 0.02857, y: 0.35377)),
            .line(.init(x: 0.35000, y: 0.35377)),
            .curve(
                to: .init(x: 0.65000, y: 0.35377),
                control1: .init(x: 0.45000, y: 0.35377),
                control2: .init(x: 0.55000, y: 0.35377)
            ),
            .line(.init(x: 0.96667, y: 0.35377))
        ]
    }

    nonisolated private var openCommands: [FolderPathCommand] {
        [
            .move(.init(x: 0.64399, y: 0.26238)),
            .curve(
                to: .init(x: 0.57971, y: 0.17327),
                control1: .init(x: 0.64399, y: 0.21316),
                control2: .init(x: 0.61521, y: 0.17327)
            ),
            .line(.init(x: 0.43553, y: 0.17327)),
            .curve(
                to: .init(x: 0.37397, y: 0.13203),
                control1: .init(x: 0.41155, y: 0.17327),
                control2: .init(x: 0.38888, y: 0.15808)
            ),
            .line(.init(x: 0.33902, y: 0.07094)),
            .curve(
                to: .init(x: 0.27746, y: 0.02970),
                control1: .init(x: 0.32411, y: 0.04489),
                control2: .init(x: 0.30144, y: 0.02970)
            ),
            .line(.init(x: 0.10009, y: 0.02970)),
            .curve(
                to: .init(x: 0.02649, y: 0.17674),
                control1: .init(x: 0.04527, y: 0.02970),
                control2: .init(x: 0.00730, y: 0.10556)
            ),
            .line(.init(x: 0.24042, y: 0.97030)),
            .line(.init(x: 0.78034, y: 0.97030)),
            .curve(
                to: .init(x: 0.85484, y: 0.89604),
                control1: .init(x: 0.81411, y: 0.97030),
                control2: .init(x: 0.84409, y: 0.94040)
            ),
            .line(.init(x: 0.97351, y: 0.40594)),
            .curve(
                to: .init(x: 0.89903, y: 0.26238),
                control1: .init(x: 0.99060, y: 0.33538),
                control2: .init(x: 0.95273, y: 0.26238)
            ),
            .line(.init(x: 0.64399, y: 0.26238)),
            .close,
            .move(.init(x: 0.24042, y: 0.97030)),
            .line(.init(x: 0.38050, y: 0.33926)),
            .curve(
                to: .init(x: 0.45560, y: 0.26238),
                control1: .init(x: 0.39064, y: 0.29356),
                control2: .init(x: 0.42110, y: 0.26238)
            ),
            .line(.init(x: 0.64399, y: 0.26238))
        ]
    }
}

private enum FolderPathCommand {
    case move(FolderUnitPoint)
    case line(FolderUnitPoint)
    case curve(to: FolderUnitPoint, control1: FolderUnitPoint, control2: FolderUnitPoint)
    case close
}

private extension Path {

    mutating nonisolated func addMorphingCommands(
        closed: [FolderPathCommand],
        open: [FolderPathCommand],
        in rect: CGRect,
        openAmount: CGFloat
    ) {
        guard closed.count == open.count else {
            addCommands(openAmount < 0.5 ? closed : open, in: rect)
            return
        }

        let p = FolderPathInterpolator(rect: rect, openAmount: openAmount)

        for (closedCommand, openCommand) in zip(closed, open) {
            switch (closedCommand, openCommand) {
            case let (.move(closedPoint), .move(openPoint)):
                move(to: p.point(closed: closedPoint, open: openPoint))
            case let (.line(closedPoint), .line(openPoint)):
                addLine(to: p.point(closed: closedPoint, open: openPoint))
            case let (
                .curve(closedPoint, closedControl1, closedControl2),
                .curve(openPoint, openControl1, openControl2)
            ):
                addCurve(
                    to: p.point(closed: closedPoint, open: openPoint),
                    control1: p.point(closed: closedControl1, open: openControl1),
                    control2: p.point(closed: closedControl2, open: openControl2)
                )
            case (.close, .close):
                closeSubpath()
            default:
                addCommands(openAmount < 0.5 ? closed : open, in: rect)
                return
            }
        }
    }

    mutating nonisolated private func addCommands(_ commands: [FolderPathCommand], in rect: CGRect) {
        for command in commands {
            switch command {
            case let .move(point):
                move(to: point.cgPoint(in: rect))
            case let .line(point):
                addLine(to: point.cgPoint(in: rect))
            case let .curve(point, control1, control2):
                addCurve(
                    to: point.cgPoint(in: rect),
                    control1: control1.cgPoint(in: rect),
                    control2: control2.cgPoint(in: rect)
                )
            case .close:
                closeSubpath()
            }
        }
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

    nonisolated func cgPoint(in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + (x * rect.width),
            y: rect.minY + (y * rect.height)
        )
    }
}
