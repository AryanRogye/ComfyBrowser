//
//  ComfyBrowserRoot.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//


import SwiftUI

struct ComfyBrowserRoot: View {
    
    @Environment(ComfyBrowserViewModel.self) var comfyBrowserViewModel
    @Environment(BrowserCoordinator.self) var browserController

    var backgroundColor: some ShapeStyle {
            LinearGradient(
                colors: [.red.opacity(0.5), .red.opacity(0.7), .pink.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
    }

    var body: some View {
        @Bindable var comfyBrowserViewModel = comfyBrowserViewModel
        
        let shouldShowSidebar: Binding<Bool> = Binding(
            /// If Sidebar is Closed, we should hide the sidebar
            get: { comfyBrowserViewModel.sidebarState == .closed },
            set: { _ in }
        )
        let shouldShowContent = Binding(
            /// If Sidebar is Closed, we should hide the sidebar
            get: { comfyBrowserViewModel.sidebarState != .closed },
            set: { _ in }
        )
        let shouldShowSidebarIconInTopBar = Binding(
            /// If Sidebar is Closed, we should hide the sidebar
            get: { comfyBrowserViewModel.sidebarState == .closed },
            set: { _ in }
        )
        
        ZStack {
            
            /// Background
            Rectangle()
                .fill(backgroundColor)
                .ignoresSafeArea()

            /// Main Content
            HStack(spacing: 6) {
                Sidebar(
                    browserController: browserController
                )
                
                VStack(spacing: 0) {
                    TopBar(
                        shouldShowSidebarIcon: shouldShowSidebarIconInTopBar,
                        sidebarIcon: { sidebarIcon }
                    )
                    
                    WebView()
                        .clipShape(
                            .rect(
                                bottomLeadingRadius: 8,
                                bottomTrailingRadius: 8
                            )
                        )
                }
            }
            .padding(6)
        }
        .ignoresSafeArea(edges: .top)
        .animation(.snappy(duration: 0.2), value: comfyBrowserViewModel.sidebarState)
        .windowTitlebarArea(
            shouldShowContent: shouldShowContent,
            shouldHideTrafficLights: shouldShowSidebar,
            content: {
                sidebarIcon
            }
        )
    }
    
    private var sidebarIcon: some View {
        SidebarIcon(action: comfyBrowserViewModel.toggleSidebarOpenClose)
    }
}

#Preview {
    @Previewable @State  var browserController = BrowserCoordinator()
    @Previewable @State  var comfyBrowserState = ComfyBrowserViewModel()

    ComfyBrowserRoot()
        .environment(browserController)
        .environment(comfyBrowserState)
        .padding()
        .frame(width: 600, height: 600)
}
