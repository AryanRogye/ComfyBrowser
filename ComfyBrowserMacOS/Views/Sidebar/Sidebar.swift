//
//  Sidebar.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import SwiftUI

struct Sidebar: View {

    @Environment(ComfyBrowserViewModel.self) var comfyBrowserVM
    @Bindable var browserCoordinator: BrowserCoordinator


    var body: some View {
        @Bindable var comfyBrowserVM = comfyBrowserVM

        if comfyBrowserVM.sidebarState == .open {
            SidebarView(
                faviconService: browserCoordinator.faviconService,
                sidebar: $browserCoordinator.sidebar,
                selectedTab: $browserCoordinator.selectedTab,
                clickedTab: { tab in
                    /// if same just exit early
                    if browserCoordinator.selectedTab?.id == tab.id { return }
                    browserCoordinator.select(id: tab.id)
                },
                closeTab: { tab in
                    browserCoordinator.closeTab(id: tab.id)
                },
                clickedFolder: { folder in
                    print("""
                    Clicked Folder: \(folder.title) (\(folder.id))
                    Expanded: \(folder.isExpanded)
                    """)
                    browserCoordinator.toggleFolder(id: folder.id)
                }
            )
            .frame(maxWidth: 200, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {

    @Previewable @State  var browserCoordinator = BrowserCoordinator()
    @Previewable @State  var comfyBrowserState = ComfyBrowserViewModel()

    ZStack {
        LinearGradient(
            colors: [.red.opacity(0.5), .red.opacity(0.7), .pink.opacity(0.9)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack {
            SidebarView(
                //        SidebarContent(
                faviconService: browserCoordinator.faviconService,
                sidebar: $browserCoordinator.sidebar,
                selectedTab: $browserCoordinator.selectedTab,
            ) { tab in } closeTab: { tab in } clickedFolder: { folder in }
                .padding()
        }
    }
    .frame(width: 200, height: 510)
    .task {
        browserCoordinator.selectedTab = browserCoordinator.sidebar.tabs.first!
    }
}
