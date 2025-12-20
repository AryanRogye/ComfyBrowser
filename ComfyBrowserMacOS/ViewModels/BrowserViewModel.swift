//
//  BrowserViewModel.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import Foundation
import WebKit

@Observable @MainActor
final class BrowserViewModel {
    
    var tabs : [Tab] = []
    var webViews : [UUID: WKWebView] = [:]
    
    var webView: WKWebView?
    var selectedTab : Tab?
    var currentRequest : URLRequest?
    
    init() {
        selectedTab = createTempTab()
        webView = getDefaultWebkitView()
        
        guard let webView, let selectedTab else { return }
        
        // Create the request first
        let request = URLRequest(url: selectedTab.url)
        self.currentRequest = request
        
        // Then load it
        webView.load(request)
    }
    
    @discardableResult
    public func createTab() -> (Tab, WKWebView) {
        /// Get default webView
        let webView = getDefaultWebkitView()
        /// Create a new Tab
        let newTab = createTempTab()
        
        /// Add to webViews dictionary
        webViews[newTab.id] = webView
        /// Append to tabs array
        tabs.append(newTab)
        return (newTab, webView)
    }
    
    private func createTempTab() -> Tab {
        let newTab = Tab(
            title: "New Tab",
            url: URL(string: "https://google.com/")!,
            isActive: true
        )
        return newTab
    }
    
    private func getDefaultWebkitView() -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsAirPlayForMediaPlayback = true
        
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        return webView
    }
}
