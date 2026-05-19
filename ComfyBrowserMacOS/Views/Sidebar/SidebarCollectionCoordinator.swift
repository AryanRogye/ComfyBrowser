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
    var sidebar = SidebarModel()
    var faviconService: FaviconService
    let closeTab: (Tab) -> Void
    let clickedTab: (Tab) -> Void
    
    init(
        faviconService: FaviconService,
        sidebar: SidebarModel,
        closeTab: @escaping (Tab) -> Void,
        clickedTab: @escaping (Tab) -> Void
    ) {
        self.faviconService = faviconService
        self.sidebar = sidebar
        self.closeTab = closeTab
        self.clickedTab = clickedTab
    }
    
    /// Asks the data source for the number of items in the specified section
    func collectionView(
        _ collectionView: NSCollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        sidebar.tabs.count
    }
    
    /// Asks the data source to provide an `NSCollectionViewItem` for the specified represented object.
    /// In our case this is the `SidebarTabItem`
    ///
    /// This method must always return a valid item instance.
    func collectionView(
        _ collectionView: NSCollectionView,
        itemForRepresentedObjectAt indexPath: IndexPath
    ) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: SidebarTabItem.identifier,
            for: indexPath
        ) as! SidebarTabItem

        let tabs : [Tab] = sidebar.regular.compactMap { node in
            switch node {
            case .tab(let tab):
                return tab
            case .folder(let folder):
                return nil
            }
        }

        item.configure(
            faviconService: faviconService,
            with: tabs[indexPath.item],
            closeTab: closeTab,
            clickedTab: clickedTab
        )
        return item
    }
}
