//
//  WebViewContainer.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import SwiftUI
import WebKit

struct WebView: View {
    @Environment(BrowserCoordinator.self) var browserCoordinator

    var body: some View {
        @Bindable var browserCoordinator = browserCoordinator
        WebViewContainer(
            webView: browserCoordinator.webView,
            onURLOrTitleChange: { url, title in
                guard let url, let title else { return }
                browserCoordinator.updateSelectedTab(url: url, title: title)
            },
            onNavigationAvailabilityChange: { canGoBack, canGoForward in
                browserCoordinator.updateNavigationAvailability(
                    canGoBack: canGoBack,
                    canGoForward: canGoForward
                )
            }
        )
        .id(ObjectIdentifier(browserCoordinator.webView))
    }
}

struct WebViewContainer: NSViewRepresentable {

    var webView: WKWebView
    var onURLOrTitleChange: @MainActor (URL?, String?) -> Void
    var onNavigationAvailabilityChange: @MainActor (Bool, Bool) -> Void

    func makeCoordinator() -> WebViewCoordinator {
        return WebViewCoordinator(
            onURLOrTitleChange: onURLOrTitleChange,
            onNavigationAvailabilityChange: onNavigationAvailabilityChange
        )
    }

    func makeNSView(context: Context) -> WKWebView {
        
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        context.coordinator.startObservingState(of: webView)
        
        /// Configurations
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
}

class WebViewCoordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
    
    var onURLOrTitleChange: @MainActor (URL?, String?) -> Void
    var onNavigationAvailabilityChange: @MainActor (Bool, Bool) -> Void
    
    private var urlObservation: NSKeyValueObservation?
    private var titleObservation: NSKeyValueObservation?
    private var canGoBackObservation: NSKeyValueObservation?
    private var canGoForwardObservation: NSKeyValueObservation?

    init(
        onURLOrTitleChange: @escaping @MainActor (URL?, String?) -> Void,
        onNavigationAvailabilityChange: @escaping @MainActor (Bool, Bool) -> Void
    ) {
        self.onURLOrTitleChange = onURLOrTitleChange
        self.onNavigationAvailabilityChange = onNavigationAvailabilityChange
        super.init()
    }
    
    deinit {
        urlObservation?.invalidate()
        titleObservation?.invalidate()
        canGoBackObservation?.invalidate()
        canGoForwardObservation?.invalidate()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Also update on didFinish to catch the final page title after DOM settles
        notifyStateChange(from: webView)
        notifyNavigationAvailability(from: webView)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        print("Started provisional navigation (requesting URL). Show loading indicator.")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("Content started arriving. DOM is receiving data.")
        notifyNavigationAvailability(from: webView)
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
    
    /// Observes page identity and navigation availability for the active web view.
    func startObservingState(
        of webView: WKWebView
    ) {
        /// Saftey
        urlObservation?.invalidate()
        titleObservation?.invalidate()
        canGoBackObservation?.invalidate()
        canGoForwardObservation?.invalidate()
        
        urlObservation = webView.observe(\.url, options: [.new]) { [weak self] view, _ in
            DispatchQueue.main.async {
                self?.notifyStateChange(from: view)
            }
        }
        
        titleObservation = webView.observe(\.title, options: [.new]) { [weak self] view, _ in
            DispatchQueue.main.async {
                self?.notifyStateChange(from: view)
            }
        }
        
        canGoBackObservation = webView.observe(\.canGoBack, options: [.initial, .new]) { [weak self] view, _ in
            DispatchQueue.main.async {
                self?.notifyNavigationAvailability(from: view)
            }
        }
        
        canGoForwardObservation = webView.observe(\.canGoForward, options: [.initial, .new]) { [weak self] view, _ in
            DispatchQueue.main.async {
                self?.notifyNavigationAvailability(from: view)
            }
        }
    }
    
    private func notifyStateChange(from view: WKWebView) {
        let url = view.url
        let title = view.title
        
        Task { @MainActor in
            onURLOrTitleChange(url, title)
        }
    }
    
    private func notifyNavigationAvailability(from view: WKWebView) {
        let canGoBack = view.canGoBack
        let canGoForward = view.canGoForward
        
        Task { @MainActor in
            onNavigationAvailabilityChange(canGoBack, canGoForward)
        }
    }
}
