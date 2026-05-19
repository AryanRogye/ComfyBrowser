//
//  Tab.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/23/25.
//

import Foundation
import WebKit


struct SidebarModel: Codable, Hashable, Sendable {
    var pinned: [SidebarNode] = []
    var folders: [SidebarNode] = []
    var regular: [SidebarNode] = []

    var tabs: [Tab] {
        pinned.allTabs() + folders.allTabs() + regular.allTabs()
    }

    var isRegularTabsEmpty: Bool {
        regular.isEmpty
    }

    func findTab(id: UUID) -> Tab? {
        pinned.findTab(id: id)
        ?? folders.findTab(id: id)
        ?? regular.findTab(id: id)
    }

    mutating func moveTab(
        id: UUID,
        to sectionKind: SidebarSectionKind,
        index: Int
    ) {
        guard let tab = removeTab(id: id) else { return }
        insert(.tab(tab), into: sectionKind, at: index)
    }

    mutating func insert(
        _ node: SidebarNode,
        into sectionKind: SidebarSectionKind,
        at index: Int
    ) {
        switch sectionKind {
        case .pinned:
            pinned.insertClamped(node, at: index)
        case .folders:
            folders.insertClamped(node, at: index)
        case .regular:
            regular.insertClamped(node, at: index)
        }
    }

    mutating func insert(
        _ node: SidebarNode,
        into sectionKind: SidebarSectionKind
    ) {
        /// clamps nicely
        insert(node, into: sectionKind, at: Int.max)
    }


    @discardableResult
    mutating func closeTab(id: UUID) -> Tab? {
        guard var tab = removeTab(id: id) else { return nil }

        tab.retainedWebView?.stopLoading()
        tab.retainedWebView = nil

        return tab
    }

    mutating func updateTab(
        id: UUID,
        _ update: (inout Tab) -> Void
    ) {
        if pinned.updateTab(id: id, update) { return }
        if folders.updateTab(id: id, update) { return }
        if regular.updateTab(id: id, update) { return }
    }

    mutating func removeTab(id: UUID) -> Tab? {
        pinned.removeTab(id: id)
        ?? folders.removeTab(id: id)
        ?? regular.removeTab(id: id)
    }

    mutating func removeFolder(id: UUID) -> Folder? {
        pinned.removeFolder(id: id)
        ?? folders.removeFolder(id: id)
        ?? regular.removeFolder(id: id)
    }
}

enum SidebarSectionKind: Codable, Hashable, Sendable {
    case pinned
    case folders
    case regular
}

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

struct Tab: Codable, Hashable, Identifiable, Equatable, Sendable {

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
//                tab.retainedWebView?.stopLoading()
//                tab.retainedWebView = nil
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

extension Array where Element == SidebarNode {
    mutating func insertClamped(_ node: SidebarNode, at index: Int) {
        let safeIndex = Swift.min(Swift.max(index, 0), count)
        insert(node, at: safeIndex)
    }
}

extension Array where Element == SidebarNode {
    mutating func updateTab(
        id: UUID,
        _ update: (inout Tab) -> Void
    ) -> Bool {
        for index in indices {
            switch self[index] {
            case .tab(var tab) where tab.id == id:
                update(&tab)
                self[index] = .tab(tab)
                return true

            case .folder(var folder):
                if folder.children.updateTab(id: id, update) {
                    self[index] = .folder(folder)
                    return true
                }

            default:
                continue
            }
        }

        return false
    }
}
