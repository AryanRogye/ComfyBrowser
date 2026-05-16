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
    var tabs: [Tab] = []
    var faviconService: FaviconService
    let closeTab: (Tab) -> Void
    let clickedTab: (Tab) -> Void
    
    init(
        faviconService: FaviconService,
        tabs: [Tab],
        closeTab: @escaping (Tab) -> Void,
        clickedTab: @escaping (Tab) -> Void
    ) {
        self.faviconService = faviconService
        self.tabs = tabs
        self.closeTab = closeTab
        self.clickedTab = clickedTab
    }
    
    /// Asks the data source for the number of items in the specified section
    func collectionView(
        _ collectionView: NSCollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        tabs.count
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
        
        item.configure(
            faviconService: faviconService,
            with: tabs[indexPath.item],
            closeTab: closeTab,
            clickedTab: clickedTab
        )
        return item
    }
}
