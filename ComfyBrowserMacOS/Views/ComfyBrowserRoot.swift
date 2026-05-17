//
//  ComfyBrowserRoot.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//


import SwiftUI

struct ComfyBrowserRoot: View {
    
    @Environment(ComfyBrowserViewModel.self) var comfyBrowserViewModel
    @Environment(BrowserCoordinator.self) var browserCoordinator
    
    @State private var isSearchOverlayVisible: Bool = false
    @State private var isSearchFieldFocused: Bool = false
    @State private var search: String = ""
    @State private var searchSuggestions: [SearchSuggestion] = []

    var backgroundColor: some ShapeStyle {
            LinearGradient(
                colors: [.red.opacity(0.5), .red.opacity(0.7), .pink.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            /// Background
            Rectangle()
                .fill(backgroundColor)
                .ignoresSafeArea()

            /// Main Content
            HStack(spacing: 6) {
                Sidebar(
                    browserCoordinator: browserCoordinator
                )
                
                BrowserContentView {
                    sidebarIcon
                }
            }
            .padding(6)
        }
        .ignoresSafeArea(edges: .top)
        .animation(.snappy(duration: 0.2), value: comfyBrowserViewModel.sidebarState)
        .windowTitlebarArea(
            /// show content when the sidebar is not open meaning
            /// open/floating
            shouldShowContent: Binding(
                /// If Sidebar is Closed, we should hide the sidebar
                get: { comfyBrowserViewModel.sidebarState != .closed },
                set: { _ in }
            ),
            /// hide traffic lights when sidebar is closed
            shouldHideTrafficLights: Binding(
                /// If Sidebar is Closed, we should hide the sidebar
                get: { comfyBrowserViewModel.sidebarState == .closed },
                set: { _ in }
            )
,
            content: {
                sidebarIcon
            }
        )
    }
    
    // MARK: - Sidebar Icon
    private var sidebarIcon: some View {
        SidebarIcon(action: comfyBrowserViewModel.toggleSidebarOpenClose)
    }
}

#Preview {
    @Previewable @State  var browserCoordinator = BrowserCoordinator()
    @Previewable @State  var comfyBrowserState = ComfyBrowserViewModel()

    ComfyBrowserRoot()
        .environment(browserCoordinator)
        .environment(comfyBrowserState)
        .padding()
        .frame(width: 600, height: 600)
}
