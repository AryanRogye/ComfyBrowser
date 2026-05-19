//
//  SidebarNode.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/17/26.
//

import Foundation

struct SidebarTabState {
    var pinnedNodes: [SidebarNode] = []
    var regularTabs: [Tab] = []
}

enum SidebarNode: Hashable, Equatable {
    case tab(Tab)
    case folder(TabFolder)

    var id: UUID {
        switch self {
        case .tab(let tab):
            tab.id
        case .folder(let tabFolder):
            tabFolder.id
        }
    }

    /// Collects every pinned tab ID, including tabs inside folders.
    public static func pinnedTabIDs(in nodes: [SidebarNode]) -> Set<UUID> {
        nodes.reduce(into: Set<UUID>()) { ids, node in
            switch node {
            case .tab(let tab):
                ids.insert(tab.id)
            case .folder(let folder):
                ids.formUnion(pinnedTabIDs(in: folder.children))
            }
        }
    }
}
