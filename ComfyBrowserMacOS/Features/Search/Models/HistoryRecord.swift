//
//  HistoryRecord.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import Foundation

/// A persisted, de-duplicated browser history entry.
///
/// This is not the same as `Tab.history`. `Tab.history` describes one tab's
/// back/forward stack, while `HistoryRecord` is global user history used for
/// omnibar suggestions across launches.
///
/// Example:
///     Visiting https://github.com three times creates one record with
///     `visitCount == 3`, not three separate suggestion rows.
struct HistoryRecord: Identifiable, Codable, Hashable, Sendable {
    /// Uses the normalized URL so history rows de-duplicate naturally.
    var id: String { normalizedURL }
    
    /// Canonical URL key used for matching and persistence.
    var normalizedURL: String
    
    /// The latest concrete URL loaded by WebKit.
    var url: URL
    
    /// Best known page title from WebKit.
    var title: String?
    
    /// Cached host so the UI can display compact URLs quickly.
    var host: String?
    
    /// Number of times this normalized URL has been visited.
    var visitCount: Int
    
    /// First time the user visited this URL.
    var firstVisitedAt: Date
    
    /// Most recent time the user visited this URL.
    var lastVisitedAt: Date
    
    nonisolated init(
        url: URL,
        title: String? = nil,
        visitedAt: Date = .now
    ) {
        self.normalizedURL = Self.normalizedKey(for: url)
        self.url = url
        self.title = title?.nilIfBlank
        self.host = url.host(percentEncoded: false)
        self.visitCount = 1
        self.firstVisitedAt = visitedAt
        self.lastVisitedAt = visitedAt
    }
    
    nonisolated mutating func recordVisit(
        url: URL,
        title: String?,
        visitedAt: Date
    ) {
        self.url = url
        if let title = title?.nilIfBlank {
            self.title = title
        }
        self.host = url.host(percentEncoded: false)
        self.visitCount += 1
        self.lastVisitedAt = visitedAt
    }
}

extension HistoryRecord {
    
    /// Creates a stable key for de-duplicating visits.
    ///
    /// Example:
    ///     https://EXAMPLE.com/docs#intro -> https://example.com/docs
    nonisolated static func normalizedKey(for url: URL) -> String {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url.absoluteString.lowercased()
        }
        
        components.scheme = components.scheme?.lowercased()
        components.host = components.host?.lowercased()
        components.fragment = nil
        
        if components.path == "/" {
            components.path = ""
        }
        
        return components.url?.absoluteString.lowercased() ?? url.absoluteString.lowercased()
    }
    
    /// The title shown in the suggestion row.
    ///
    /// Example:
    ///     If the page title is missing, this falls back to `github.com`.
    nonisolated var displayTitle: String {
        title?.nilIfBlank ?? host ?? url.absoluteString
    }
    
    /// The compact URL shown as suggestion detail text.
    ///
    /// Example:
    ///     https://github.com/AryanRogye -> github.com/AryanRogye
    nonisolated var displayURL: String {
        if let host {
            return host + url.path
        }
        return url.absoluteString
    }
    
    /// Checks whether this record should appear for a typed query.
    ///
    /// Example:
    ///     A record titled "GitHub" with URL `github.com` matches "git".
    nonisolated func matches(_ query: String) -> Bool {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedQuery.isEmpty else { return true }
        
        return displayTitle.lowercased().contains(normalizedQuery)
            || displayURL.lowercased().contains(normalizedQuery)
            || url.absoluteString.lowercased().contains(normalizedQuery)
    }
}

private extension String {
    nonisolated var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
