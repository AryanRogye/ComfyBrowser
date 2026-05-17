//
//  HoverBackground.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/17/26.
//

import SwiftUI

struct HoverBackground<Content: View>: View {

    @State private var isHovering = false

    var cornerRadius: CGFloat = 6
    var innerColor: Color = .white.opacity(0.15)
    var outerColor: Color = .white.opacity(0.2)

    @ViewBuilder var content: Content

    var body: some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isHovering ? innerColor : .clear)
                    .stroke(isHovering ? outerColor : .clear)
            }
            .onHover { hovering in
                isHovering = hovering
            }
            .animation(.snappy(duration: 0.2), value: isHovering)
    }
}
