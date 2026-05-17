//
//  SearchSuggestionRowViewModel.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//


import Foundation

@Observable
@MainActor
final class SearchSuggestionRowViewModel {
    var isHovering = false
    var faviconService: FaviconService
    var suggestion : SearchSuggestion
    
    init(
        faviconService: FaviconService,
        suggestion: SearchSuggestion
    ) {
        self.faviconService = faviconService
        self.suggestion = suggestion
    }
}
