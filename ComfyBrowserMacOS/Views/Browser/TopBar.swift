//
//  TopBar.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import SwiftUI

private struct SearchFieldFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct TopBar<SidebarIcon: View>: View {

    let searchEngine: SearchEngine
    @Bindable var faviconService: FaviconService
    @Binding var canNavigateBack: Bool
    @Binding var canNavigateForward: Bool
    @Binding var shouldShowSidebarIcon: Bool
    @Binding var isSearchOverlayVisible: Bool
    @Binding var isSearchFieldFocused: Bool
    @Binding var search: String
    @Binding var searchSuggestions: [SearchSuggestion]
    @ViewBuilder var sidebarIcon: SidebarIcon
    var onSearch: (String) -> Void
    var searching: (String) -> [SearchSuggestion]
    var selectSuggestionReplace: (SearchSuggestion) -> Void
    var onForward: () -> Void
    var onBack: () -> Void

    @State private var hoveringOverSearch: Bool = false
    @State private var hoveringOverLink: Bool = false

    @State private var searchFieldFrame: CGRect = .zero
    private let coordinateSpaceName = "TopBarSpace"

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
    ///     When the popup is open, `FloatingOverlayPanel` provides the white
    ///     surface behind the text field, so this background becomes clear.
    var backgroundFill: AnyShapeStyle {
        if isSearchOverlayVisible {
            return AnyShapeStyle(.clear)
        }

        return AnyShapeStyle(.white)
    }

    var textFieldBackground: Color {
        if isSearchFieldFocused || isSearchOverlayVisible {
            return .white
        }
        return hoveringOverSearch ? .gray.opacity(0.2) : .gray.opacity(0.1)
    }

    /// TopBar shows up in a ZStack so this will get ordered correctly
    var body: some View {
        if isSearchOverlayVisible, searchFieldFrame.width > 0 {
            /// tap to dismiss
            tapToDismissView
                .zIndex(9)

            /// suggestions show up in this container
            searchSuggestionsContainer
                .zIndex(10)
        }

        HStack {

            /// Sidebar Icon
            if shouldShowSidebarIcon {
                sidebarIcon
            }

            navigationButtons
                .padding(.horizontal)

            /// Search field
            textfield
        }
        .padding(.horizontal, inset)
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background {
            background
                .fill(backgroundFill)
        }
        .contentShape(Rectangle())
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
        .zIndex(11)
        .coordinateSpace(name: coordinateSpaceName)
        .onPreferenceChange(SearchFieldFrameKey.self) { frame in
            print("searchFieldFrame:", frame)
            searchFieldFrame = frame
        }
    }

    // MARK: - Tap To Dismiss
    private var tapToDismissView: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                isSearchOverlayVisible = false
                isSearchFieldFocused = false
            }
    }

    // MARK: - Search Suggestions Container
    private var searchSuggestionsContainer: some View {
        return FloatingOverlayPanel {
            SearchSuggestionsList(
                faviconService: faviconService,
                suggestions: searchSuggestions,
                onSelect: selectSuggestionReplace
            )
        }
        .frame(width: searchFieldFrame.width + (inset * 2))
        .offset(x: searchFieldFrame.minX - inset)
    }

    // MARK: - Navigation Buttons
    @ViewBuilder
    private var navigationButtons: some View {
        HStack(spacing: 10) {
            Button {
                onBack()
            } label: {
                HoverBackground(
                    innerColor: .black.opacity(0.15),
                    outerColor: .black.opacity(0.2)
                ) {
                    Image(systemName: "arrow.backward")
                        .padding(6)
                }
            }
            .buttonStyle(.plain)
            .disabled(!canNavigateBack)

            Button {
                onForward()
            } label: {
                HoverBackground(
                    innerColor: .black.opacity(0.15),
                    outerColor: .black.opacity(0.2)
                ) {
                    Image(systemName: "arrow.forward")
                        .padding(6)
                }
            }
            .buttonStyle(.plain)
            .disabled(!canNavigateForward)
        }
    }

    // MARK: - Textfield
    private var textfield: some View {
        HStack(alignment: .center) {
            if isSearchOverlayVisible {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.black)
                    .frame(width: 18)
            } else {
                Button(action: {
                    /// copy to clipboard
                }) {
                    HoverBackground {
                        Image(systemName: "link")
                            .foregroundStyle(.black)
                            .padding(3)
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 18)
            }

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
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                isSearchOverlayVisible = true
                isSearchFieldFocused = true
            }
        )
        .animation(.snappy(duration: 0.2), value: isSearchOverlayVisible)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(textFieldBackground)
                .padding(.vertical, 3)
                .onTapGesture {
                    isSearchOverlayVisible = true
                    isSearchFieldFocused = true
                }
        }
        .onHover { hovering in
            if isSearchFieldFocused || isSearchOverlayVisible {
                hoveringOverSearch = false
            } else {
                hoveringOverSearch = hovering
            }
        }
        .onChange(of: isSearchFieldFocused) { _, newValue in
            if newValue {
                hoveringOverSearch = false
            }
        }
        .onChange(of: isSearchOverlayVisible) { _, newValue in
            if newValue {
                hoveringOverSearch = false
            }
        }
        .animation(.bouncy, value: hoveringOverSearch)
        .overlay {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: SearchFieldFrameKey.self,
                    value: proxy.frame(in: .named(coordinateSpaceName))
                )
            }
        }
    }
}

#Preview {
    
    @Previewable @State var comfyBrowserViewModel = ComfyBrowserViewModel()
    @Previewable @State var browserCoordinator = BrowserCoordinator()
    
    VStack {
        TopBar(
            searchEngine: .duckDuckGo,
            faviconService: browserCoordinator.faviconService,
            canNavigateBack: .constant(true),
            canNavigateForward: .constant(true),
            shouldShowSidebarIcon: .constant(true),
            isSearchOverlayVisible: .constant(false),
            isSearchFieldFocused: .constant(false),
            search: .constant(""),
            searchSuggestions: .constant([]),
            sidebarIcon: {
                SidebarIcon(action: comfyBrowserViewModel.toggleSidebarOpenClose)
            },
            onSearch: { searchTerm in
                browserCoordinator.search(searchTerm)
            },
            searching: { searchTerm in
                browserCoordinator.searching(searchTerm)
            },
            selectSuggestionReplace: { suggestion in
            },
            onForward: browserCoordinator.navigateForward,
            onBack: browserCoordinator.navigateBack
        )
        .padding()
    }
    .frame(width: 400, height: 500)
}
