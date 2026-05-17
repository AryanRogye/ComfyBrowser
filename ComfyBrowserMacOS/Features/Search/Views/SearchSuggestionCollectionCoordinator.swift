//
//  SearchSuggestionCollectionCoordinator.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import AppKit

// MARK: - SearchSuggestionCollectionCoordinator
/// Coordinates the AppKit collection view used by the omnibar suggestions.
///
/// This mirrors `SidebarCollectionCoordinator`: SwiftUI owns the suggestion
/// array, while the coordinator feeds reusable AppKit collection items.
///
/// Example:
///     `TopBar` updates `suggestions`, SwiftUI calls `updateNSView`, and this
///     coordinator reloads rows without rebuilding the entire top bar.
final class SearchSuggestionCollectionCoordinator: NSObject, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    var faviconService: FaviconService
    var suggestions: [SearchSuggestion]
    var highlightedID: SearchSuggestion.ID?
    var onHighlight: (SearchSuggestion.ID?) -> Void
    var onSelect: (SearchSuggestion) -> Void
    
    init(
        faviconService: FaviconService,
        suggestions: [SearchSuggestion],
        highlightedID: SearchSuggestion.ID?,
        onHighlight: @escaping (SearchSuggestion.ID?) -> Void,
        onSelect: @escaping (SearchSuggestion) -> Void
    ) {
        self.faviconService = faviconService
        self.suggestions = suggestions
        self.highlightedID = highlightedID
        self.onHighlight = onHighlight
        self.onSelect = onSelect
    }
    
    /// Asks the data source how many suggestion rows should be displayed.
    func collectionView(
        _ collectionView: NSCollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        suggestions.count
    }
    
    /// Provides a reusable item whose content is still rendered by SwiftUI.
    func collectionView(
        _ collectionView: NSCollectionView,
        itemForRepresentedObjectAt indexPath: IndexPath
    ) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: SearchSuggestionItem.identifier,
            for: indexPath
        ) as! SearchSuggestionItem
        
        let suggestion = suggestions[indexPath.item]
        item.configure(
            with: suggestion,
            isHighlighted: highlightedID == suggestion.id,
            faviconService: faviconService,
            onHighlight: onHighlight,
            onSelect: onSelect
        )
        
        return item
    }
}
