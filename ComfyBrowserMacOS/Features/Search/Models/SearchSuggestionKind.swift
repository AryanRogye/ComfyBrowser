//
//  SearchSuggestionKind.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import Foundation

/// The source or action represented by one omnibar row.
///
/// Example:
///     `.openTab` means selecting the row should switch to an existing tab,
///     while `.search` means selecting the row should load the search URL.
enum SearchSuggestionKind: String, Codable, Hashable, Sendable {
    /// A currently open tab that matches the user's typed text.
    case openTab
    
    /// A persisted history visit that matches the user's typed text.
    case history
    
    /// A direct URL interpretation of the user's typed text.
    case url
    
    /// A search-engine query interpretation of the user's typed text.
    case search
}
