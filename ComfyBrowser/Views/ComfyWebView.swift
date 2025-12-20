//
//  HomeView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/22/25.
//

import SwiftUI
import UIKit
import WebKit


struct ComfyWebView: UIViewRepresentable {
    
    @Binding var currentRequest: URLRequest?
    @Binding var tab: Tab
    private var webView: WKWebView
    
    private var onURLChange: (URL) -> Void
    private var onClose: (URL?) -> Void

    init(
        webView: WKWebView,
        tab: Binding<Tab>,
        currentRequest: Binding<URLRequest?>,
        onURLChange: @escaping (URL) -> Void,
        onClose: @escaping (URL?) -> Void
    ) {
        self.webView = webView
        self._tab = tab
        self._currentRequest = currentRequest
        self.onURLChange = onURLChange
        self.onClose = onClose
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator {  url in
            onURLChange(url)
        } onClose: { url in
            onClose(url)
        }
    }
    
    
    func makeUIView(context: Context) -> WKWebView {
        
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        //        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let result = currentRequest {
            if uiView.url?.absoluteString != result.url?.absoluteString {
                
                uiView.load(result)
                
            }
        }
    }
    
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        
        private var hasLaunchedOnce: Bool = false
        public var shouldShowNewTab: Bool = false
        
        public var onURLChange: (URL) -> Void
        
        private var retainedPopups: [WKWebView] = []
        private var popupDelegates: [ObjectIdentifier: PopupCatcherDelegate] = [:]
        
        private(set) var lastURL: URL?
        private var onClose: (URL?) -> Void
        
        init(
            onURLChange: @escaping (URL) -> Void,
            onClose: @escaping (URL?) -> Void
        ) {
            self.onURLChange = onURLChange
            self.onClose = onClose
        }
        
        deinit {
            onClose(lastURL)  // persist whatever the last URL was
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            if let u = webView.url { lastURL = u; onURLChange(u) }
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let u = webView.url { lastURL = u; onURLChange(u) }
        }
        
        /// For Popups
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            
            // Return a child so WebKit has somewhere to load first
            let child = WKWebView(frame: .zero, configuration: configuration)
            retainedPopups.append(child)
            
            // Retain the delegate (navigationDelegate is weak)
            let catcher = PopupCatcherDelegate { [weak self, weak child] req in
                // Hand off to your tab system
                self?.onURLChange(req.url ?? URL(string: "google.com")!)
                
                // Cleanup retain cycles
                if let child = child {
                    self?.retainedPopups.removeAll { $0 === child }
                    self?.popupDelegates.removeValue(forKey: ObjectIdentifier(child))
                }
            }
            popupDelegates[ObjectIdentifier(child)] = catcher
            child.navigationDelegate = catcher
            return child
        }
        
        private final class PopupCatcherDelegate: NSObject, WKNavigationDelegate {
            private var handled = false
            private let onFirstMainFrame: (URLRequest) -> Void
            init(_ onFirstMainFrame: @escaping (URLRequest) -> Void) { self.onFirstMainFrame = onFirstMainFrame }
            
            func webView(_ webView: WKWebView,
                         decidePolicyFor action: WKNavigationAction,
                         decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
                
                if !handled, action.targetFrame?.isMainFrame == true, let _ = action.request.url {
                    handled = true
                    onFirstMainFrame(action.request)    // hand off to your tabs
                    decisionHandler(.cancel)            // stop child from navigating
                    return
                }
                decisionHandler(.allow)
            }
        }
        
    }
}
