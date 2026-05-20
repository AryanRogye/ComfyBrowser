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

    var sidebar = SidebarModel()
    var selectedTab: Tab?
    var faviconService: FaviconService
    let closeTab: (Tab) -> Void
    let clickedTab: (Tab) -> Void
    var clickedFolder: (Folder) -> Void

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
        case 1: return sidebar.savedRows.count
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
        let (kind, node) = sidebar.item(at: indexPath)

        switch kind {
        case .pinned:
            guard case .tab(let tab) = node else { fatalError() }
            return pinnedItem(in: collectionView, at: indexPath, tab: tab)
        case .saved:
            return savedItem(in: collectionView, at: indexPath, node: node)
        case .regular:
            guard case .tab(let tab) = node else { fatalError() }
            return regularItem(in: collectionView, at: indexPath, tab: tab)
        }
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
            clickedTab: clickedTab
        )
        return item
    }

    func savedItem(
        in collectionView: NSCollectionView,
        at indexPath: IndexPath,
        node: SidebarNode
    ) -> NSCollectionViewItem {

        let displayNode = flattenedSavedNodes(sidebar.savedRows)[indexPath.item]

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
                clickedTab: clickedTab,
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
                clickedFolder: clickedFolder,
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
            clickedTab: clickedTab
        )
        return item
    }

    struct SidebarDisplayNode {
        let node: SidebarNode
        let depth: Int
    }

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
