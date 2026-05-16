//
//  SearchSuggestionsList.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import SwiftUI

/// Renders the omnibar suggestion popup content.
///
/// `TopBar` will own focus, keyboard navigation, and query text. This view only
/// displays suggestions and reports highlight/select events back up.
///
/// Example:
///     Pressing Down in `TopBar` changes `highlightedID`, and this list redraws
///     the matching row as highlighted.
struct SearchSuggestionsList: View {
    
    var suggestions: [SearchSuggestion]
    var highlightedID: SearchSuggestion.ID?
    var onHighlight: (SearchSuggestion.ID?) -> Void
    var onSelect: (SearchSuggestion) -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(suggestions) { suggestion in
                SearchSuggestionRow(
                    suggestion: suggestion,
                    isHighlighted: highlightedID == suggestion.id
                )
                .onHover { isHovering in
                    if isHovering {
                        onHighlight(suggestion.id)
                    }
                }
                .onTapGesture {
                    onSelect(suggestion)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 58)
        .padding(.bottom, 10)
    }
}

#Preview {
    SearchSuggestionsList(
        suggestions: [
            SearchSuggestion(
                id: "tab",
                kind: .openTab,
                title: "GitHub",
                subtitle: "github.com",
                url: URL(string: "https://github.com"),
                score: 1
            ),
            SearchSuggestion(
                id: "search",
                kind: .search,
                title: "swiftui search",
                subtitle: "Search with DuckDuckGo",
                url: URL(string: "https://duckduckgo.com/?q=swiftui%20search"),
                query: "swiftui search",
                score: 1
            )
        ],
        highlightedID: "tab",
        onHighlight: { _ in },
        onSelect: { _ in }
    )
    .frame(width: 520)
    .padding()
}
