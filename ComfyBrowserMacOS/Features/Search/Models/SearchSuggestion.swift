//
//  SearchSuggestion.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import Foundation

/// A single row shown in the omnibar suggestion popup.
///
/// The provider creates these from multiple sources: open tabs, history,
/// direct URLs, and search actions. The UI only needs this one shape.
///
/// Example:
///     SearchSuggestion(
///         id: "open-tab-UUID",
///         kind: .openTab,
///         title: "GitHub",
///         subtitle: "https://github.com",
///         url: URL(string: "https://github.com"),
///         tabID: tab.id,
///         score: 1100
///     )
struct SearchSuggestion: Identifiable, Hashable, Sendable {
    /// Stable row ID used by SwiftUI selection/highlighting.
    let id: String
    
    /// Tells the browser what should happen when the row is selected.
    var kind: SearchSuggestionKind
    
    /// Primary text shown in the row.
    var title: String
    
    /// Secondary text shown below the title, usually a URL or action label.
    var subtitle: String?
    
    /// Destination URL for history, direct URL, and search rows.
    var url: URL?
    
    /// Existing tab ID for `.openTab` rows.
    var tabID: UUID?
    
    /// Raw search text for `.search` rows.
    var query: String?
    
    /// Ranking score. Higher scores appear first.
    var score: Int
    
    init(
        id: String,
        kind: SearchSuggestionKind,
        title: String,
        subtitle: String? = nil,
        url: URL? = nil,
        tabID: UUID? = nil,
        query: String? = nil,
        score: Int
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.url = url
        self.tabID = tabID
        self.query = query
        self.score = score
    }
}
