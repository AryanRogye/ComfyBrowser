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
final class SidebarCollectionCoordinator: NSObject, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
    var sidebar = SidebarModel()
    var selectedTab: Tab?
    var faviconService: FaviconService
    let closeTab: (Tab) -> Void
    let clickedTab: (Tab) -> Void
    var clickedFolder: (Folder) -> Void
    var moveTab: (UUID, SidebarSectionKind, Int) -> Void

    /// saved section can be filled with
    /// folders + tabs so this helps us manage it
    var savedDisplayRows: [SidebarDisplayNode] {
        flattenedSavedNodes(sidebar.saved)
    }

    private lazy var clickCoordinator = SidebarClickCoordinator(
        itemLookup: { [weak self] indexPath in
            self?.item(at: indexPath)?.1
        },
        clickedTab: clickedTab,
        clickedFolder: clickedFolder
    )

    private lazy var dragDropCoordinator = SidebarDragDropCoordinator(
        getItem: { [weak self] indexPath in
            self?.item(at: indexPath)
        }
    )

    init(
        faviconService: FaviconService,
        sidebar: SidebarModel,
        selectedTab: Tab?,
        closeTab: @escaping (Tab) -> Void,
        clickedTab: @escaping (Tab) -> Void,
        clickedFolder: @escaping (Folder) -> Void,
        moveTab: @escaping (UUID, SidebarSectionKind, Int) -> Void
    ) {
        self.faviconService = faviconService
        self.sidebar = sidebar
        self.selectedTab = selectedTab
        self.closeTab = closeTab
        self.clickedTab = clickedTab
        self.clickedFolder = clickedFolder
        self.moveTab = moveTab
    }
}

// MARK: - Main Coordinator
extension SidebarCollectionCoordinator {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        3
    }

    /// Asks the data source for the number of items in the specified section
    func collectionView(
        _ collectionView: NSCollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch section {
        case 0: return sidebar.pinned.count
        case 1: return savedDisplayRows.count
        case 2: return sidebar.regular.count
        default: return 0
        }
    }

    /// Asks the data source to provide an `NSCollectionViewItem` for the specified represented object.
    /// In our case this is the `SidebarTabItem`
    ///
    /// This method must always return a valid item instance.
    func collectionView(
        _ collectionView: NSCollectionView,
        itemForRepresentedObjectAt indexPath: IndexPath
    ) -> NSCollectionViewItem {
        guard let (kind, node) = item(at: indexPath) else {
            fatalError("Missing sidebar item at \(indexPath)")
        }

        switch kind {
        case .pinned:
            guard case .tab(let tab) = node else { fatalError() }
            return pinnedItem(in: collectionView, at: indexPath, tab: tab)
        case .saved:
            return savedItem(in: collectionView, at: indexPath)
        case .regular:
            guard case .tab(let tab) = node else { fatalError() }
            return regularItem(in: collectionView, at: indexPath, tab: tab)
        }
    }
}

// MARK: - Header Creation
extension SidebarCollectionCoordinator {
    func collectionView(
        _ collectionView: NSCollectionView,
        viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
        at indexPath: IndexPath
    ) -> NSView {
        guard kind == NSCollectionView.elementKindSectionHeader else {
            return NSView()
        }

        let header = collectionView.makeSupplementaryView(
            ofKind: kind,
            withIdentifier: SidebarSectionHeaderView.identifier,
            for: indexPath
        ) as! SidebarSectionHeaderView

        return header
    }
}

// MARK: - Row Creation
extension SidebarCollectionCoordinator {

