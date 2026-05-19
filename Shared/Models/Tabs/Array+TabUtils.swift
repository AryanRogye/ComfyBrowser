//
//  Array+TabUtils.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/19/26.
//

import Foundation

// MARK: - Remove Tab
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


// MARK: - Recursion Removal
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

// MARK: - Find Tab
extension Array where Element == Tab {
    func findTab(id: UUID) -> Tab? {
        for node in self {
            if node.id == id { return node }
        }

        return nil
    }
}

// MARK: - Node Recurssion
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

// MARK: - Insert Clamped
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

// MARK: - Update Tab
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

// MARK: - Update Folder/Tab
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
