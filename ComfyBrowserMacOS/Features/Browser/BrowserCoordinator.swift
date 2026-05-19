//
//  BrowserCoordinator.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import Foundation
import WebKit
import Combine

@Observable
@MainActor
final class BrowserCoordinator {

    static let dataStore: WKWebsiteDataStore = .default()

    var tabs : [Tab] = []
    private var regularTabs: [Tab] {
        let pinnedIDs = SidebarNode.pinnedTabIDs(in: pinnedNodes)
        return tabs.filter { !pinnedIDs.contains($0.id) }
    }

    var pinnedNodes: [SidebarNode] = []

    private var pinnedTabCount: Int {
        pinnedNodes.reduce(0) { count, node in
            guard case .tab = node else { return count }
            return count + 1
        }
    }

    var selectedTab : Tab?
    var searchEngine: SearchEngine = .duckDuckGo
    var canNavigateBack: Bool = false
    var canNavigateForward: Bool = false
    
    let faviconService = FaviconService()
    let searchCoordinator = SearchCoordinator()

    var webView: WKWebView
    
    init() {
        webView = Self.getDefaultWebkitView()
        refreshNavigationAvailability()
        observeTabs()
    }
}

// MARK: - Pinned Tabs
extension BrowserCoordinator {
    
    /// Pins an existing tab into the pinned sidebar zone without changing WebKit ownership.
    public func pinTab(id: UUID, atPinnedIndex pinnedIndex: Int? = nil) {
        guard let tab = tabs.first(where: { $0.id == id }) else { return }
        guard SidebarNode.pinnedTabIDs(in: pinnedNodes).contains(id) else { return }

        insertPinnedTab(tab, atPinnedIndex: pinnedIndex)
    }
    
    /// Removes a tab from the pinned sidebar zone while keeping the tab open.
    public func unpinTab(id: UUID) {
        removePinnedTab(id: id, from: &pinnedNodes)
    }
    
    /// Expands or collapses a pinned folder row.
    public func togglePinnedFolder(id: UUID) {
        toggleFolder(id: id, in: &pinnedNodes)
    }
    
    /// Moves a tab into the pinned tabs section.
    public func movePinnedTab(id: UUID, toPinnedIndex pinnedIndex: Int) {
        guard let tab = tabs.first(where: { $0.id == id }) else { return }
        
        removePinnedTab(id: id, from: &pinnedNodes)
        insertPinnedTab(tab, atPinnedIndex: pinnedIndex)
    }
    
    /// Moves a top-level pinned folder within the folders section.
    public func movePinnedFolder(id: UUID, toFolderIndex folderIndex: Int) {
        guard let folder = removePinnedFolder(id: id, from: &pinnedNodes) else { return }
        insertPinnedFolder(folder, atFolderIndex: folderIndex)
    }
    
    /// Moves a regular tab within the regular tab section.
    public func moveRegularTab(id: UUID, toRegularIndex regularIndex: Int) {
        guard let sourceIndex = tabs.firstIndex(where: { $0.id == id }) else { return }
        
        let tab = tabs.remove(at: sourceIndex)
        let regularIDs = regularTabs.map(\.id)
        let destinationID = regularIDs.indices.contains(regularIndex)
            ? regularIDs[regularIndex]
            : nil
        
        if let destinationID, let destinationIndex = tabs.firstIndex(where: { $0.id == destinationID }) {
            tabs.insert(tab, at: destinationIndex)
        } else {
            tabs.append(tab)
        }
    }
    
    /// Moves a tab under a pinned folder, pinning it if needed.
    public func movePinnedTab(id: UUID, intoFolder folderID: UUID) {
        guard let tab = tabs.first(where: { $0.id == id }) else { return }
        
        removePinnedTab(id: id, from: &pinnedNodes)
        insertPinnedTab(tab, intoFolder: folderID, in: &pinnedNodes)
    }

    private func insertPinnedTab(_ tab: Tab, atPinnedIndex pinnedIndex: Int?) {
        let index = topLevelInsertionIndex(
            forNodeKind: .tab,
            sectionIndex: pinnedIndex ?? pinnedTabCount
        )
        
        pinnedNodes.insert(
            .tab(tab),
            at: min(index, pinnedNodes.count)
        )
    }
    
    private func insertPinnedFolder(_ folder: TabFolder, atFolderIndex folderIndex: Int) {
        let index = topLevelInsertionIndex(
            forNodeKind: .folder,
            sectionIndex: folderIndex
        )
        
        pinnedNodes.insert(
            .folder(folder),
            at: min(index, pinnedNodes.count)
        )
    }

    private enum PinnedNodeKind {
        case tab
        case folder
    }
    
