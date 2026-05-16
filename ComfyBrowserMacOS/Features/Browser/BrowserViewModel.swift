//
//  BrowserViewModel.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import Foundation
import WebKit
import Combine

@Observable
@MainActor
final class BrowserViewModel {

    static let dataStore: WKWebsiteDataStore = .default()

    var tabs : [Tab] = []
    var selectedTab : Tab?
    var searchEngine: SearchEngine = .duckDuckGo
    
    let faviconService = FaviconService()

    var webView: WKWebView
    

    init() {
        webView = Self.getDefaultWebkitView()
        observeTabs()
    }

    func updateNameAtIndex(_ index: Int, to newName: String) {
        guard index >= 0, index < tabs.count else { return }
        var tab = tabs[index]
        tab.title = newName
        tabs[index] = tab
        print("Updated Tab At Index: \(index) With Name: \(newName)")
    }

    public func createTab(_ value: String? = nil) {
        /// Get default webView
        let newWebView = Self.getDefaultWebkitView()

        var newTab: Tab?
        if let value {
            newTab = createTabWith(value)
        } else {
            /// Create a new Tab
            newTab = createTempTab()
        }
        guard var newTab else { return }

        newWebView.load(URLRequest(url: newTab.url))
        newTab.retainedWebView = newWebView
        
        /// Append to tabs array
        tabs.append(newTab)
        selectedTab = newTab
        webView = newWebView
        
        print("Current Tab Count: \(tabs.count)")
    }

    private func createTabWith(_ value: String) -> Tab? {
        // Normalize input into a loadable URL
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Decide if input is likely a URL or a search query
        let hasScheme = trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://")
        let looksLikeDomain = trimmed.contains(".") && !trimmed.contains(" ")

        var finalURL: URL?
        if hasScheme {
            finalURL = URL(string: trimmed)
        } else if looksLikeDomain {
            // Prepend https:// for bare domains
            finalURL = URL(string: "https://\(trimmed)")
        } else {
            // Treat as a search query
            finalURL = searchEngine.search(for: trimmed)
        }

        guard let url = finalURL else { return nil }

        let title = trimmed

        let newTab = Tab(
            title: title,
            url: url,
            isActive: true
        )
        return newTab
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

// MARK: - Tab Mutation
extension BrowserViewModel {
    public func updateURL(at index: Int, url: URL) {
        guard tabs.indices.contains(index) else { return }
        tabs[index].url = url
    }
    public func updateTitle(at index: Int, title: String) {
        guard tabs.indices.contains(index) else { return }
        tabs[index].title = title
    }
    public func saveRetainedWebView(for tab: Tab, webview: WKWebView) {
        guard let index = tabs.firstIndex(where: { $0.id == tab.id }) else { return }
        guard tabs.indices.contains(index) else { return }
        tabs[index].retainedWebView = webview
    }

}

// MARK: - Tab Management
extension BrowserViewModel {
    
    public func updateURLAndTitle(_ url: URL?, _ title: String?) {
        if let url, let title {
            /// find the browser tab in the tabs array
            guard let selectedTab = selectedTab else { return }
            guard let index = tabs.firstIndex(where: { $0.id == selectedTab.id }) else { return }
            
            updateURL(at: index, url: url)
            updateTitle(at: index, title: title)
        }
    }
    
    internal func saveCurrentTab() {
        if let currentTab = self.selectedTab {
            self.saveRetainedWebView(for: currentTab, webview: webView)
        }
    }
    
    public func closeTab(id: UUID) {
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

// MARK: - Observations
extension BrowserViewModel {
    
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

// MARK: - Helpers
extension BrowserViewModel {
    
    internal static func makeConfig() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = dataStore
        config.defaultWebpagePreferences.preferredContentMode = .desktop
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsAirPlayForMediaPlayback = true
        config.preferences.isElementFullscreenEnabled = true
        config.preferences.inactiveSchedulingPolicy = .suspend
        
        return config
    }
    
    internal static func getDefaultWebkitView() -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: Self.makeConfig())
        
        webView.autoresizingMask = [.width, .height]
        
        webView.customUserAgent =
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
        return webView
    }
}
