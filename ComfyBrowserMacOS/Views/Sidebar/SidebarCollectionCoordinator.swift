//
//  SidebarCollectionCoordinator.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import AppKit

// MARK: - SidebarCollectionCoordinator
/// Class is responsible for coordinating with the NSCollectionView to display
/// tabs
final class SidebarCollectionCoordinator: NSObject, NSCollectionViewDataSource, NSCollectionViewDelegate {
    static let dragType = NSPasteboard.PasteboardType("com.comfybrowser.sidebar-item")
    
    var pinnedNodes: [SidebarNode] = []
    var tabs: [Tab] = []
    var faviconService: FaviconService
    let closeTab: (Tab) -> Void
    let clickedTab: (Tab) -> Void
    let toggleFolder: (UUID) -> Void
    let movePinnedTab: (UUID, Int) -> Void
    let movePinnedFolder: (UUID, Int) -> Void
    let moveRegularTab: (UUID, Int) -> Void
    let moveTabIntoFolder: (UUID, UUID) -> Void
    let unpinTab: (UUID) -> Void
    
    init(
        faviconService: FaviconService,
        pinnedNodes: [SidebarNode],
        tabs: [Tab],
        closeTab: @escaping (Tab) -> Void,
        clickedTab: @escaping (Tab) -> Void,
        toggleFolder: @escaping (UUID) -> Void,
        movePinnedTab: @escaping (UUID, Int) -> Void,
        movePinnedFolder: @escaping (UUID, Int) -> Void,
        moveRegularTab: @escaping (UUID, Int) -> Void,
        moveTabIntoFolder: @escaping (UUID, UUID) -> Void,
        unpinTab: @escaping (UUID) -> Void
    ) {
        self.faviconService = faviconService
        self.pinnedNodes = pinnedNodes
        self.tabs = tabs
        self.closeTab = closeTab
        self.clickedTab = clickedTab
        self.toggleFolder = toggleFolder
        self.movePinnedTab = movePinnedTab
        self.movePinnedFolder = movePinnedFolder
        self.moveRegularTab = moveRegularTab
        self.moveTabIntoFolder = moveTabIntoFolder
        self.unpinTab = unpinTab
    }
    
    /// Asks the data source to provide an `NSCollectionViewItem` for the specified represented object.
    /// In our case this is either a tab row or a folder row.
    ///
    /// This method must always return a valid item instance.
    func collectionView(
        _ collectionView: NSCollectionView,
        itemForRepresentedObjectAt indexPath: IndexPath
    ) -> NSCollectionViewItem {
        guard let sidebarSection = SidebarSection(rawValue: indexPath.section) else {
            return NSCollectionViewItem()
        }
        
        switch sidebarSection {
        case .pinnedTabs:
            return tabItem(
                in: collectionView,
                at: indexPath,
                tab: pinnedTabs[indexPath.item]
            )
        case .folders:
            return folderItem(
                in: collectionView,
                at: indexPath,
                row: folderRows[indexPath.item]
            )
        case .regularTabs:
            return tabItem(
                in: collectionView,
                at: indexPath,
                tab: regularTabs[indexPath.item]
            )
        }
    }
}

// MARK: - Section Item Count
extension SidebarCollectionCoordinator {
    /// Asks the data source for the number of items in the specified section
    func collectionView(
        _ collectionView: NSCollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let sidebarSection = SidebarSection(rawValue: section) else { return 0 }

        switch sidebarSection {
        case .pinnedTabs:
            return pinnedTabs.count
        case .folders:
            return folderRows.count
        case .regularTabs:
            return regularTabs.count
        }
    }
}

// MARK: - Section Title
extension SidebarCollectionCoordinator {
    /// Creates the small section title shown above each sidebar zone.
    func collectionView(
        _ collectionView: NSCollectionView,
        viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
        at indexPath: IndexPath
    ) -> NSView {
        guard
            kind == NSCollectionView.elementKindSectionHeader,
            let sidebarSection = SidebarSection(rawValue: indexPath.section)
        else {
            return NSView()
        }

        let header = collectionView.makeSupplementaryView(
            ofKind: kind,
            withIdentifier: SidebarSectionHeaderView.identifier,
            for: indexPath
        ) as! SidebarSectionHeaderView

        header.configure(title: sidebarSection.title)
        return header
    }

}

// MARK: - Dragging
extension SidebarCollectionCoordinator {
    /// Creates a local pasteboard payload for sidebar-only dragging.
    func collectionView(
        _ collectionView: NSCollectionView,
        pasteboardWriterForItemAt indexPath: IndexPath
    ) -> NSPasteboardWriting? {
        guard let dragItem = dragItem(at: indexPath) else { return nil }

        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setString(
            dragItem.pasteboardValue,
            forType: Self.dragType
        )
        return pasteboardItem
    }

    func collectionView(
        _ collectionView: NSCollectionView,
        canDragItemsAt indexPaths: Set<IndexPath>,
        with event: NSEvent
    ) -> Bool {
        indexPaths.contains { dragItem(at: $0) != nil }
    }
}

// MARK: - Dropping
extension SidebarCollectionCoordinator {
    /// Keeps drops local to the sidebar and normalizes section drop operations.
    func collectionView(
        _ collectionView: NSCollectionView,
        validateDrop draggingInfo: NSDraggingInfo,
        proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>,
        dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>
    ) -> NSDragOperation {
        guard draggedItem(from: draggingInfo) != nil else { return [] }
        guard let sidebarSection = SidebarSection(rawValue: proposedDropIndexPath.pointee.section) else {
            return []
        }

        switch sidebarSection {
        case .pinnedTabs, .regularTabs:
            proposedDropOperation.pointee = .before
        case .folders:
            break
        }

        return .move
    }

