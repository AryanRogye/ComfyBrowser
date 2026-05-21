//
//  SidebarNode.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/19/26.
//

import Foundation

enum SidebarNode: Hashable, Equatable, Codable, Sendable {
    case tab(Tab)
    case folder(Folder)

    var id: UUID {
        switch self {
        case .tab(let tab):
            tab.id
        case .folder(let tabFolder):
            tabFolder.id
        }
    }
}