    private func topLevelInsertionIndex(
        forNodeKind nodeKind: PinnedNodeKind,
        sectionIndex: Int
    ) -> Int {
        var matchingNodeCount = 0
        
        for index in pinnedNodes.indices {
            switch (nodeKind, pinnedNodes[index]) {
            case (.tab, .tab), (.folder, .folder):
                if matchingNodeCount == sectionIndex {
                    return index
                }
                
                matchingNodeCount += 1
            case (.tab, .folder), (.folder, .tab):
                continue
            }
        }
        
        return pinnedNodes.count
    }
}

// MARK: - Search
extension BrowserCoordinator {
    
    /// Search "String"
    public func search(_ value: String, inPlace: Bool = false) {
        
        let openInPlace = inPlace && !tabs.isEmpty
        
        switch searchCoordinator.resolve(value, with: searchEngine) {
        case .empty:
            return
        case .url(let url):
            if openInPlace {
                createTabInPlace(
                    url: url,
                    title: value
                )
            } else {
                createTab(
                    url: url,
                    title: value
                )
            }
        case .search(let query, let url):
            if openInPlace {
                createTabInPlace(
                    url: url,
                    title: query
                )
            } else {
                createTab(
                    url: url,
                    title: query
                )
            }
        }
    }
    
    /// While Searching we can call this to get a list
    /// of searchSuggestions (uses users history)
    public func searching(
        _ value: String
    ) -> [SearchSuggestion] {
        searchCoordinator.suggestions(
            for: value,
            with: searchEngine,
            tabs: tabs
        )
    }
    
    /// Clicking a Suggestion
    public func openSuggestion(
        _ suggestion: SearchSuggestion,
        inPlace: Bool = false
    ) {
        
        let openInPlace = inPlace && !tabs.isEmpty
        
        switch suggestion.kind {
        case .openTab:
            guard let tabID = suggestion.tabID else { return }
            select(id: tabID)
        case .history, .url, .search:
            guard let url = suggestion.url else { return }
            if openInPlace {
                createTabInPlace(url: url, title: suggestion.title)
            } else {
                createTab(url: url, title: suggestion.title)
            }
        }
    }
    
    internal func createTabConfig(url: URL, title: String) -> (Tab, WKWebView) {
        let newWebView = Self.getDefaultWebkitView()
        var tab = Tab(title: title, url: url, isActive: true)
        newWebView.load(URLRequest(url: tab.url))
        tab.retainedWebView = newWebView
        
        return (tab, newWebView)
    }
    
    /// Internal Function Creates a tab and replaces
    /// the current tab with it
    internal func createTabInPlace(
        url: URL,
        title: String
    ) {
        webView.load(URLRequest(url: url))
        updateSelectedTab(url: url, title: title)
        refreshNavigationAvailability()
    }
    
    /// Internal Function Creates a tab and adds it to the
    /// tabs array
    internal func createTab(
        url: URL,
        title: String
    ) {
        let (tab, newWebView) = createTabConfig(url: url, title: title)
        
        tabs.append(tab)
        selectedTab = tab
        webView = newWebView
        refreshNavigationAvailability()
        
        searchCoordinator.recordHistoryVisit(url: url, title: title)
    }

    private func createTempTab() -> Tab {
        let newTab = Tab(
            title: "New Tab",
            url: URL(string: "about:blank")!,
            isActive: true
        )
        return newTab
    }

}

// MARK: - Navigation Actions
extension BrowserCoordinator {
    
    /// Navigates the active tab backward when WebKit has a valid entry.
    public func navigateBack() {
        guard canNavigateBack else { return }
        guard webView.canGoBack else {
            refreshNavigationAvailability()
            return
        }
        
        webView.goBack()
        refreshNavigationAvailability()
    }
    
    /// Navigates the active tab forward when WebKit has a valid entry.
    public func navigateForward() {
        guard canNavigateForward else { return }
        guard webView.canGoForward else {
            refreshNavigationAvailability()
            return
        }
        
        webView.goForward()
        refreshNavigationAvailability()
    }
}

// MARK: - Tab Management
extension BrowserCoordinator {
    
    /// Updates the selected tab with the latest loaded page state.
    ///
    /// This is typically called by `WebViewContainer` after a navigation finishes
    /// or the page title changes.
    ///
    /// Example:
    ///     updateSelectedTab(
    ///         url: URL(string: "https://github.com")!,
    ///         title: "GitHub"
    ///     )
    public func updateSelectedTab(
        url: URL,
        title: String
    ) {
        guard let selectedTab else { return }
        guard let index = tabs.firstIndex(where: { $0.id == selectedTab.id }) else { return }
        
        let didURLChange = tabs[index].url != url
        
        /// Ony Update and add to history if url is not the same
        if didURLChange {
            updateURL(at: index, url: url, title: title)
            searchCoordinator.recordHistoryVisit(url: url, title: title)
        }
        
        updateTitle(at: index, title: title)
        self.selectedTab = tabs[index]
    }
    