    /// Applies the requested sidebar move back through the SwiftUI-owned model.
    func collectionView(
        _ collectionView: NSCollectionView,
        acceptDrop draggingInfo: NSDraggingInfo,
        indexPath: IndexPath,
        dropOperation: NSCollectionView.DropOperation
    ) -> Bool {
        guard let dragItem = draggedItem(from: draggingInfo) else { return false }
        guard let sidebarSection = SidebarSection(rawValue: indexPath.section) else { return false }

        switch (dragItem.kind, sidebarSection) {
        case (.tab, .pinnedTabs):
            movePinnedTab(dragItem.id, indexPath.item)
        case (.tab, .regularTabs):
            unpinTab(dragItem.id)
            moveRegularTab(dragItem.id, indexPath.item)
        case (.tab, .folders):
            guard dropOperation == .on else { return false }
            guard case .folder(let folder) = folderRows[indexPath.item] else { return false }
            moveTabIntoFolder(dragItem.id, folder.id)
        case (.folder, .folders):
            guard dropOperation == .before else { return false }
            movePinnedFolder(dragItem.id, indexPath.item)
        case (.folder, .pinnedTabs), (.folder, .regularTabs):
            return false
        }

        return true
    }
}

// MARK: - Row Creation
private extension SidebarCollectionCoordinator {
    func tabItem(
        in collectionView: NSCollectionView,
        at indexPath: IndexPath,
        tab: Tab
    ) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: SidebarTabItem.identifier,
            for: indexPath
        ) as! SidebarTabItem

        item.configure(
            faviconService: faviconService,
            with: tab,
            closeTab: closeTab,
            clickedTab: clickedTab
        )
        return item
    }

    func folderItem(
        in collectionView: NSCollectionView,
        at indexPath: IndexPath,
        row: FolderRow
    ) -> NSCollectionViewItem {
        switch row {
        case .folder(let folder):
            let item = collectionView.makeItem(
                withIdentifier: SidebarFolderItem.identifier,
                for: indexPath
            ) as! SidebarFolderItem

            item.configure(
                with: folder,
                toggleFolder: toggleFolder
            )
            return item
        case .tab(let tab):
            return tabItem(
                in: collectionView,
                at: indexPath,
                tab: tab
            )
        }
    }
}

// MARK: - Sidebar Computed Properties
extension SidebarCollectionCoordinator {
    /// The sidebar has one collection view split into Arc-like zones.
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        SidebarSection.allCases.count
    }
}

// MARK: - Sidebar Zones
extension SidebarCollectionCoordinator {
    enum FolderRow {
        case folder(TabFolder)
        case tab(Tab)
    }
    
    enum DragKind: String {
        case tab
        case folder
    }
    
    struct DragItem {
        var kind: DragKind
        var id: UUID
        
        var pasteboardValue: String {
            "\(kind.rawValue):\(id.uuidString)"
        }
        
        init(kind: DragKind, id: UUID) {
            self.kind = kind
            self.id = id
        }
        
        init?(pasteboardValue: String) {
            let parts = pasteboardValue.split(separator: ":")
            guard parts.count == 2 else { return nil }
            guard let kind = DragKind(rawValue: String(parts[0])) else { return nil }
            guard let id = UUID(uuidString: String(parts[1])) else { return nil }
            
            self.kind = kind
            self.id = id
        }
    }
    
    var pinnedTabs: [Tab] {
        pinnedNodes.compactMap { node in
            guard case .tab(let tab) = node else { return nil }
            return tab
        }
    }
    
    var folderRows: [FolderRow] {
        folders.flatMap { folder in
            var rows: [FolderRow] = [.folder(folder)]
            
            if folder.isExpanded {
                rows += folder.children.compactMap { node in
                    guard case .tab(let tab) = node else { return nil }
                    return .tab(tab)
                }
            }
            
            return rows
        }
    }
    
    var regularTabs: [Tab] {
        let pinnedIDs = pinnedTabIDs(in: pinnedNodes)
        return tabs.filter { !pinnedIDs.contains($0.id) }
    }
    
    var folders: [TabFolder] {
        pinnedNodes.compactMap { node in
            guard case .folder(let folder) = node else { return nil }
            return folder
        }
    }
    
    /// Collects tab IDs hidden from the regular tab zone.
    func pinnedTabIDs(in nodes: [SidebarNode]) -> Set<UUID> {
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

// MARK: - Drag and Drop
private extension SidebarCollectionCoordinator {
    func dragItem(at indexPath: IndexPath) -> DragItem? {
        guard let sidebarSection = SidebarSection(rawValue: indexPath.section) else { return nil }
        
        switch sidebarSection {
        case .pinnedTabs:
            guard pinnedTabs.indices.contains(indexPath.item) else { return nil }
            return DragItem(
                kind: .tab,
                id: pinnedTabs[indexPath.item].id
            )
        case .folders:
            guard folderRows.indices.contains(indexPath.item) else { return nil }
            
            switch folderRows[indexPath.item] {
            case .folder(let folder):
                return DragItem(
                    kind: .folder,
                    id: folder.id
                )
            case .tab(let tab):
                return DragItem(
                    kind: .tab,
                    id: tab.id
                )
            }
        case .regularTabs:
            guard regularTabs.indices.contains(indexPath.item) else { return nil }
            return DragItem(
                kind: .tab,
                id: regularTabs[indexPath.item].id
            )
        }
    }
    
    func draggedItem(from draggingInfo: NSDraggingInfo) -> DragItem? {
        guard let value = draggingInfo.draggingPasteboard.string(forType: Self.dragType) else {
            return nil
        }
        
        return DragItem(pasteboardValue: value)
    }
}
