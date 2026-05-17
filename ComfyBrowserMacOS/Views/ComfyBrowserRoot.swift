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
                
                rightContent
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
    
    // MARK: - Right Content
    private var rightContent: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                /// Keeps `WebView` below the top bar without making the popup
                /// part of the normal VStack layout.
                Color.clear
                    .frame(height: 40)
                
                WebView()
                    .clipShape(
                        .rect(
                            bottomLeadingRadius: 8,
                            bottomTrailingRadius: 8
                        )
                    )
            }
            
            if isSearchOverlayVisible {
                dismissSearchOverlayLayer
                    .zIndex(9)
                
                searchOverlay
                    .zIndex(10)
            }
            
            topBar
                .zIndex(11)
        }
    }
    
    // MARK: - TopBar
    private var topBar: some View {
        let shouldShowSidebarIconInTopBar = Binding(
            /// If Sidebar is Closed, we should hide the sidebar
            get: { comfyBrowserViewModel.sidebarState == .closed },
            set: { _ in }
        )
        
        return TopBar(
            faviconService: browserCoordinator.faviconService,
            searchEngine: browserCoordinator.searchEngine,
            shouldShowSidebarIcon: shouldShowSidebarIconInTopBar,
            sidebarIcon: { sidebarIcon },
            onSearch: { searchTerm in
                browserCoordinator.search(searchTerm)
            },
            searching: { searchTerm in
                return browserCoordinator.searching(searchTerm)
            },
            isSearchOverlayVisible: $isSearchOverlayVisible,
            isSearchFieldFocused: $isSearchFieldFocused,
            search: $search,
            searchSuggestions: $searchSuggestions
        )
    }
    
    // MARK: - Search Overlay
    private var dismissSearchOverlayLayer: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                isSearchOverlayVisible = false
                isSearchFieldFocused = false
            }
    }
    
    private var searchOverlay: some View {
        FocusedSearchOverlay {
            SearchSuggestionsList(
                faviconService: browserCoordinator.faviconService,
                suggestions: searchSuggestions,
                onHighlight: { _ in },
                onSelect: { suggestion in
                    browserCoordinator.openSuggestion(suggestion)
                    isSearchOverlayVisible = false
                    isSearchFieldFocused = false
                }
            )
        }
        .padding(.leading, searchOverlayLeadingPadding)
        .padding(.trailing, 10)
    }
    
    /// Matches the search field's leading edge inside `TopBar`.
    ///
    /// Example:
    ///     When the sidebar is closed, the top bar also shows the sidebar
    ///     button, so the popup starts after that button and the HStack spacing.
    private var searchOverlayLeadingPadding: CGFloat {
        if comfyBrowserViewModel.sidebarState == .closed {
            return 45
        }
        
        return 10
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
