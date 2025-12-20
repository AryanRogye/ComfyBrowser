//
//  ComfyBrowserRoot.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//


import SwiftUI

struct ComfyBrowserRoot: View {
    
    @Environment(ComfyBrowserViewModel.self) var comfyBrowserViewModel
    
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
            
            Rectangle()
                .fill(backgroundColor)
                .ignoresSafeArea()

            HStack(spacing: 6) {
                Sidebar(sidebarState: $comfyBrowserViewModel.sidebarState)
                
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

struct SidebarIcon: View {
    
    @State private var isHoveringOverSidebar = false
    var action: () -> Void
    
    var sidebarInnerColor: Color {
        return .white.opacity(
            isHoveringOverSidebar ? 0.15 : 0
        )
    }
    var sidebarOuterColor: Color {
        return .white.opacity(
            isHoveringOverSidebar ? 0.2 : 0
        )
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: "sidebar.left")
                .resizable()
                .frame(width: 21, height: 17)
                .padding(.horizontal, 3)
                .padding(.vertical, 3)
                .background {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(sidebarInnerColor)
                        .stroke(sidebarOuterColor)
                }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHoveringOverSidebar = hovering
        }
        .animation(.snappy(duration: 0.2), value: isHoveringOverSidebar)
    }
}

struct TopBar<SidebarIcon: View>: View {
    
    @Binding var shouldShowSidebarIcon: Bool
    var sidebarIcon: SidebarIcon
    
    init(
        shouldShowSidebarIcon: Binding<Bool>,
        @ViewBuilder sidebarIcon: @escaping () -> SidebarIcon
    ) {
        self._shouldShowSidebarIcon = shouldShowSidebarIcon
        self.sidebarIcon = sidebarIcon()
    }
    
    var body: some View {
        HStack {
            if shouldShowSidebarIcon {
                sidebarIcon
            }
            Spacer()
            Text("Middle")
            Spacer()
            Text("End")
        }
        .padding(.horizontal, 8)
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity, maxHeight: 40)
        .background(.regularMaterial)
        .clipShape(
            .rect(
                topLeadingRadius: 8,
                topTrailingRadius: 8
            )
        )
        .animation(.snappy(duration: 0.2), value: shouldShowSidebarIcon)
    }
}

struct Sidebar: View {
    
    @Binding var sidebarState : SidebarState
    
    var backgroundColor: some ShapeStyle {
        LinearGradient(
            colors: [.pink.opacity(0.5), .red.opacity(0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        if sidebarState == .open {
            VStack {
                Text("This is Sidebar")
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: 200, maxHeight: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .stroke(.white.opacity(0.3), style: .init(lineWidth: 1))
            }
        }
    }
}


#Preview {
    @Previewable @State  var comfyBrowserVM = BrowserViewModel()
    @Previewable @State  var comfyBrowserState = ComfyBrowserViewModel()

    ComfyBrowserRoot()
        .environment(comfyBrowserVM)
        .environment(comfyBrowserState)
        .padding()
        .frame(width: 600, height: 600)
}
