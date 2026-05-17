//
//  View+readFrame.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/17/26.
//

import SwiftUI

extension View {
    func readFrame(into frame: Binding<CGRect>, in coordinateSpace: String) -> some View {
        modifier(FrameReader(frame: frame, coordinateSpaceName: coordinateSpace))
    }
}

private struct FrameReader: ViewModifier {

    @Binding var frame: CGRect
    let coordinateSpaceName: String

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            frame = proxy.frame(
                                in: .named(coordinateSpaceName)
                            )
                        }
                        .onChange(of: proxy.size) {
                            frame = proxy.frame(
                                in: .named(coordinateSpaceName)
                            )
                        }
                }
            )
    }
}
