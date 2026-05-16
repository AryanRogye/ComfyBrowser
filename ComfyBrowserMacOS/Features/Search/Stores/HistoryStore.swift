//
//  HistoryStore.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import Foundation

/// Owns persistent local browsing history for omnibar suggestions.
///
/// This is intentionally separate from `SuggestionIndex`. The store is the
/// source of truth on disk; the index is only a bounded in-memory cache.
///
/// Example:
///     let historyStore = await HistoryStore.make()
///     await historyStore.recordVisit(url: url, title: title)
actor HistoryStore {
    
    private var recordsByURL: [String: HistoryRecord] = [:]
    private let fileURL: URL
    private var pendingPersistTask: Task<Void, Never>?
    
    /// Creates an in-memory history store.
    ///
    /// This initializer does not load from disk. Use `HistoryStore.make()`
    /// when the app wants persisted browser history.
    ///
    /// Example:
    ///     let emptyStore = HistoryStore(records: previewRecords)
    init(
        fileURL: URL? = nil,
        fileManager: FileManager = .default,
        records: [HistoryRecord] = []
    ) {
        self.fileURL = fileURL ?? Self.defaultHistoryFileURL(fileManager: fileManager)
        self.recordsByURL = Dictionary(
            uniqueKeysWithValues: records.map { ($0.normalizedURL, $0) }
        )
    }
    
    /// Records a successful page visit and schedules a debounced disk write.
    ///
    /// Repeated visits update one `HistoryRecord` by normalized URL.
    ///
    /// Example:
    ///     await recordVisit(url: URL(string: "https://github.com")!, title: "GitHub")
    @discardableResult
    func recordVisit(
        url: URL,
        title: String?,
        visitedAt: Date = .now
    ) -> HistoryRecord? {
        guard Self.shouldRecord(url) else { return nil }
        
        let key = HistoryRecord.normalizedKey(for: url)
        if var existing = recordsByURL[key] {
            existing.recordVisit(
                url: url,
                title: title,
                visitedAt: visitedAt
            )
            recordsByURL[key] = existing
        } else {
            recordsByURL[key] = HistoryRecord(
                url: url,
                title: title,
                visitedAt: visitedAt
            )
        }
        
        schedulePersist()
        return recordsByURL[key]
    }
    
    /// Returns the newest history records.
    ///
    /// Example:
    ///     `await recent(limit: 10)` is useful for showing suggestions on empty focus.
    func recent(
        limit: Int
    ) -> [HistoryRecord] {
        Array(
            recordsByURL.values
                .sorted { $0.lastVisitedAt > $1.lastVisitedAt }
                .prefix(max(0, limit))
        )
    }
    
    /// Returns history records that match typed omnibar text.
    ///
    /// Example:
    ///     `await matching("git", limit: 8)` can return GitHub history rows.
    func matching(
        _ query: String,
        limit: Int
    ) -> [HistoryRecord] {
        Array(
            recordsByURL.values
                .filter { $0.matches(query) }
                .sorted {
                    if $0.visitCount == $1.visitCount {
                        return $0.lastVisitedAt > $1.lastVisitedAt
                    }
                    return $0.visitCount > $1.visitCount
                }
                .prefix(max(0, limit))
        )
    }
    
    /// Deletes all persisted history.
    ///
    /// This is not wired to settings yet, but exists so the future privacy UI
    /// has one obvious entry point.
    func clear() {
        recordsByURL.removeAll()
        schedulePersist()
    }
    
    /// Immediately writes the latest in-memory history snapshot to disk.
    ///
    /// Most callers should rely on debounced persistence. `flush()` exists for
    /// shutdown, tests, or future import/export tools that need a known save
    /// point. It awaits the same nonisolated writer used by debounced saves.
    ///
    /// Example:
    ///     await historyStore.flush()
    func flush() async {
        pendingPersistTask?.cancel()
        await Self.persist(
            records: sortedRecordsForPersistence(),
            to: fileURL
        )
    }
}

extension HistoryStore {
    
    /// Creates a store and loads persisted history asynchronously.
    ///
    /// This should be the normal app startup path once history is wired into
    /// `SearchCoordinator`. The file read happens in `loadRecords(from:)`,
    /// which performs the blocking disk work in a detached task.
    ///
    /// Example:
    ///     let historyStore = await HistoryStore.make()
    static func make(
        fileURL: URL? = nil,
        fileManager: FileManager = .default
    ) async -> HistoryStore {
        let store = HistoryStore(
            fileURL: fileURL,
            fileManager: fileManager
        )
        await store.load()
        return store
    }
    
