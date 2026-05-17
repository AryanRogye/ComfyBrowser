//
//  UserSearchResolver.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import Foundation

/// `SearchInputResolver`
/// decides: "is this a URL, domain, search, or empty?"
///
/// Converts raw omnibar input into a browser action.
///
/// `BrowserCoordinator` should use this instead of re-implementing URL/search
/// parsing in multiple places.
enum UserSearchResolver {
    
    /// Resolves typed omnibar text into the action the browser should perform.
    ///
    /// Examples:
    ///     github.com -> .url(https://github.com)
    ///     https://example.com/docs -> .url(https://example.com/docs)
    ///     comfy browser -> .search("comfy browser", searchEngineURL)
    static func resolve(
        _ input: String,
        searchEngine: SearchEngine
    ) -> SearchQueryIntent {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .empty }
        
        if let explicitURL = explicitHTTPURL(from: trimmed) {
            return .url(explicitURL)
        }
        
        if let domainURL = bareDomainURL(from: trimmed) {
            return .url(domainURL)
        }
        
        guard let searchURL = searchEngine.search(for: trimmed) else {
            return .empty
        }
        
        return .search(query: trimmed, url: searchURL)
    }
}

extension UserSearchResolver {
    
    private static func explicitHTTPURL(
        from input: String
    ) -> URL? {
        guard let url = URL(string: input) else { return nil }
        guard let scheme = url.scheme?.lowercased() else { return nil }
        guard scheme == "http" || scheme == "https" else { return nil }
        guard url.host(percentEncoded: false) != nil else { return nil }
        return url
    }
    
    private static func bareDomainURL(
        from input: String
    ) -> URL? {
        guard !input.contains(" ") else { return nil }
        guard input.contains(".") || input == "localhost" else { return nil }
        
        let candidate = "https://\(input)"
        guard let url = URL(string: candidate) else { return nil }
        guard url.host(percentEncoded: false) != nil else { return nil }
        
        return url
    }
}
