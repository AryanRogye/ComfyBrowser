//
//  SidebarSectionKind.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/19/26.
//

enum SidebarSectionKind: Int, Codable, Hashable, Sendable {
    case pinned  = 0
    case saved   = 1
    case regular = 2
}
