//
//  FocusedSearchOverlay.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import SwiftUI

/// When The Search Textfield is clicked this is the
/// background that shows up behind it
struct FocusedSearchOverlay<Content: View>: View {
    
    @ViewBuilder var content: () -> Content
    
    /// Shape of Overlay
    var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 12)
    }

    /// Overlay Stroke Color
    var strokeColor: Color {
        Color.black.opacity(0.06)
    }
    
    /// Overlay Shadow Color
    var shadowColor: Color {
        Color.black.opacity(0.14)
    }
    
    /// Overlay Height
    var overlayHeight: CGFloat {
        172
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
            .padding(.top, dividerTopPadding)
    }
}

extension FocusedSearchOverlay where Content == EmptyView {
    init() {
        self.init { EmptyView() }
    }
}
