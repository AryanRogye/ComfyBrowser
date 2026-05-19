//
//  Tab.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/23/25.
//

import Foundation
import WebKit


struct SidebarModel: Codable, Hashable {
    var sections: [SidebarSection] = [
        .init(kind: .pinned, nodes: []),
        .init(kind: .folders, nodes: []),
        .init(kind: .regular, nodes: [])
    ]

    func findTab(id: UUID) -> Tab? {
        for section in sections {
            if let tab = section.nodes.findTab(id: id) { return tab }
        }
        return nil
    }

    var allTabs: [Tab] {
        sections.flatMap { $0.nodes.allTabs() }
    }

    mutating func moveTab(
        id: UUID,
        to sectionKind: SidebarSectionKind,
        index: Int
    ) {
        guard let tab = removeTab(id: id) else { return }

        insert(
            .tab(tab),
            into: sectionKind,
            at: index
        )
    }

    mutating func insert(
        _ node: SidebarNode,
        into sectionKind: SidebarSectionKind,
        at index: Int
    ) {
        guard let sectionIndex = sections.firstIndex(where: { $0.kind == sectionKind }) else { return }

        let safeIndex = min(max(index, 0), sections[sectionIndex].nodes.count)
        sections[sectionIndex].nodes.insert(node, at: safeIndex)
    }

    mutating func removeTab(id: UUID) -> Tab? {
        for sectionIndex in sections.indices {
            if let tab = sections[sectionIndex].nodes.removeTab(id: id) {
                return tab
            }
        }

        return nil
    }

    mutating func removeFolder(id: UUID) -> Folder? {
        for sectionIndex in sections.indices {
            if let folder = sections[sectionIndex].nodes.removeFolder(id: id) {
                return folder
            }
        }

        return nil
    }
}

struct SidebarSection: Codable, Hashable, Identifiable {
    var id: SidebarSectionKind { kind }
    var kind: SidebarSectionKind
    var nodes: [SidebarNode]

}

enum SidebarSectionKind: Codable, Hashable {
    case pinned
    case folders
    case regular
}

enum SidebarNode: Hashable, Equatable, Codable {
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

struct Tab: Codable, Hashable, Identifiable, Equatable {

    let id: UUID
    var title: String
    var url: URL
    var isActive: Bool

    var history: [NavigationEntry]
    var historyIndex: Int = 0

    var retainedWebView: WKWebView?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
        case isActive
        case history
        case historyIndex
    }

    init(
        title: String,
        url: URL,
        isActive: Bool,
    ) {
        self.id = UUID()
        self.title = title
        self.url = url
        self.isActive = isActive
        self.history = [
            .init(url: url, title: title, visitedAt: .now)
        ]
    }

    /// Decodes tab metadata without trying to restore a live `WKWebView`.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decode(URL.self, forKey: .url)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        history = try container.decode([NavigationEntry].self, forKey: .history)
        historyIndex = try container.decode(Int.self, forKey: .historyIndex)
        retainedWebView = nil
    }

    /// Encodes only stable tab metadata.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(url, forKey: .url)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(history, forKey: .history)
        try container.encode(historyIndex, forKey: .historyIndex)
    }

    static func == (lhs: Tab, rhs: Tab) -> Bool {
        lhs.id == rhs.id
        && lhs.title == rhs.title
        && lhs.url == rhs.url
        && lhs.isActive == rhs.isActive
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    struct NavigationEntry: Hashable, Codable {
        var url: URL
        var title: String?
        var visitedAt: Date
    }
}

struct Folder: Codable, Hashable, Identifiable, Equatable {
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


/// recursion removal
/// Pinned
/// ├── Tab A
/// ├── Folder X
/// │    ├── Tab B
/// │    └── Folder Y
/// │          └── Tab C
/// └── Tab D
///
/// removeTab:
/// imagine removing Tab C, It DOESN’T directly see Tab C.
/// we need to do a recursive search for this
///
/// removeFolder:
/// imagine removing Folder Y, it would do the same recursive
/// move down
///
/// This is the case for both Tabs and Folders
extension Array where Element == SidebarNode {

    mutating func removeTab(id: UUID) -> Tab? {
        for index in indices {
            switch self[index] {
            case .tab(let tab) where tab.id == id:
                remove(at: index)
                return tab

            case .folder(var folder):
                if let tab = folder.children.removeTab(id: id) {
                    self[index] = .folder(folder)
                    return tab
                }

            default:
                continue
            }
        }

        return nil
    }

    mutating func removeFolder(id: UUID) -> Folder? {
        for index in indices {
            switch self[index] {
            case .folder(let folder) where folder.id == id:
                remove(at: index)
                return folder

            case .folder(var folder):
                if let removed = folder.children.removeFolder(id: id) {
                    self[index] = .folder(folder)
                    return removed
                }

            case .tab:
                continue
            }
        }

        return nil
    }
}

extension Array where Element == SidebarNode {
    /// Recursively searches the sidebar tree for a tab matching the provided ID.
    ///
    /// Example Tree:
    ///     Pinned
    ///     ├── Tab A
    ///     ├── Folder X
    ///     │    ├── Tab B
    ///     │    └── Folder Y
    ///     │          └── Tab C
    ///     └── Tab D
    ///
    /// Example:
    ///     nodes.findTab(id: tabC.id)
    ///
    /// Search Flow:
    ///     - checks Tab A
    ///     - enters Folder X
    ///     - checks Tab B
    ///     - enters Folder Y
    ///     - finds Tab C
    ///
    /// This is recursive because folders can contain more `SidebarNode`s,
    /// including additional folders.
    func findTab(id: UUID) -> Tab? {
        for node in self {
            switch node {
            case .tab(let tab) where tab.id == id: return tab
            case .folder(let folder): if let t = folder.children.findTab(id: id) { return t }
            default: continue
            }
        }
        return nil
    }

    /// Flattens the entire sidebar tree into a single array of tabs.
    ///
    /// Example Tree:
    ///     Pinned
    ///     ├── Tab A
    ///     ├── Folder X
    ///     │    ├── Tab B
    ///     │    └── Folder Y
    ///     │          └── Tab C
    ///     └── Tab D
    ///
    /// Example:
    ///     nodes.allTabs()
    ///
    /// Returns:
    ///     [TabA, TabB, TabC, TabD]
    ///
    /// This recursively traverses folders and collects every tab found
    /// within the sidebar hierarchy.
    func allTabs() -> [Tab] {
        flatMap { node -> [Tab] in
            switch node {
            case .tab(let tab): return [tab]
            case .folder(let folder): return folder.children.allTabs()
            }
        }
    }
}
