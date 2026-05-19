//
//  TabFolder.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/17/26.
//

import Foundation

struct TabFolder: Hashable, Identifiable, Equatable {
    let id = UUID()
    var title: String
    var children: [SidebarNode] = []
    var isExpanded = true

    static func == (lhs: TabFolder, rhs: TabFolder) -> Bool {
        lhs.id == rhs.id
        && lhs.title == rhs.title
        && lhs.children == rhs.children
        && lhs.isExpanded == rhs.isExpanded
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
