//
//  BrowserContentView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/17/26.
//

import SwiftUI

struct BrowserContentView<SidebarIcon: View>: View {
    
    @Environment(ComfyBrowserViewModel.self) var comfyBrowserViewModel
    @Environment(BrowserCoordinator.self) var browserCoordinator
    
    @ViewBuilder var sidebarIcon: () -> SidebarIcon

    @State private var isSearchOverlayVisible: Bool = false
    @State private var isSearchFieldFocused: Bool = false
    @State private var search: String = ""
    @State private var searchSuggestions: [SearchSuggestion] = []
    
    
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
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            browserSurfaceShadow
            
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

            topBarContent

            centerSearchOverlay
        }
    }
    
    // MARK: - Browser Surface Shadow
    private var browserSurfaceShadow: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.white)
            .shadow(
                color: .black.opacity(0.6),
                radius: 20,
                x: -3,
                y: 3
            )
            .allowsHitTesting(false)
    }
    
    // MARK: - TopBar
    @ViewBuilder
    private var topBarContent: some View {
        if isSearchOverlayVisible {
            /// tap to dismiss
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    isSearchOverlayVisible = false
                    isSearchFieldFocused = false
                }
                .zIndex(9)
            
            searchOverlay
                .zIndex(10)
        }
        
        /// this is always pushed to the top, keeping highest z ordering
        topBar
            .zIndex(11)
    }
    
    private var topBar: some View {
        let shouldShowSidebarIconInTopBar = Binding(
            /// If Sidebar is Closed, we should hide the sidebar
            get: { comfyBrowserViewModel.sidebarState == .closed },
            set: { _ in }
        )
        
        return TopBar(
            searchEngine: browserCoordinator.searchEngine,
            shouldShowSidebarIcon: shouldShowSidebarIconInTopBar,
            isSearchOverlayVisible: $isSearchOverlayVisible,
            isSearchFieldFocused: $isSearchFieldFocused,
            search: $search,
            searchSuggestions: $searchSuggestions,
            sidebarIcon: sidebarIcon,
            onSearch: { searchTerm in
                browserCoordinator.search(searchTerm, inPlace: true)
            },
            searching: { searchTerm in
                return browserCoordinator.searching(searchTerm)
            },
        )
    }

    // MARK: - Search Overlay
    private var searchOverlay: some View {
        FloatingOverlayPanel {
            SearchSuggestionsList(
                faviconService: browserCoordinator.faviconService,
                suggestions: searchSuggestions,
                onSelect: selectSuggestionReplace
            )
        }
        .padding(.leading, searchOverlayLeadingPadding)
        .padding(.trailing, 10)
    }
    
    // MARK: - Center Search Overlay
    @ViewBuilder
    private var centerSearchOverlay: some View {
        @Bindable var comfyBrowserVM = comfyBrowserViewModel
        VStack {
            NewTabSearchPanel(
                isShowing: $comfyBrowserVM.isShowingNewTabSearch,
                faviconService: browserCoordinator.faviconService,
                searchEngine: browserCoordinator.searchEngine,
                onSearch: { searchTerm in
                    comfyBrowserVM.isShowingNewTabSearch = false
                    browserCoordinator.search(searchTerm)
                },
                searching: browserCoordinator.searching,
                selectSuggestion: selectSuggestionNew
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal)
    }
    
    private func selectSuggestionReplace(_ suggestion: SearchSuggestion) {
        browserCoordinator.openSuggestionInPlace(suggestion)
        isSearchOverlayVisible = false
        isSearchFieldFocused = false
    }
    
    private func selectSuggestionNew(_ suggestion: SearchSuggestion) {
        browserCoordinator.openSuggestion(suggestion)
        comfyBrowserViewModel.isShowingNewTabSearch = false
    }
}
