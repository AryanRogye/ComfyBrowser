//
//  TabManager.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/22/25.
//

import WebKit
import Foundation
import Combine

class TabManager: TabService, ObservableObject {
    
    @Published var tabs: [Tab] = []
    var tabsPublisher: AnyPublisher<[Tab], Never> {
        $tabs.eraseToAnyPublisher()
    }
    var webViews : [UUID: WKWebView] = [:]
    
    // MARK: - Create Tab
    
    /// Function will create a tab, `see protocol TabService`
    public func createTab() -> Tab {
        /// Get default webView
        let webView = getDefaultWebkitView()
        /// Create a new Tab
        let newTab = createTempTab()
        
        /// Add to webViews dictionary
        webViews[newTab.id] = webView
        /// Append to tabs array
        tabs.append(newTab)
        return newTab
    }
    
    func createTab(with request: URLRequest) -> Tab {
        /// Get default webView
        let webView = getDefaultWebkitView()
        let newTab = Tab(
            title: "New Tab",
            url: request.url ?? URL(string: "https://google.com/")!,
            isActive: true
        )
        
        /// Add to webViews dictionary
        webViews[newTab.id] = webView
        /// Append to tabs array
        tabs.append(newTab)
        return newTab
    }

    
    public func createTempTab(with url: URL) -> Tab {
        let newTab = Tab(
            title: "New Tab",
            url: url,
            isActive: true
        )
        return newTab
    }
    
    public func createTempTab() -> Tab {
        let newTab = Tab(
            title: "New Tab",
            url: URL(string: "https://google.com/")!,
            isActive: true
        )
        return newTab
    }
    
    public func getTabView(by id: UUID) -> WKWebView? {
        return webViews[id]
    }
    
    public func getTab(at index: Int) -> Tab? {
        return tabs.first(where: { $0.id == tabs[index].id })
    }
    
    public func addTab(_ tab: Tab) {
        let webView = getDefaultWebkitView()
        webViews[tab.id] = webView
        tabs.append(tab)
    }
    public func setTabResponse(for id: UUID, with response: URLResponse) {
        guard let webView = webViews[id], let url = response.url else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func getTabCount() -> Int {
        return tabs.count
    }
    
    private func getDefaultWebkitView() -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsPictureInPictureMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true
        
        
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }
}
