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
    var selectedTab : Tab?
    var searchEngine: SearchEngine = .duckDuckGo
    
    let faviconService = FaviconService()
    let searchCoordinator = SearchCoordinator()

    var webView: WKWebView
    
    init() {
        webView = Self.getDefaultWebkitView()
        observeTabs()
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
            updateURL(at: index, url: url)
            searchCoordinator.recordHistoryVisit(url: url, title: title)
        }
        
        updateTitle(at: index, title: title)
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
            return
        }
        
        if closingSelected {
            let newIndex = min(index, tabs.count - 1)
            select(id: tabs[newIndex].id)
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
    }
}

// MARK: - Tab Mutation
extension BrowserCoordinator {
    
    /// Updates a tab's current URL and appends a new history entry.
    internal func updateURL(at index: Int, url: URL) {
        guard tabs.indices.contains(index) else { return }
        
        /// add new URL to the history
        tabs[index].history.append(
            .init(
                url: url,
                visitedAt: .now
            )
        )
        tabs[index].url = url
        tabs[index].historyIndex += 1
    }
    
    /// Updates a tab's display title.
    internal func updateTitle(at index: Int, title: String) {
        guard tabs.indices.contains(index) else { return }
        tabs[index].title = title
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