    /// Filters URLs that should never become omnibar suggestions.
    ///
    /// Example:
    ///     about:blank is skipped, but https://example.com is recorded.
    static func shouldRecord(
        _ url: URL
    ) -> Bool {
        guard let scheme = url.scheme?.lowercased() else { return false }
        guard scheme == "http" || scheme == "https" else { return false }
        guard url.host(percentEncoded: false) != nil else { return false }
        return true
    }
    
    /// Returns the JSON file location used for history persistence.
    ///
    /// Example:
    ///     ~/Library/Application Support/com.aryanrogye.ComfyBrowserMacOS/SearchHistory.json
    static func defaultHistoryFileURL(
        fileManager: FileManager = .default
    ) -> URL {
        let appSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? fileManager.temporaryDirectory
        
        let bundleID = Bundle.main.bundleIdentifier ?? "ComfyBrowser"
        
        return appSupport
            .appending(path: bundleID, directoryHint: .isDirectory)
            .appending(path: "SearchHistory.json", directoryHint: .notDirectory)
    }
}

// MARK: - Persistence
extension HistoryStore {
    
    /// Applies persisted history from disk to the actor's in-memory dictionary.
    ///
    /// This runs through `HistoryStore.make()`. The JSON file stores an array
    /// because arrays are easier to inspect by hand, but the actor keeps
    /// records in a dictionary so visits can be updated by normalized URL. The
    /// actual file read happens in `loadRecords(from:)`.
    ///
    /// Example:
    ///     [
    ///         {
    ///             "normalizedURL": "https://github.com",
    ///             "title": "GitHub",
    ///             "visitCount": 3
    ///         }
    ///     ]
    ///
    /// If the file is missing, the store starts empty. If decoding fails, the
    /// store also starts empty instead of crashing the browser on launch.
    private func load() async {
        let records = await Self.loadRecords(from: fileURL)
        recordsByURL = Dictionary(
            uniqueKeysWithValues: records.map { ($0.normalizedURL, $0) }
        )
    }
    
    /// Schedules a debounced write of the current history snapshot.
    ///
    /// Each mutation cancels the previous pending write and schedules a new
    /// one. That means quick sequences of page loads or title updates collapse
    /// into one disk write. The scheduled task captures plain values before it
    /// leaves actor isolation, so it never reads `self` from the detached task.
    ///
    /// Example:
    ///     await recordVisit(url: githubURL, title: "GitHub")
    ///     -> updates `recordsByURL`
    ///     -> `schedulePersist()` writes SearchHistory.json after a short delay
    private func schedulePersist() {
        pendingPersistTask?.cancel()
        
        let records = sortedRecordsForPersistence()
        let targetFileURL = fileURL
        
        pendingPersistTask = Task.detached(priority: .utility) { [records, targetFileURL] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            
            await Self.persist(
                records: records,
                to: targetFileURL
            )
        }
    }
    
    /// Sorts records into the order used by the persisted JSON file.
    ///
    /// Example:
    ///     The most recently visited page is written first.
    private func sortedRecordsForPersistence() -> [HistoryRecord] {
        recordsByURL.values.sorted {
            $0.lastVisitedAt > $1.lastVisitedAt
        }
    }
    
    /// Reads persisted history from disk outside the actor executor.
    ///
    /// Example:
    ///     `HistoryStore.make()` awaits this helper, then applies the loaded
    ///     records back to actor state.
    private nonisolated static func loadRecords(
        from fileURL: URL
    ) async -> [HistoryRecord] {
        await Task.detached(priority: .utility) { [fileURL] in
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                return []
            }
            
            do {
                let data = try Data(contentsOf: fileURL)
                return try JSONDecoder().decode([HistoryRecord].self, from: data)
            } catch {
                return []
            }
        }.value
    }
    
    /// Writes a history snapshot to disk without reading actor state.
    ///
    /// This method only receives immutable values. Debounced saves call it from
    /// a detached task; `flush()` awaits it directly when a caller needs to know
    /// the latest snapshot has reached disk.
    ///
    /// Example:
    ///     `schedulePersist()` captures `[HistoryRecord]`, waits 0.5 seconds
    ///     in a detached task, then calls this method with that snapshot.
    ///
    /// The write is atomic so a partial write should not corrupt the old file
    /// if the app quits during persistence.
    private nonisolated static func persist(
        records: [HistoryRecord],
        to fileURL: URL
    ) async {
        do {
            let directory = fileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(records)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            return
        }
    }
}
