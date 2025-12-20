//
//  WebViewContainer.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import WebKit
import SwiftUI

struct WebView: View {
    @Environment(BrowserViewModel.self) var browserVM
    
    var body: some View {
        @Bindable var browserVM = browserVM
        if let webView = browserVM.webView {
            WebViewContainer(
                currentRequest: $browserVM.currentRequest,
                webView: webView
            )
        }
    }
}

struct WebViewContainer: NSViewRepresentable {
    
    @Binding var currentRequest: URLRequest?
    var webView : WKWebView
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    init(
        currentRequest : Binding<URLRequest?>,
        webView: WKWebView
    ) {
        self._currentRequest = currentRequest
        self.webView = webView
    }
    
    func makeNSView(context: Context) -> WKWebView {
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        if let request = currentRequest {
            webView.load(request)
        }
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        if let request = currentRequest {
            if nsView.url?.absoluteString != request.url?.absoluteString {
                nsView.load(request)
            }
        }
    }
    
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
    }
}
