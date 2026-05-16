//
//  ComfyBrowserMacOSApp.swift
//  ComfyBrowserMacOS
//
//  Created by Aryan Rogye on 11/18/25.
//

import SwiftUI
import WebKit

@main
struct ComfyBrowserMacOSApp: App {

    @State private var browserController = BrowserCoordinator()
    @State private var comfyBrowserViewModel = ComfyBrowserViewModel()

    var body: some Scene {
        WindowGroup {
                ComfyBrowserRoot()
                    .environment(browserController)
                    .environment(comfyBrowserViewModel)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
