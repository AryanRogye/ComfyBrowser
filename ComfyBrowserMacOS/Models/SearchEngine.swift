//
//  SearchEngine.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/15/26.
//

import Foundation

enum SearchEngine: String, CaseIterable {
    case google = "Google"
    case duckDuckGo = "DuckDuckGo"
    case braveSearch = "Brave Search"

    var searchURLPrefix: String {
        switch self {
        case .google:
            return "https://www.google.com/search?q="
        case .duckDuckGo:
            return "https://duckduckgo.com/?q="
        case .braveSearch:
            return "https://search.brave.com/search?q="
        }
    }

    /// Generates a search URL using the currently selected search engine.
    ///
    /// Examples:
    ///
    /// Google:
    /// Input:
    ///     "comfy browser"
    /// Output:
    ///     https://www.google.com/search?q=comfy%20browser
    ///
    /// DuckDuckGo:
    /// Input:
    ///     "comfy browser"
    /// Output:
    ///     https://duckduckgo.com/?q=comfy%20browser
    ///
    /// Brave Search:
    /// Input:
    ///     "comfy browser"
    /// Output:
    ///     https://search.brave.com/search?q=comfy%20browser
    ///
    /// - Parameter query: The raw search query entered by the user.
    /// - Returns: A fully encoded search URL for the selected search engine.
    func search(
        for query: String
    ) -> URL? {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: searchURLPrefix + encoded)
    }
}
