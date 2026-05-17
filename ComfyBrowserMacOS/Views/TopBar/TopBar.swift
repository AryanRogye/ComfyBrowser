//
//  TopBar.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import SwiftUI

struct TopBar<SidebarIcon: View>: View {
    
    @Bindable var faviconService: FaviconService
    let searchEngine: SearchEngine
    @Binding var shouldShowSidebarIcon: Bool
    @ViewBuilder var sidebarIcon: SidebarIcon
    var onSearch: (String) -> Void
    var searching: (String) -> [SearchSuggestion]
    @Binding var isSearchOverlayVisible: Bool
    @Binding var isSearchFieldFocused: Bool
    @Binding var search: String
    @Binding var searchSuggestions: [SearchSuggestion]
    
    /// Background Shape Of TopBar
    let background = UnevenRoundedRectangle(
        topLeadingRadius: 8,
        bottomLeadingRadius: 0,
        bottomTrailingRadius: 0,
        topTrailingRadius: 8
    )
    
    /// Padding Around
    var inset : CGFloat {
        10
    }
    
    /// Height
    var height: CGFloat {
        40
    }
    
    /// Top bar material while the search popup is closed.
    ///
    /// Example:
    ///     When the popup is open, `FocusedSearchOverlay` provides the white
    ///     surface behind the text field, so this background becomes clear.
    var backgroundFill: AnyShapeStyle {
        if isSearchOverlayVisible {
            return AnyShapeStyle(.clear)
        }
        
        return AnyShapeStyle(.regularMaterial)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            topBar
                .padding(.horizontal, inset)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background {
                    background
                        .fill(backgroundFill)
                }
                .contentShape(Rectangle())
                .zIndex(1)
        }
        .frame(maxWidth: .infinity)
        .frame(
            height: height,
            alignment: .topLeading
        )
        .animation(
            .snappy(duration: 0.2),
            value: shouldShowSidebarIcon
        )
        .animation(
            .snappy(duration: 0.2),
            value: isSearchOverlayVisible
        )
    }
    
    /// MARK: - Top Bar
    private var topBar: some View {
        HStack {
            /// Sidebar Icon
            if shouldShowSidebarIcon {
                sidebarIcon
            }
            
            /// Container For Search
            /// This is seperate so that it shows up
            /// as "another" container
            searchContainer
        }
    }
    
    

    private var searchContainer: some View {
        ZStack(alignment: .topLeading) {
            HStack {
                textfield
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40, alignment: .topLeading)
    }
    
    private var textfield: some View {
        HStack(alignment: .center) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.black)
            
            ComfyTextField(
                placeholder: "Search with \(searchEngine.rawValue) or enter address",
                text: $search,
                isFocused: $isSearchFieldFocused,
                selectAllOnFocus: true,
                onSubmit: {
                    if search.isEmpty { return }
                    onSearch(search)
                    isSearchOverlayVisible = false
                    isSearchFieldFocused = false
                },
                onFocusRequest: {
                    isSearchOverlayVisible = true
                    searchSuggestions = searching(search)
                },
                onFocusChange: { newValue in
                    if !newValue {
                        return
                    }
                    isSearchOverlayVisible = true
                    searchSuggestions = searching(search)
                },
                onTextChange: { newValue in
                    searchSuggestions = searching(newValue)
                }
            )
        }
        .padding(.leading)
        .frame(height: 40)
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                isSearchOverlayVisible = true
                isSearchFieldFocused = true
            }
        )
        .animation(.snappy(duration: 0.2), value: isSearchOverlayVisible)
    }
}

#Preview {
    
    @Previewable @State var comfyBrowserViewModel = ComfyBrowserViewModel()
    @Previewable @State var browserCoordinator = BrowserCoordinator()
    
    VStack {
        TopBar(
            faviconService: browserCoordinator.faviconService,
            searchEngine: .duckDuckGo,
            shouldShowSidebarIcon: .constant(true),
            sidebarIcon: {
                SidebarIcon(action: comfyBrowserViewModel.toggleSidebarOpenClose)
            },
            onSearch: { searchTerm in
                browserCoordinator.search(searchTerm)
            },
            searching: { searchTerm in
                browserCoordinator.searching(searchTerm)
            },
            isSearchOverlayVisible: .constant(false),
            isSearchFieldFocused: .constant(false),
            search: .constant(""),
            searchSuggestions: .constant([])
        )
        .padding()
    }
    .frame(width: 400, height: 500)
}
