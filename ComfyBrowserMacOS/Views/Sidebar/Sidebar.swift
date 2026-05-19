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
                pinnedNodes: $browserCoordinator.pinnedNodes,
                tabs: $browserCoordinator.tabs,
                clickedTab: { tab in
                    /// if same just exit early
                    if browserCoordinator.selectedTab?.id == tab.id { return }
                    browserCoordinator.select(id: tab.id)
                },
                closeTab: { tab in
                    browserCoordinator.closeTab(id: tab.id)
                },
                toggleFolder: { folderID in
                    browserCoordinator.togglePinnedFolder(id: folderID)
                },
                movePinnedTab: { tabID, index in
                    browserCoordinator.movePinnedTab(id: tabID, toPinnedIndex: index)
                },
                movePinnedFolder: { folderID, index in
                    browserCoordinator.movePinnedFolder(id: folderID, toFolderIndex: index)
                },
                moveRegularTab: { tabID, index in
                    browserCoordinator.moveRegularTab(id: tabID, toRegularIndex: index)
                },
                moveTabIntoFolder: { tabID, folderID in
                    browserCoordinator.movePinnedTab(
                        id: tabID,
                        intoFolder: folderID
                    )
                },
                unpinTab: { tabID in
                    browserCoordinator.unpinTab(id: tabID)
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
            pinnedNodes: .constant([
                .tab(
                    .init(
                        title: "Pinned GitHub",
                        url: URL(string: "https://github.com")!,
                        isActive: false
                    )
                ),
                .folder(
                    TabFolder(
                        title: "Work",
                        children: [
                            .tab(
                                .init(
                                    title: "Linear",
                                    url: URL(string: "https://linear.app")!,
                                    isActive: false
                                )
                            )
                        ]
                    )
                )
            ]),
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
        ) { tab in
        } closeTab: { tab in
        } toggleFolder: { folderID in
        } movePinnedTab: { tabID, index in
        } movePinnedFolder: { folderID, index in
        } moveRegularTab: { tabID, index in
        } moveTabIntoFolder: { tabID, folderID in
        } unpinTab: { tabID in
        }
            .padding()
    }
    .frame(width: 200, height: 510)
}