    func pinnedItem(
        in collectionView: NSCollectionView,
        at indexPath: IndexPath,
        tab: Tab
    ) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: SidebarPinnedTabItem.identifier,
            for: indexPath
        ) as! SidebarPinnedTabItem

        item.configure(
            faviconService: faviconService,
            with: tab,
            selectedTab: selectedTab,
            closeTab: closeTab,
            clickedRow: clickCoordinator.clickHandler(for: collectionView)
        )
        return item
    }

    func savedItem(
        in collectionView: NSCollectionView,
        at indexPath: IndexPath
    ) -> NSCollectionViewItem {

        let displayNode = savedDisplayRows[indexPath.item]

        switch displayNode.node {
        case .tab(let tab):
            let item = collectionView.makeItem(
                withIdentifier: SidebarTabItem.identifier,
                for: indexPath
            ) as! SidebarTabItem

            item.configure(
                faviconService: faviconService,
                with: tab,
                selectedTab: selectedTab,
                closeTab: closeTab,
                clickedRow: clickCoordinator.clickHandler(for: collectionView),
                indentationLevel: displayNode.depth
            )

            return item

        case .folder(let folder):
            let item = collectionView.makeItem(
                withIdentifier: SidebarFolderItem.identifier,
                for: indexPath
            ) as! SidebarFolderItem

            item.configure(
                with: folder,
                clickedRow: clickCoordinator.clickHandler(for: collectionView),
                indentationLevel: displayNode.depth
            )

            return item
        }
    }


    func regularItem(
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
            selectedTab: selectedTab,
            closeTab: closeTab,
            clickedRow: clickCoordinator.clickHandler(for: collectionView)
        )
        return item
    }
}

// MARK: - Item Getters
extension SidebarCollectionCoordinator {

    struct SidebarDisplayNode {
        let node: SidebarNode
        let depth: Int
    }

    internal func item(at indexPath: IndexPath) -> (SidebarSectionKind, SidebarNode)? {
        switch indexPath.section {
        case 0:
            guard sidebar.pinned.indices.contains(indexPath.item) else { return nil }
            return (.pinned, .tab(sidebar.pinned[indexPath.item]))
        case 1:
            let rows = savedDisplayRows
            guard rows.indices.contains(indexPath.item) else { return nil }
            return (.saved, rows[indexPath.item].node)
        case 2:
            guard sidebar.regular.indices.contains(indexPath.item) else { return nil }
            return (.regular, .tab(sidebar.regular[indexPath.item]))
        default:
            return nil
        }
    }

    /// Recursive function to generate flattened nodes
    func flattenedSavedNodes(_ nodes: [SidebarNode], depth: Int = 0) -> [SidebarDisplayNode] {
        nodes.flatMap { node in
            switch node {
            case .tab:
                return [SidebarDisplayNode(node: node, depth: depth)]

            case .folder(let folder):
                var rows = [SidebarDisplayNode(node: node, depth: depth)]

                if folder.isExpanded {
                    rows += flattenedSavedNodes(folder.children, depth: depth + 1)
                }

                return rows
            }
        }
    }
}

// MARK: - Drag/Drop
extension SidebarCollectionCoordinator {
    /// Encodes a sidebar item into the drag pasteboard so AppKit knows what's being dragged.
    ///
    /// Called by AppKit for every item the user might drag. Returning `nil` makes that
    /// item non-draggable. Returning an `NSPasteboardItem` opts it in.
    ///
    /// The payload is a plain string encoded as `"kind:uuid"` — e.g:
    ///   `"tab:550e8400-e29b-41d4-a716-446655440000"`
    ///   `"folder:550e8400-e29b-41d4-a716-446655440000"`
    ///
    /// This string is later decoded in `acceptDrop` via `DragItem(pasteboardValue:)`
    /// to figure out what was actually dropped and where to move it.
    func collectionView(
        _ collectionView: NSCollectionView,
        pasteboardWriterForItemAt indexPath: IndexPath
    ) -> NSPasteboardWriting? {
        guard let dragItem = dragDropCoordinator.dragItem(at: indexPath) else {
            return nil
        }

        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setString(
            dragItem.pasteboardValue,
            forType: SidebarDragDropCoordinator.dragType
        )

        return pasteboardItem
    }

