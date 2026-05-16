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
    var currentRequest : URLRequest?
    var searchEngine: SearchEngine = .duckDuckGo

    var webView: WKWebView
    var cancellables : Set<AnyCancellable> = []

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
        self.webView = Self.getDefaultWebkitView()

        var newTab: Tab?
        if let value {
            newTab = createTabWith(value)
        } else {
            /// Create a new Tab
            newTab = createTempTab()
        }
        guard let newTab else { return }

        /// Append to tabs array
        tabs.append(newTab)
        selectedTab = newTab
        let req = URLRequest(url: newTab.url)
        currentRequest = req

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

// MARK: - Tab Management
extension BrowserViewModel {
    public func select(tab: Tab) {
        self.selectedTab = tab
        let request = URLRequest(url: tab.url)
        self.currentRequest = request
        self.webView.load(request)
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
                print("Tabs Changed:\n" + self.tabs.map { "• \($0.title)" }.joined(separator: "\n"))
                self.observeTabs()
            }
        }
    }
}

// MARK: - Helpers
extension BrowserViewModel {
    internal static func getDefaultWebkitView() -> WKWebView {
        let config = WKWebViewConfiguration()
        
        config.websiteDataStore = dataStore
        config.defaultWebpagePreferences.preferredContentMode = .desktop
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsAirPlayForMediaPlayback = true
        
        config.preferences.isElementFullscreenEnabled = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        
        webView.autoresizingMask = [.width, .height]
        
        webView.customUserAgent =
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
        return webView
    }
}
