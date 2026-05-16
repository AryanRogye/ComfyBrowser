//
//  SearchSuggestionProvider.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import Foundation

/// `SearchSuggestionProvider`
/// combines everything into rows for the omnibar
///
/// Combines local sources into ranked omnibar suggestions.
///
/// V1 sources are open tabs, cached history, a direct URL action, and a search
/// action. This is the "muxer" layer: the UI asks one provider and does not
/// need to know where each row came from.
///
/// Example:
///     provider.suggestions(
///         for: "git",
///         tabs: browserCoordinator.tabs,
///         index: suggestionIndex,
///         searchEngine: .duckDuckGo
///     )
struct SearchSuggestionProvider {
    
    var resolver = SearchInputResolver()
    var maxSuggestions: Int = 8
    
    /// Builds ranked suggestions for the current query.
    ///
    /// Open tabs intentionally start with a higher base score than history so
    /// switching tabs feels fast, like Zen/Arc command bars.
    func suggestions(
        for query: String,
        tabs: [Tab],
        index: SuggestionIndex,
        searchEngine: SearchEngine
    ) -> [SearchSuggestion] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let tabSuggestions = openTabSuggestions(
            for: trimmed,
            tabs: tabs
        )
        
        let historySuggestions = historySuggestions(
            for: trimmed,
            index: index,
            excluding: Set(tabSuggestions.compactMap { $0.url?.absoluteString })
        )
        
        let actionSuggestion = actionSuggestion(
            for: trimmed,
            searchEngine: searchEngine
        )
        
        return Array(
            (tabSuggestions + historySuggestions + actionSuggestion)
                .sorted { lhs, rhs in
                    if lhs.score == rhs.score {
                        return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                    }
                    return lhs.score > rhs.score
                }
                .prefix(maxSuggestions)
        )
    }
}

extension SearchSuggestionProvider {
    
    /// Creates suggestions for already-open tabs.
    ///
    /// Example:
    ///     If a GitHub tab is open, typing "git" returns an `.openTab` row.
    private func openTabSuggestions(
        for query: String,
        tabs: [Tab]
    ) -> [SearchSuggestion] {
        tabs.compactMap { tab in
            let title = tab.title.nilIfBlank ?? tab.url.host(percentEncoded: false) ?? tab.url.absoluteString
            let subtitle = tab.url.absoluteString
            let score = scoreMatch(
                query: query,
                title: title,
                subtitle: subtitle,
                baseScore: 1_000
            )
            
            guard query.isEmpty || score > 1_000 else { return nil }
            
            return SearchSuggestion(
                id: "open-tab-\(tab.id.uuidString)",
                kind: .openTab,
                title: title,
                subtitle: subtitle,
                url: tab.url,
                tabID: tab.id,
                score: score
            )
        }
    }
    
    /// Creates suggestions from cached persistent history.
    ///
    /// Open-tab URLs are excluded so the popup does not show duplicate rows for
    /// the same page.
    private func historySuggestions(
        for query: String,
        index: SuggestionIndex,
        excluding openTabURLStrings: Set<String>
    ) -> [SearchSuggestion] {
        let records = query.isEmpty
            ? index.recent(limit: maxSuggestions)
            : index.matching(query, limit: maxSuggestions)
        
        return records.compactMap { record in
            guard !openTabURLStrings.contains(record.url.absoluteString) else {
                return nil
            }
            
            let score = scoreMatch(
                query: query,
                title: record.displayTitle,
                subtitle: record.displayURL,
                baseScore: 500
            ) + min(record.visitCount, 25)
            
            guard query.isEmpty || score > 500 else { return nil }
            
            return SearchSuggestion(
                id: "history-\(record.normalizedURL)",
                kind: .history,
                title: record.displayTitle,
                subtitle: record.displayURL,
                url: record.url,
                score: score
            )
        }
    }
    
    /// Creates the final direct-open or search row.
    ///
    /// Examples:
    ///     "github.com" creates `.url`
    ///     "swiftui toolbar" creates `.search`
    private func actionSuggestion(
        for query: String,
        searchEngine: SearchEngine
    ) -> [SearchSuggestion] {
        switch resolver.resolve(query, searchEngine: searchEngine) {
        case .empty:
            return []
        case .url(let url):
            return [
                SearchSuggestion(
                    id: "url-\(url.absoluteString)",
                    kind: .url,
                    title: url.absoluteString,
                    subtitle: "Open address",
                    url: url,
                    score: 250
                )
            ]
        case .search(let query, let url):
            return [
                SearchSuggestion(
                    id: "search-\(query)",
                    kind: .search,
                    title: query,
                    subtitle: "Search with \(searchEngine.rawValue)",
                    url: url,
                    query: query,
                    score: 200
                )
            ]
        }
    }
    
    /// Scores one source match against the query.
    ///
    /// Exact matches beat prefixes, and prefixes beat substring matches.
    private func scoreMatch(
        query: String,
        title: String,
        subtitle: String,
        baseScore: Int
    ) -> Int {
        let normalizedQuery = query.lowercased()
        guard !normalizedQuery.isEmpty else { return baseScore }
        
        let normalizedTitle = title.lowercased()
        let normalizedSubtitle = subtitle.lowercased()
        
        if normalizedTitle == normalizedQuery || normalizedSubtitle == normalizedQuery {
            return baseScore + 100
        }
        
        if normalizedTitle.hasPrefix(normalizedQuery) || normalizedSubtitle.hasPrefix(normalizedQuery) {
            return baseScore + 75
        }
        
        if normalizedTitle.contains(normalizedQuery) || normalizedSubtitle.contains(normalizedQuery) {
            return baseScore + 50
        }
        
        return baseScore
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