    /// Guards against dragging items that have no valid drag representation.
    ///
    /// a section header or empty placeholder would return `nil` from
    /// `dragItem(at:)` and would be blocked here.
    func collectionView(
        _ collectionView: NSCollectionView,
        canDragItemsAt indexPaths: Set<IndexPath>,
        with event: NSEvent
    ) -> Bool {
        let validDrag = indexPaths.contains { dragDropCoordinator.dragItem(at: $0) != nil }
        return validDrag
    }

    /// Validates and adjusts a proposed drop target before the user releases the drag.
    ///
    /// AppKit calls this continuously as the user hovers over the collection view,
    /// giving us a chance to either reject the drop or mutate where/how it lands.
    ///
    /// `proposedDropIndexPath` — where AppKit thinks the user wants to drop.
    ///   We can reassign this to redirect the drop to a different index.
    ///
    /// `proposedDropOperation` — either:
    ///   `.before` — drop lands BETWEEN items (shows a gap indicator)
    ///   `.on`     — drop lands ON TOP of an item (shows a highlight, used for folders)
    ///
    /// Example — user drags a tab and hovers over section 0 (pinned):
    ///   AppKit proposes indexPath [0, 2], operation .on
    ///   We force it to .before so it always inserts between pinned tabs, never onto one
    ///
    /// Example — user drags a tab and hovers over section 1 (saved):
    ///   AppKit proposes indexPath [1, 0], operation .on (hovering over a folder)
    ///   We leave it alone — .on is valid here because dropping onto a folder nests the tab
    ///
    /// Returning [] rejects the drop entirely and shows the no-drop cursor.
    /// Returning .move accepts it and shows the drag indicator.
    func collectionView(
        _ collectionView: NSCollectionView,
        validateDrop draggingInfo: NSDraggingInfo,
        proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>,
        dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>
    ) -> NSDragOperation {
        guard let draggedItem = dragDropCoordinator.draggedItem(from: draggingInfo) else {
            return []
        }

        switch unsafe proposedDropIndexPath.pointee.section {
            /// pinned, regular — always insert between items
        case 0, 2:
            unsafe proposedDropOperation.pointee = .before
            /// Saved Block Allow both before and on dropping onto a folder
        case 1:
            break
        default:
            return []
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
        print("DROP accept indexPath=\(indexPath) operation=\(dropOperation)")

        guard let draggedItem = dragDropCoordinator.draggedItem(from: draggingInfo) else {
            print("DROP accept rejected: no dragged item")
            return false
        }

        print("DROP accept draggedItem=\(draggedItem.pasteboardValue)")

        switch (draggedItem.kind, indexPath.section) {
        case (.tab, SidebarSectionKind.pinned.rawValue):   // tab → pinned
            moveTab(draggedItem.id, .pinned, indexPath.item)
            return true
        case (.tab, SidebarSectionKind.regular.rawValue):   // tab → regular
            moveTab(draggedItem.id, .regular, indexPath.item)
            return true
        case (.tab, SidebarSectionKind.saved.rawValue):   // tab → saved (onto a folder)
            guard dropOperation == .on else {
                print("DROP accept moving tab to saved index=\(indexPath.item)")
                moveTab(draggedItem.id, .saved, indexPath.item)
                return true
            }
            /// dropping tab on top of the folde
            // moveTabIntoFolder — TODO
            return false  // TODO
        case (.folder, SidebarSectionKind.saved.rawValue): // folder reorder within saved
            guard dropOperation == .before else {
                print("DROP accept rejected: folder drop operation=\(dropOperation)")
                return false
            }
            print("DROP accept rejected: folder reorder TODO")
            // moveSavedFolder(draggedItem.id, indexPath.item)
            return false  // TODO
            /// Folders CANT go in pinned/regular
        case (.folder, SidebarSectionKind.pinned.rawValue), (.folder, SidebarSectionKind.regular.rawValue):
            return false
            /// Drop Accept Rejected: unsupported dragged kind/section
        default:
            return false
        }
    }
}
