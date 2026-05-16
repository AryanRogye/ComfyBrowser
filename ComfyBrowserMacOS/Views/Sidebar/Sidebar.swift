//
//  Sidebar.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import SwiftUI

struct Sidebar: View {

    @Environment(ComfyBrowserViewModel.self) var comfyBrowserVM
    @Bindable var browserController: BrowserCoordinator


    var body: some View {
        @Bindable var comfyBrowserVM = comfyBrowserVM

        if comfyBrowserVM.sidebarState == .open {
            SidebarView(
                faviconService: browserController.faviconService,
                tabs: $browserController.tabs,
                clickedTab: { tab in
                    /// if same just exit early
                    if browserController.selectedTab?.id == tab.id { return }
                    browserController.select(id: tab.id)
                },
                closeTab: { tab in
                    browserController.closeTab(id: tab.id)
                }
            )
            .frame(maxWidth: 200, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    VStack {
        SidebarView(
            //        SidebarContent(
            faviconService: FaviconService(),
            tabs: .constant([
                .init(
                    title: "DuckDuckGo",
                    url: URL(string: "https://duckduckgo.com")!,
                    isActive: true
                ),
                .init(
                    title: "GitHub",
                    url: URL(string: "https://github.com")!,
                    isActive: false
                ),
                .init(
                    title: "UIC Blackboard",
                    url: URL(string: "https://uic.blackboard.com")!,
                    isActive: false
                )
            ])
        ) { tab in } closeTab: { tab in }
            .padding()
    }
    .frame(width: 200, height: 510)
}
