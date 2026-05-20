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

    static let dragType = NSPasteboard.PasteboardType("com.comfybrowser.sidebar-item")

    var sidebar = SidebarModel()
    var selectedTab: Tab?
    var faviconService: FaviconService
    let closeTab: (Tab) -> Void
    let clickedTab: (Tab) -> Void
    var clickedFolder: (Folder) -> Void

    /// saved section can be filled with
    /// folders + tabs so this helps us manage it
    var savedDisplayRows: [SidebarDisplayNode] {
        flattenedSavedNodes(sidebar.saved)
    }

    var hiddenSections: Set<Int> = [0]

    private lazy var clickCoordinator = SidebarClickCoordinator(
        itemLookup: { [weak self] indexPath in
            self?.item(at: indexPath)?.1
        },
        clickedTab: clickedTab,
        clickedFolder: clickedFolder
    )

    init(
        faviconService: FaviconService,
        sidebar: SidebarModel,
        selectedTab: Tab?,
        closeTab: @escaping (Tab) -> Void,
        clickedTab: @escaping (Tab) -> Void,
        clickedFolder: @escaping (Folder) -> Void
    ) {
        self.faviconService = faviconService
        self.sidebar = sidebar
        self.selectedTab = selectedTab
        self.closeTab = closeTab
        self.clickedTab = clickedTab
        self.clickedFolder = clickedFolder
    }

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
        let header = collectionView.makeSupplementaryView(
            ofKind: kind,
            withIdentifier: SidebarSectionHeaderView.identifier,
            for: indexPath
        ) as! SidebarSectionHeaderView

        return header
    }

    func collectionView(
        _ collectionView: NSCollectionView,
        layout collectionViewLayout: NSCollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> NSSize {
        hiddenSections.contains(section) ? .zero : NSSize(width: collectionView.bounds.width, height: 28)
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        // Set left and right insets to 0
        return NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
