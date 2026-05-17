//
//  NewTabSearchPanel.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/17/26.
//

import SwiftUI

struct NewTabSearchPanel: View {
    
    @Binding var isShowing: Bool
    @Bindable var faviconService: FaviconService
    let searchEngine: SearchEngine
    var onSearch: (String) -> Void
    var searching: @MainActor (String) -> [SearchSuggestion]
    var selectSuggestion: (SearchSuggestion) -> Void
    
    @State private var searchSuggestions: [SearchSuggestion] = []
    @State private var search: String = ""
    @State private var isSearchFieldFocused: Bool = true
    
    var body: some View {
        if isShowing {
            VStack {
                ZStack {
                    FloatingOverlayPanel(
                        useDividerPadding: false,
                        overlayHeight: 200
                    ) {
                        SearchSuggestionsList(
                            faviconService: faviconService,
                            suggestions: searchSuggestions,
                            onSelect: selectSuggestion
                        )
                    } label: {
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
                                    isShowing = false
                                },
                                onFocusRequest: {
                                },
                                onFocusChange: { newValue in
                                    if !newValue {
                                        isShowing = false
                                        return
                                    }
                                },
                                onTextChange: { newValue in
                                    searchSuggestions = searching(newValue)
                                }
                            )
                        }
                        .frame(height: 40)
                        .contentShape(Rectangle())
                        .padding(.horizontal, 8)
                    }
                }
            }
        }
    }
}
