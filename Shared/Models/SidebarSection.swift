//
//  SidebarSection.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/18/26.
//

enum SidebarSection: Int, CaseIterable {
    case pinnedTabs
    case folders
    case regularTabs

    var title: String {
        switch self {
        case .pinnedTabs:
            return "Pinned Tabs"
        case .folders:
            return "Folders"
        case .regularTabs:
            return "Regular Tabs"
        }
    }
}
