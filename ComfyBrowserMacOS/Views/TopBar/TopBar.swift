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
    var onOpenSuggestion: (SearchSuggestion) -> Void
    var searching: (String) -> [SearchSuggestion]
    
    @FocusState private var isFocused: Bool
    @State private var isSearchOverlayVisible: Bool = false
    @State private var search: String = ""
    @State private var searchSuggestions: [SearchSuggestion] = []
    
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
    
    /// when the serach overlay is visible we want it floating on top
    var containerZIndex: CGFloat {
        isSearchOverlayVisible ? 10 : 1
    }
    
    
    /// Container Holding Search Items
    /// ZIndex = 0 because it has to be held UNDER the textfield
    var searchContainerZIndex: CGFloat {
        0
    }
    
    /// Container Holding Search Items
    /// ZIndex = 1 because it has to be held ABOVE the textfield
    var textfieldContainerZIndex: CGFloat {
        1
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
                        .fill(.regularMaterial)
                }
                .contentShape(Rectangle())
                .zIndex(1)
        }
        .frame(maxWidth: .infinity)
        .frame(
            height: height,
            alignment: .topLeading
        )
        .zIndex(containerZIndex)
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
            
            /// if Focused we show a background
            if isSearchOverlayVisible {
                FocusedSearchOverlay {
                    SearchSuggestionsList(
                        suggestions: searchSuggestions,
                        onHighlight: { _ in },
                        onSelect: { suggestion in
                            self.onOpenSuggestion(suggestion)
                        }
                    )
                }
                .zIndex(searchContainerZIndex)
            }
            
            HStack {
                textfield
                Spacer()
            }
            .zIndex(textfieldContainerZIndex)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40, alignment: .topLeading)
    }
    
    private var textfield: some View {
        HStack(alignment: .center) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.black)
            
            TextField("Search with \(searchEngine.rawValue) or enter address", text: $search)
                .textFieldStyle(.plain)
                .foregroundStyle(.black)
                .onSubmit {
                    if search.isEmpty { return }
                    onSearch(search)
                    isFocused = false
                }
                .focused($isFocused)
                .onChange(of: isFocused) { _, newValue in
                    if !newValue {
                        isSearchOverlayVisible = false
                        return
                    }
                    isSearchOverlayVisible = true
                    if !isSearchOverlayVisible || search.isEmpty { return }
                    TextFieldSelectAll.selectAll()
                }
                .onChange(of: search) { _, newValue in
                    searchSuggestions = searching(search)
                    print("Search Suggestions: \(searchSuggestions.map { $0.title }.joined(separator: ", "))")
                }
        }
        .padding(.leading)
        .frame(height: 40)
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                isSearchOverlayVisible = true
                isFocused = true
            }
        )
        .animation(.snappy(duration: 0.2), value: isSearchOverlayVisible)
    }
}

/// When The Search Textfield is clicked this is the
/// background that shows up behind it
private struct FocusedSearchOverlay<Content: View>: View {
    
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
    
    var body: some View {
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
            .overlay(alignment: .top) {
                VStack {
                    divider
                    
                    content()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: overlayHeight)
            .padding(.horizontal, overlayHorizontalInset)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(.black.opacity(0.12))
            .frame(height: 1)
            .padding(.horizontal, 20)
            .padding(.top, 48)
    }
}

extension FocusedSearchOverlay where Content == EmptyView {
    init() {
        self.init { EmptyView() }
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
            onOpenSuggestion: { suggestion in
                browserCoordinator.openSuggestion(suggestion)
            },
            searching: { searchTerm in
                browserCoordinator.searching(searchTerm)
            })
        .padding()
    }
    .frame(width: 400, height: 500)
}
