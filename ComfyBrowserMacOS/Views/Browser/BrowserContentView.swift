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

            topBar

            centerSearchOverlay
        }
        /// if searchField gets focused hide this
        .onChange(of: isSearchFieldFocused) { _, newValue in
            if newValue {
                comfyBrowserViewModel.isShowingNewTabSearch = false
            }
        }
        /// if center search is focused then hide the search bar
        .onChange(of: comfyBrowserViewModel.isShowingNewTabSearch) { _, newValue in
            if newValue {
                isSearchOverlayVisible = false
                isSearchFieldFocused = false
            }
        }
    }
    
    // MARK: - Browser Surface Shadow
    private var browserSurfaceShadow: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.white)
            .shadow(
                color: .black.opacity(0.15),
                radius: 8,
                x: -2,
                y: 2
            )
            .allowsHitTesting(false)
    }
    
    // MARK: - TopBar
    private var topBar: some View {
        @Bindable var browserCoordinator = browserCoordinator
        let shouldShowSidebarIconInTopBar = Binding(
            /// If Sidebar is Closed, we should hide the sidebar
            get: { comfyBrowserViewModel.sidebarState == .closed },
            set: { _ in }
        )
        
        return TopBar(
            searchEngine: browserCoordinator.searchEngine,
            faviconService: browserCoordinator.faviconService,
            canNavigateBack: $browserCoordinator.canNavigateBack,
            canNavigateForward: $browserCoordinator.canNavigateForward,
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
            selectSuggestionReplace: selectSuggestionReplace,
            onForward: browserCoordinator.navigateForward,
            onBack: browserCoordinator.navigateBack
        )
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
        browserCoordinator.openSuggestion(suggestion, inPlace: true)
        isSearchOverlayVisible = false
        isSearchFieldFocused = false
    }
    
    private func selectSuggestionNew(_ suggestion: SearchSuggestion) {
        browserCoordinator.openSuggestion(suggestion)
        comfyBrowserViewModel.isShowingNewTabSearch = false
    }
}
