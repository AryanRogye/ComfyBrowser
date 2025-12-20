//
//  TabViewModel.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/23/25.
//

import Combine
import WebKit

class TabViewModel: ObservableObject {
    
    @Published var tab: Tab
    @Published var webView: WKWebView? = nil
    
    private let tabService : TabService
    let deps: BrowserViewDeps
    
    init(
        tab: Tab,
        deps: BrowserViewDeps
    ) {
        self.deps = deps
        self.tab = tab
        self.tabService = deps.tabService
        self.webView = getCurrentWebView()
        self.webView?.load(URLRequest(url: tab.url))
    }
    
    public func getCurrentWebView() -> WKWebView? {
        return tabService.getTabView(by: tab.id)
    }
}
