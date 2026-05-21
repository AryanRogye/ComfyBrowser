//
//  Folder.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/19/26.
//

import Foundation

struct Folder: Codable, Hashable, Identifiable, Equatable, Sendable {
    let id: UUID
    var title: String
    var children: [SidebarNode] = []
    var isExpanded = false

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case children
        case isExpanded
    }

    init(
        title: String,
    ) {
        self.id = UUID()
        self.title = title
    }

    init(
        title: String,
        children: [SidebarNode]
    ) {
        self.id = UUID()
        self.title = title
        self.children = children
    }

    static func == (lhs: Folder, rhs: Folder) -> Bool {
        lhs.id == rhs.id
        && lhs.title == rhs.title
        && lhs.children == rhs.children
        && lhs.isExpanded == rhs.isExpanded
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        children = try container.decode([SidebarNode].self, forKey: .children)
        isExpanded = try container.decode(Bool.self, forKey: .isExpanded)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(children, forKey: .children)
        try container.encode(isExpanded, forKey: .isExpanded)
    }
}
