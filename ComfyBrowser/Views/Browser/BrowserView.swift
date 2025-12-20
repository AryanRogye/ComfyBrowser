//
//  BrowserView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/22/25.
//

import SwiftUI
import WebKit

struct BrowserView: View {
    
    let tab: Tab
    @EnvironmentObject var viewModel: TabViewModel
    
    init(tab: Tab) {
        self.tab = tab
    }
    
    var body: some View {
        Group {
            if let view = viewModel.webView {
                ComfyBrowserView(
                    webView: view,
                    tab: $viewModel.tab,
                    deps: viewModel.deps
                )
            } else {
                Text("No WebView Available")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
}
