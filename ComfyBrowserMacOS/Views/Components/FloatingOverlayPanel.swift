//
//  FloatingOverlayPanel.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import SwiftUI

/// Floating panel used to host search and launcher overlay content.
///
/// Example:
///     `FloatingOverlayPanel { SearchSuggestionsList(...) }` renders the
///     shared white panel used by the top-bar search popup.
struct FloatingOverlayPanel<Content: View, Label: View>: View {
    
    var useDividerPadding: Bool = false
    var overlayHeight: CGFloat = 172
    @ViewBuilder var content: () -> Content
    @ViewBuilder var label: () -> Label
    
    /// Shape of Overlay
    var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 12)
    }
    
    var background : UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 8,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 8
        )
    }


    /// Overlay Stroke Color
    var strokeColor: Color {
        Color.black.opacity(0.06)
    }
    
    /// Overlay Shadow Color
    var shadowColor: Color {
        Color.black.opacity(0.14)
    }
    
    /// Padding Inset
    var overlayHorizontalInset: CGFloat {
        8
    }
    
    var dividerTopPadding: CGFloat {
        48
    }
    
    var dividerHeight: CGFloat {
        1
    }
    
    /// Height available for suggestion rows below the search divider.
    ///
    /// Example:
    ///     The overlay is 172pt tall and the divider starts 48pt down, so the
    ///     collection view gets an explicit 123pt hit-test area below it.
    var contentHeight: CGFloat {
        max(0, overlayHeight - dividerTopPadding - dividerHeight)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            shape
                .fill(.white)
                .shadow(
                    color: shadowColor,
                    radius: 16,
                    x: 0, y: 8
                )
                .overlay {
                    shape
                        .stroke(
                            strokeColor,
                            lineWidth: 1
                        )
                }
                .allowsHitTesting(false)
            
            VStack(spacing: 0) {
                
                if Label.self == EmptyView.self {
                    Color.white
                        .frame(height: dividerTopPadding)
                        .background {
                            background
                        }
                        .clipShape(background)
                } else {
                    label()
                        .frame(maxWidth: .infinity)
                }

                divider
                
                content()
                    .frame(maxWidth: .infinity)
                    .frame(height: contentHeight)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity)
        .frame(height: overlayHeight)
        .padding(.horizontal, overlayHorizontalInset)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(.black.opacity(0.12))
            .frame(height: dividerHeight)
            .padding(.horizontal, 20)
            .padding(.top, useDividerPadding ? dividerTopPadding : 0)
    }
}

extension FloatingOverlayPanel where Label == EmptyView {
    
    /// Builds the overlay when there is no custom label content.
    ///
    /// Example:
    ///     `FloatingOverlayPanel { SearchSuggestionsList(...) }` uses this
    ///     initializer and stores `EmptyView` for the unused label slot.
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.label = { EmptyView() }
    }
}

extension FloatingOverlayPanel where Content == EmptyView, Label == EmptyView {
    
    /// Builds an empty overlay shell for layout previews.
    ///
    /// Example:
    ///     `FloatingOverlayPanel()` renders the overlay background and divider
    ///     without suggestion rows.
    init() {
        self.init { EmptyView() }
    }
}
