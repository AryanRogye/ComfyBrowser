//
//  ComfyBrowserView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/23/25.
//

import SwiftUI
import WebKit

struct ComfyBrowserView: View {
    
    var webView: WKWebView
    @Binding var tab: Tab
    @StateObject var viewModel: ComfyBrowserViewModel
    
    init(
        webView: WKWebView,
        tab: Binding<Tab>,
        deps: BrowserViewDeps
    ) {
        self.webView = webView
        self._tab = tab
        self._viewModel = StateObject(
            wrappedValue: ComfyBrowserViewModel(
                deps: deps,
                tab: tab
            ))
    }
    
    var body: some View {
        ComfyBrowserFrame(topContent: {
            ComfyBrowserTopDashboard()
        }, mainContent: {
            ComfyWebView(
                webView: webView,
                tab: $tab,
                currentRequest: $viewModel.currentRequest,
                onURLChange: { url in
//                    viewModel.addTab(with: url)
                }, onClose: { url in
                    tab.url = url ?? tab.url
                }
            )
        }, bottomContent: {
            ComfyBrowserBottomDashboard()
            
        })
        .environmentObject(viewModel)
    }
}


#Preview {
    
    let appEnv = AppEnv()
    let tab = appEnv.tabService.createTab()
    
    BrowserView(
        tab: tab
    )
    .environmentObject(
        TabViewModel(
            tab: tab,
            deps: appEnv
        )
    )
    .environmentObject(NavigationViewModel())
}