    /// Closes a tab and releases its retained `WKWebView`.
    ///
    /// If the closed tab is currently selected, the browser selects the nearest
    /// remaining tab. If no tabs remain, the browser resets to a fresh blank
    /// `WKWebView`.
    ///
    /// Most likely a "xmark" button will do this
    public func closeTab(
        id: UUID
    ) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let closingSelected = selectedTab?.id == id
        
        /// release the WebView before removing (Stops Leak)
        tabs[index].retainedWebView?.stopLoading()
        tabs[index].retainedWebView = nil
        
        tabs.remove(at: index)
        
        guard !tabs.isEmpty else {
            selectedTab = nil
            webView.stopLoading()
            webView = Self.getDefaultWebkitView()
            webView.load(URLRequest(url: createTempTab().url))
            refreshNavigationAvailability()
            return
        }
        
        if closingSelected {
            let newIndex = min(index, tabs.count - 1)
            select(id: tabs[newIndex].id)
        } else {
            refreshNavigationAvailability()
        }
    }
    
    /// Selects a tab and restores its retained `WKWebView` if available.
    ///
    /// Before switching tabs, the current visible `WKWebView` is saved back into
    /// the previously selected tab. If the destination tab does not already retain
    /// a `WKWebView`, a new one is created and loaded with the tab's current URL.
    ///
    /// Example:
    ///     select(id: tab.id)
    public func select(id: UUID) {
        
        saveCurrentTab()
        
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        let storedTab = tabs[index]
        
        self.selectedTab = storedTab

        if let webview = storedTab.retainedWebView {
            self.webView = webview
        } else {
            let newWebView = Self.getDefaultWebkitView()
            newWebView.load(URLRequest(url: storedTab.url))
            
            tabs[index].retainedWebView = newWebView
            self.webView = newWebView
        }
        
        refreshNavigationAvailability()
    }
}

// MARK: - Tab Mutation
extension BrowserCoordinator {
    
    /// Updates a tab's current URL and keeps its metadata history valid.
    internal func updateURL(at index: Int, url: URL, title: String?) {
        guard tabs.indices.contains(index) else { return }
        
        clampHistoryIndex(at: index)
        
        guard !tabs[index].history.isEmpty else {
            tabs[index].history = [
                .init(
                    url: url,
                    title: title,
                    visitedAt: .now
                )
            ]
            tabs[index].url = url
            tabs[index].historyIndex = 0
            return
        }
        
        let currentIndex = tabs[index].historyIndex
        
        if tabs[index].history[currentIndex].url == url {
            tabs[index].url = url
            tabs[index].history[currentIndex].title = title
            return
        }
        
        if currentIndex > 0 && tabs[index].history[currentIndex - 1].url == url {
            tabs[index].historyIndex = currentIndex - 1
            tabs[index].url = url
            updateCurrentHistoryTitle(at: index, title: title)
            return
        }
        
        let nextIndex = currentIndex + 1
        if tabs[index].history.indices.contains(nextIndex),
           tabs[index].history[nextIndex].url == url {
            tabs[index].historyIndex = nextIndex
            tabs[index].url = url
            updateCurrentHistoryTitle(at: index, title: title)
            return
        }
        
        if currentIndex < tabs[index].history.count - 1 {
            tabs[index].history.removeSubrange((currentIndex + 1)...)
        }
        
        tabs[index].history.append(
            .init(
                url: url,
                title: title,
                visitedAt: .now
            )
        )
        tabs[index].url = url
        tabs[index].historyIndex = tabs[index].history.count - 1
    }
    
    /// Updates a tab's display title.
    internal func updateTitle(at index: Int, title: String) {
        guard tabs.indices.contains(index) else { return }
        tabs[index].title = title
        updateCurrentHistoryTitle(at: index, title: title)
    }
    
    /// Stores the active `WKWebView` instance back into the matching tab.
    internal func saveRetainedWebView(for tab: Tab, webview: WKWebView) {
        guard let index = tabs.firstIndex(where: { $0.id == tab.id }) else { return }
        guard tabs.indices.contains(index) else { return }
        tabs[index].retainedWebView = webview
    }
    
    /// Persists the currently displayed `WKWebView` into the selected tab.
    internal func saveCurrentTab() {
        if let currentTab = self.selectedTab {
            self.saveRetainedWebView(for: currentTab, webview: webView)
        }
    }
    
