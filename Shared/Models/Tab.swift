//
//  Tab.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/23/25.
//

import Foundation
import WebKit


struct SidebarModel: Codable, Hashable, Sendable {
    //    var pinned: [Tab] = []
    //    var saved: [SidebarNode] = []
    //    var regular: [Tab] = []
    /// MOCK DELETE WHEN MERGING TO MAIN
    var pinned: [Tab] = [
        .init(title: "Reddit", url: URL(string: "https://reddit.com")!, isActive: false),
        .init(title: "GitHub", url: URL(string: "https://github.com")!, isActive: false),
        .init(title: "YouTube", url: URL(string: "https://youtube.com")!, isActive: false),
    ]
    var saved: [SidebarNode] = [
        .folder(.init(title: "My Folder", children: [
            .tab(.init(title: "X", url: URL(string: "https://x.com")!, isActive: false),),
            .folder(.init(title: "Social Media", children: [
                .tab(.init(title: "X", url: URL(string: "https://x.com")!, isActive: false),),
                .tab(.init(title: "Reddit", url: URL(string: "https://reddit.com")!, isActive: false),),
                .tab(.init(title: "Instagram", url: URL(string: "https://instagram.com")!, isActive: false),),
                .tab(.init(title: "Facebook", url: URL(string: "https://facebook.com")!, isActive: false),),
            ]))
        ]))
    ]
    var regular: [Tab] = [
        .init(title: "X", url: URL(string: "https://x.com")!, isActive: false),
        .init(title: "Hacker News", url: URL(string: "https://news.ycombinator.com")!, isActive: false),
        .init(title: "Linear", url: URL(string: "https://linear.app")!, isActive: false),
    ]


    var tabs: [Tab] {
        pinned + saved.allTabs() + regular
    }

    var isRegularTabsEmpty: Bool {
        regular.isEmpty
    }

    func findTab(id: UUID) -> Tab? {
        pinned.findTab(id: id)
        ?? saved.findTab(id: id)
        ?? regular.findTab(id: id)
    }

    func item(at indexPath: IndexPath) -> (SidebarSectionKind, SidebarNode) {
        switch indexPath.section {
        case 0: return (.pinned, .tab(pinned[indexPath.item]))
        case 1: return (.saved, savedRows[indexPath.item])
        case 2: return (.regular, .tab(regular[indexPath.item]))
        default: fatalError()
        }
    }

    var savedRows: [SidebarNode] {
        saved.visibleRows()
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
            switch node {
            case .tab(let tab):
                pinned.insertClamped(tab, at: index)
            default:
                return
            }
        case .saved:
            saved.insertClamped(node, at: index)
        case .regular:
            switch node {
            case .tab(let tab):
                regular.insertClamped(tab, at: index)
            default:
                return
            }
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
        if saved.updateTab(id: id, update) { return }
        if regular.updateTab(id: id, update) { return }
    }

    mutating func removeTab(id: UUID) -> Tab? {
        pinned.removeTab(id: id)
        ?? saved.removeTab(id: id)
        ?? regular.removeTab(id: id)
    }

    mutating func removeFolder(id: UUID) -> Folder? {
        saved.removeFolder(id: id)
    }

    mutating func updateFolder(id: UUID, _ update: (inout Folder) -> Void) {
        if saved.updateFolder(id: id, update) { return }
    }
}

enum SidebarSectionKind: Codable, Hashable, Sendable {
    case pinned
    case saved
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


extension Array where Element == Tab {
    mutating func removeTab(id: UUID) -> Tab? {
        for index in indices {
            let tab = self[index]
            if tab.id == id {
                _ = remove(at: index)
                return tab
            }
        }

        return nil
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

extension Array where Element == Tab {
    func findTab(id: UUID) -> Tab? {
        for node in self {
            if node.id == id { return node }
        }

        return nil
    }
}
extension Array where Element == SidebarNode {
    /// Returns the rows currently visible in the sidebar tree.
    ///
    /// Example:
    ///     An expanded folder containing Tab A returns [Folder, Tab A].
    ///     A collapsed folder returns [Folder].
    func visibleRows() -> [SidebarNode] {
        flatMap { node -> [SidebarNode] in
            switch node {
            case .tab:
                return [node]
            case .folder(let folder):
                var rows: [SidebarNode] = [node]
                if folder.isExpanded {
                    rows += folder.children.visibleRows()
                }
                return rows
            }
        }
    }

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

extension Array where Element == Tab {
    mutating func insertClamped(_ tab: Tab, at index: Int) {
        let safeIndex = Swift.min(Swift.max(index, 0), count)
        insert(tab, at: safeIndex)
    }
}

extension Array where Element == SidebarNode {
    mutating func insertClamped(_ node: SidebarNode, at index: Int) {
        let safeIndex = Swift.min(Swift.max(index, 0), count)
        insert(node, at: safeIndex)
    }
}

extension Array where Element == Tab {
    mutating func updateTab(
        id: UUID,
        _ update: (inout Tab) -> Void
    ) -> Bool {
        for index in indices {
            var tab = self[index]
            if tab.id == id {
                update(&tab)
                self[index] = tab
                return true
            }
        }

        return false
    }
}

extension Array where Element == SidebarNode {
    mutating func updateFolder(
        id: UUID,
        _ update: (inout Folder) -> Void
    ) -> Bool {
        for index in indices {
            switch self[index] {
            case .tab(var tab) where tab.id == id:
                return false

            case .folder(var folder):
                if folder.id == id {
                    update(&folder)
                    self[index] = .folder(folder)
                    return true  // ← you're missing this
                }
                /// keep going deeper
                else {
                    if folder.children.updateFolder(id: id, update) {
                        self[index] = .folder(folder)
                        return true
                    }
                }

            default:
                continue
            }
        }

        return false
    }

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
