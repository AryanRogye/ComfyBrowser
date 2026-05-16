//
//  SuggestionIndex.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import Foundation

/// A bounded in-memory cache of history records for fast omnibar lookups.
///
/// This should never own `WKWebView` or other heavy browser objects. It stores
/// lightweight `HistoryRecord` values warmed from `HistoryStore`.
///
/// Example:
///     let index = SuggestionIndex(limit: 2_000, records: historyStore.recent(limit: 2_000))
///     index.matching("git", limit: 8)
final class SuggestionIndex {
    
    private let limit: Int
    private var recordsByURL: [String: HistoryRecord] = [:]
    
    init(
        limit: Int = 2_000,
        records: [HistoryRecord] = []
    ) {
        self.limit = limit
        warm(with: records)
    }
    
    /// Replaces the cache contents with records loaded from persistent history.
    ///
    /// Example:
    ///     Call once during app startup with recent history rows.
    func warm(
        with records: [HistoryRecord]
    ) {
        recordsByURL = Dictionary(
            uniqueKeysWithValues: records.map { ($0.normalizedURL, $0) }
        )
        trimToLimit()
    }
    
    /// Inserts or replaces one cached history record.
    ///
    /// Example:
    ///     After `HistoryStore.recordVisit(...)` returns a record, pass it here
    ///     so the omnibar can suggest it immediately.
    func update(
        with record: HistoryRecord
    ) {
        recordsByURL[record.normalizedURL] = record
        trimToLimit()
    }
    
    /// Returns the newest cached history records.
    func recent(
        limit: Int
    ) -> [HistoryRecord] {
        Array(
            recordsByURL.values
                .sorted { $0.lastVisitedAt > $1.lastVisitedAt }
                .prefix(max(0, limit))
        )
    }
    
    /// Returns cached history records matching typed omnibar text.
    ///
    /// Example:
    ///     `matching("you", limit: 8)` can return YouTube history.
    func matching(
        _ query: String,
        limit: Int
    ) -> [HistoryRecord] {
        Array(
            recordsByURL.values
                .filter { $0.matches(query) }
                .sorted { lhs, rhs in
                    if lhs.visitCount == rhs.visitCount {
                        return lhs.lastVisitedAt > rhs.lastVisitedAt
                    }
                    return lhs.visitCount > rhs.visitCount
                }
                .prefix(max(0, limit))
        )
    }
}

extension SuggestionIndex {
    
    private func trimToLimit() {
        guard recordsByURL.count > limit else { return }
        
        let recordsToKeep = recordsByURL.values
            .sorted { $0.lastVisitedAt > $1.lastVisitedAt }
            .prefix(limit)
        
        recordsByURL = Dictionary(
            uniqueKeysWithValues: recordsToKeep.map { ($0.normalizedURL, $0) }
        )
    }
}
