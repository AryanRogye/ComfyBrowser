//
//  SearchSuggestionsList.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import AppKit
import SwiftUI

/// Renders the omnibar suggestion popup content.
///
/// This is the SwiftUI entry point into an AppKit `NSCollectionView`, matching
/// the sidebar's architecture. AppKit owns fast row reuse and scrolling, while
/// each row remains a SwiftUI `SearchSuggestionRow`.
///
/// Example:
///     Pressing Down in `TopBar` changes `highlightedID`, and this list redraws
///     the matching row as highlighted.
struct SearchSuggestionsList: NSViewRepresentable {
    
    var suggestions: [SearchSuggestion]
    var highlightedID: SearchSuggestion.ID? = nil
    var onHighlight: (SearchSuggestion.ID?) -> Void
    var onSelect: (SearchSuggestion) -> Void
    
    func makeCoordinator() -> SearchSuggestionCollectionCoordinator {
        SearchSuggestionCollectionCoordinator(
            suggestions: suggestions,
            highlightedID: highlightedID,
            onHighlight: onHighlight,
            onSelect: onSelect
        )
    }
    
    func makeNSView(context: Context) -> SearchSuggestionScrollView {
        context.coordinator.suggestions = suggestions
        context.coordinator.highlightedID = highlightedID
        
        let scrollView = SearchSuggestionScrollView()
        scrollView.collectionView.dataSource = context.coordinator
        scrollView.collectionView.delegate = context.coordinator
        
        return scrollView
    }
    
    func updateNSView(
        _ nsView: SearchSuggestionScrollView,
        context: Context
    ) {
        context.coordinator.suggestions = suggestions
        context.coordinator.highlightedID = highlightedID
        context.coordinator.onHighlight = onHighlight
        context.coordinator.onSelect = onSelect
        
        nsView.collectionView.reloadData()
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
