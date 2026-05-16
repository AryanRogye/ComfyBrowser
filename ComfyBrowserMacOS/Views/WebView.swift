//
//  WebViewContainer.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import SwiftUI
import WebKit

struct WebView: View {
    @Environment(BrowserViewModel.self) var browserVM

    var body: some View {
        @Bindable var browserVM = browserVM
        WebViewContainer(
            webView: browserVM.webView,
            onURLOrTitleChange: { url, title in
                if let url, let title {
                    /// find the browser tab in the tabs array
                    guard let selectedTab = browserVM.selectedTab else { return }
                    guard let index = browserVM.tabs.firstIndex(where: { $0.id == selectedTab.id }) else { return }
                    
                    browserVM.tabs[index].url = url
                    browserVM.tabs[index].title = title
                }
            }
        )
        .id(ObjectIdentifier(browserVM.webView))
    }
}

struct WebViewContainer: NSViewRepresentable {

    var webView: WKWebView
    var onURLOrTitleChange: (URL?, String?) -> Void

    func makeCoordinator() -> WebViewCoordinator {
        return WebViewCoordinator(onURLOrTitleChange: onURLOrTitleChange)
    }

    func makeNSView(context: Context) -> WKWebView {
        
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        context.coordinator.startObservingURL(of: webView)
        
        /// Configurations
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
}

class WebViewCoordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
    
    var onURLOrTitleChange: (URL?, String?) -> Void
    
    private var urlObservation: NSKeyValueObservation?
    private var titleObservation: NSKeyValueObservation?
    
    private var lastObservedURL: URL?
    
    init(onURLOrTitleChange: @escaping (URL?, String?) -> Void) {
        self.onURLOrTitleChange = onURLOrTitleChange
        super.init()
    }
    
    deinit {
        urlObservation?.invalidate()
        titleObservation?.invalidate()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Also update on didFinish to catch the final page title after DOM settles
        notifyStateChange(from: webView)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        print("Started provisional navigation (requesting URL). Show loading indicator.")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("Content started arriving. DOM is receiving data.")
    }
    
    func webView(
        _ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error
    ) {
        print("Navigation failed:", error.localizedDescription)
    }
    
    func webView(
        _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        print("Provisional navigation failed:", error.localizedDescription)
    }
    
    /// Observing webview
    func startObservingURL(
        of webView: WKWebView
    ) {
        /// Saftey
        urlObservation?.invalidate()
        titleObservation?.invalidate()
        
        urlObservation = webView.observe(\.url, options: [.new]) { [weak self] view, _ in
            self?.notifyStateChange(from: view)
        }
        
        titleObservation = webView.observe(\.title, options: [.new]) { [weak self] view, _ in
            self?.notifyStateChange(from: view)
        }
    }
    
    private func notifyStateChange(from view: WKWebView) {
        onURLOrTitleChange(view.url, view.title)
    }
}
