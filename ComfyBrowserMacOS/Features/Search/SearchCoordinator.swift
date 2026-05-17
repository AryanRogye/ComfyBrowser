//
//  SearchCoordinator.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import Foundation

/// `SuggestionIndex`
/// stores history in RAM so lookup is fast
///
/// `SearchInputResolver`
/// decides: "is this a URL, domain, search, or empty?"
///
/// `SearchSuggestionProvider`
/// combines everything into rows for the omnibar

@Observable
@MainActor
final class SearchCoordinator {
    
    private(set) var historyStore = HistoryStore()
    let suggestionIndex = SuggestionIndex()
    let suggestionProvider = SearchSuggestionProvider()
    
    init() {
        loadSearchHistory()
    }
}

extension SearchCoordinator {
    public func resolve(
        _ input: String,
        with searchEngine: SearchEngine
    ) -> SearchQueryIntent {
        UserSearchResolver.resolve(
            input,
            searchEngine: searchEngine
        )
    }
    
    public func suggestions(
        for query: String,
        with searchEngine: SearchEngine,
        tabs: [Tab],
    ) -> [SearchSuggestion] {
        suggestionProvider.suggestions(
            for: query,
            tabs: tabs,
            index: suggestionIndex,
            searchEngine: searchEngine
        )
    }
}

extension SearchCoordinator {
    internal func loadSearchHistory() {
        Task { @MainActor in
            let store = await HistoryStore.make()
            let recent = await store.recent(limit: 2000)
            
            historyStore = store
            suggestionIndex.warm(
                with: recent
            )
        }
    }
    
    public func recordHistoryVisit(
        url: URL,
        title: String?
    ) {
        let historyStore = historyStore
        
        Task { @MainActor in
            guard let record = await historyStore.recordVisit(
                url: url,
                title: title
            ) else { return }
            
            suggestionIndex.update(with: record)
        }
    }
}