    /// Keeps `historyIndex` inside the available per-tab history range.
    internal func clampHistoryIndex(at index: Int) {
        guard tabs.indices.contains(index) else { return }
        
        if tabs[index].history.isEmpty {
            tabs[index].historyIndex = 0
            return
        }
        
        tabs[index].historyIndex = min(
            max(tabs[index].historyIndex, 0),
            tabs[index].history.count - 1
        )
    }
    
    /// Updates the title on the current per-tab history entry.
    internal func updateCurrentHistoryTitle(at index: Int, title: String?) {
        guard tabs.indices.contains(index) else { return }
        clampHistoryIndex(at: index)
        
        guard !tabs[index].history.isEmpty else { return }
        tabs[index].history[tabs[index].historyIndex].title = title
    }

    /// =============================================================================================
    /// Pinned Tabs Mutation
    /// =============================================================================================

    /// Removes Pinned Tabs and Folders
    /// this is recursive and will keep going till children in folder are gone
    @discardableResult
    internal func removePinnedTab(id: UUID, from nodes: inout [SidebarNode]) -> Bool {
        for index in nodes.indices {
            switch nodes[index] {
            case .tab(let tab):
                if tab.id == id {
                    nodes.remove(at: index)
                    return true
                }
            case .folder(var folder):
                if removePinnedTab(id: id, from: &folder.children) {
                    nodes[index] = .folder(folder)
                    return true
                }
            }
        }

        return false
    }

    /// Removes a pinned folder
    internal func removePinnedFolder(id: UUID, from nodes: inout [SidebarNode]) -> TabFolder? {
        for index in nodes.indices {
            guard case .folder(let folder) = nodes[index] else { continue }

            if folder.id == id {
                nodes.remove(at: index)
                return folder
            }
        }

        return nil
    }

    @discardableResult
    internal func insertPinnedTab(
        _ tab: Tab,
        intoFolder folderID: UUID,
        in nodes: inout [SidebarNode]
    ) -> Bool {
        for index in nodes.indices {
            switch nodes[index] {
            case .tab:
                continue
            case .folder(var folder):
                if folder.id == folderID {
                    folder.children.append(.tab(tab))
                    folder.isExpanded = true
                    nodes[index] = .folder(folder)
                    return true
                }

                if insertPinnedTab(tab, intoFolder: folderID, in: &folder.children) {
                    nodes[index] = .folder(folder)
                    return true
                }
            }
        }

        return false
    }

    @discardableResult
    internal func toggleFolder(id: UUID, in nodes: inout [SidebarNode]) -> Bool {
        for index in nodes.indices {
            switch nodes[index] {
            case .tab:
                continue
            case .folder(var folder):
                if folder.id == id {
                    folder.isExpanded.toggle()
                    nodes[index] = .folder(folder)
                    return true
                }

                if toggleFolder(id: id, in: &folder.children) {
                    nodes[index] = .folder(folder)
                    return true
                }
            }
        }

        return false
    }
}

// MARK: - Navigation State
extension BrowserCoordinator {
    
    /// Updates the exposed navigation availability for the active web view.
    public func updateNavigationAvailability(
        canGoBack: Bool,
        canGoForward: Bool
    ) {
        canNavigateBack = canGoBack
        canNavigateForward = canGoForward
    }
    
    /// Reads navigation availability from the currently active `WKWebView`.
    internal func refreshNavigationAvailability() {
        updateNavigationAvailability(
            canGoBack: webView.canGoBack,
            canGoForward: webView.canGoForward
        )
    }
}

// MARK: - Observations
extension BrowserCoordinator {
    /// Function Observes all tabs (for no reason right now)
    func observeTabs() {
        withObservationTracking {
            _ = tabs
        } onChange: { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                print("""
                Tabs Changed:
                \(self.tabs.map { "• \($0.title)" }.joined(separator: "\n") )
                """)
                self.observeTabs()
            }
        }
    }
}

// MARK: - Static Helpers
extension BrowserCoordinator {
    internal static func makeConfig() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = dataStore
        config.defaultWebpagePreferences.preferredContentMode = .desktop
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsAirPlayForMediaPlayback = true
        config.preferences.isElementFullscreenEnabled = true
        config.preferences.inactiveSchedulingPolicy = .none
        config.suppressesIncrementalRendering = false
        
        return config
    }
    
    internal static func getDefaultWebkitView() -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: Self.makeConfig())
        
        webView.autoresizingMask = [.width, .height]
        webView.allowsMagnification = true
        
        webView.customUserAgent =
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
        return webView
    }
}
