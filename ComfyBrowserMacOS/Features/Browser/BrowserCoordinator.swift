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

    var sidebar = SidebarModel()
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
        observeFolders()
        observePinned()
        observeRegularTabs()
    }
}

// MARK: - Search
extension BrowserCoordinator {
    
    /// Search "String"
    public func search(_ value: String, inPlace: Bool = false) {
        
        let openInPlace = inPlace && !sidebar.tabs.isEmpty

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
            tabs: sidebar.tabs
        )
    }
    
    /// Clicking a Suggestion
    public func openSuggestion(
        _ suggestion: SearchSuggestion,
        inPlace: Bool = false
    ) {
        
        let openInPlace = inPlace && !sidebar.tabs.isEmpty

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
    /// sidebar model
    internal func createTab(
        url: URL,
        title: String
    ) {
        let (tab, newWebView) = createTabConfig(url: url, title: title)
        
        sidebar.insert(.tab(tab), into: .regular)
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

        let didURLChange = selectedTab.url != url

        /// Ony Update and add to history if url is not the same
        if didURLChange {
            updateURL(tabID: selectedTab.id, url: url, title: title)
            searchCoordinator.recordHistoryVisit(url: url, title: title)
        }
        
        updateTitle(tabID: selectedTab.id, title: title)
        self.selectedTab = sidebar.findTab(id: selectedTab.id)
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
        let tabsBeforeClose = sidebar.tabs
        guard let closingIndex = tabsBeforeClose.firstIndex(where: { $0.id == id }) else {
            return
        }

        let closingSelected = selectedTab?.id == id

        _ = sidebar.closeTab(id: id)

        guard !sidebar.tabs.isEmpty else {
            selectedTab = nil
            webView.stopLoading()
            webView = Self.getDefaultWebkitView()
            webView.load(URLRequest(url: createTempTab().url))
            refreshNavigationAvailability()
            return
        }

        if closingSelected {
            let newIndex = min(closingIndex, sidebar.tabs.count - 1)
            select(id: sidebar.tabs[newIndex].id)
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
    /// if its a folder will just ignore for now
    ///
    /// Example:
    ///     select(id: tab.id)
    public func select(id: UUID) {
        
        saveCurrentTab()

        guard let storedTab = sidebar.findTab(id: id) else { return }

        if let webview = storedTab.retainedWebView {
            self.webView = webview
        } else {
            let newWebView = Self.getDefaultWebkitView()
            newWebView.load(URLRequest(url: storedTab.url))
            
            sidebar.updateTab(id: id) { tab in
                tab.retainedWebView = newWebView
            }
            self.webView = newWebView
        }

        self.selectedTab = sidebar.findTab(id: id) ?? storedTab
        refreshNavigationAvailability()
    }
}

// MARK: - Tab Mutation
extension BrowserCoordinator {
    
    /// Updates a tab's current URL and keeps its metadata history valid.
    internal func updateURL(tabID: UUID, url: URL, title: String?) {
        sidebar.updateTab(id: tabID) { tab in

            clampHistoryIndex(for: &tab)

            guard !tab.history.isEmpty else {
                tab.history = [
                    .init(
                        url: url,
                        title: title,
                        visitedAt: .now
                    )
                ]
                tab.url = url
                tab.historyIndex = 0
                return
            }

            let currentIndex = tab.historyIndex

            if tab.history[currentIndex].url == url {
                tab.url = url
                tab.history[currentIndex].title = title
                return
            }

            if currentIndex > 0 && tab.history[currentIndex - 1].url == url {
                tab.historyIndex = currentIndex - 1
                tab.url = url
                updateCurrentHistoryTitle(for: &tab, title: title)
                return
            }

            let nextIndex = currentIndex + 1
            if tab.history.indices.contains(nextIndex),
               tab.history[nextIndex].url == url {
                tab.historyIndex = nextIndex
                tab.url = url
                updateCurrentHistoryTitle(for: &tab, title: title)
                return
            }

            if currentIndex < tab.history.count - 1 {
                tab.history.removeSubrange((currentIndex + 1)...)
            }

            tab.history.append(
                .init(
                    url: url,
                    title: title,
                    visitedAt: .now
                )
            )
            tab.url = url
            tab.historyIndex = tab.history.count - 1
        }
    }
    
    /// Updates a tab's display title.
    internal func updateTitle(tabID: UUID, title: String) {
        sidebar.updateTab(id: tabID) { tab in
            tab.title = title
            updateCurrentHistoryTitle(for: &tab, title: title)
        }
    }
    
    /// Stores the active `WKWebView` instance back into the matching tab.
    internal func saveRetainedWebView(for tab: Tab, webview: WKWebView) {
        sidebar.updateTab(id: tab.id) { tab in
            tab.retainedWebView = webview
        }
    }
    
    /// Persists the currently displayed `WKWebView` into the selected tab.
    internal func saveCurrentTab() {
        guard let currentTab = selectedTab else { return }
        self.saveRetainedWebView(for: currentTab, webview: webView)
    }
    
    /// Keeps `historyIndex` inside the available per-tab history range.
    internal func clampHistoryIndex(for tab: inout Tab) {
        guard !tab.history.isEmpty else {
            tab.historyIndex = 0
            return
        }

        tab.historyIndex = min(
            max(tab.historyIndex, 0),
            tab.history.count - 1
        )
    }

    /// Updates the title on the current per-tab history entry.
    internal func updateCurrentHistoryTitle(for tab: inout Tab, title: String?) {
        clampHistoryIndex(for: &tab)

        guard !tab.history.isEmpty else { return }
        tab.history[tab.historyIndex].title = title
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
    func observeFolders() {
        withObservationTracking {
            _ = sidebar.folders
        } onChange: { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                print("""
                Folders Changed:
                \(self.sidebar.folders.map { node in
                    switch node {
                case .tab(let tab):
                        "• \(tab.title)"
                case .folder(let folder):
                        "• \(folder.title)"
                }
                }.joined(separator: "\n") )
                """)
                self.observeFolders()
            }
        }
    }
    func observePinned() {
        withObservationTracking {
            _ = sidebar.pinned
        } onChange: { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                print("""
                Pinned Changed:
                \(self.sidebar.pinned.map { node in
                    switch node {
                case .tab(let tab):
                        "• \(tab.title)"
                case .folder(let folder):
                        "• \(folder.title)"
                }
                }.joined(separator: "\n") )
                """)
                self.observePinned()
            }
        }
    }

    func observeRegularTabs() {
        withObservationTracking {
            _ = sidebar.regular
        } onChange: { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                print("""
                Tabs Changed:
                \(self.sidebar.regular.map { node in
                    switch node {
                case .tab(let tab):
                        "• \(tab.title)"
                case .folder(let folder):
                        "• \(folder.title)"
                }
                }.joined(separator: "\n") )
                """)
                self.observeRegularTabs()
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
