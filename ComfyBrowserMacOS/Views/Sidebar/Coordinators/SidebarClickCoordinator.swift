//
//  SidebarClickCoordinator.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/20/26.
//

import AppKit

/// Resolves AppKit mouse events into the sidebar row that should handle them.
final class SidebarClickCoordinator {
    private let itemLookup: (IndexPath) -> SidebarNode?
    private let clickedTab: (Tab) -> Void
    private let clickedFolder: (Folder) -> Void

    init(
        itemLookup: @escaping (IndexPath) -> SidebarNode?,
        clickedTab: @escaping (Tab) -> Void,
        clickedFolder: @escaping (Folder) -> Void
    ) {
        self.itemLookup = itemLookup
        self.clickedTab = clickedTab
        self.clickedFolder = clickedFolder
    }

    func clickHandler(for collectionView: NSCollectionView) -> (NSEvent) -> Void {
        { [weak self, weak collectionView] event in
            guard let self, let collectionView else { return }
            self.clickItem(in: collectionView, event: event)
        }
    }

}

extension SidebarClickCoordinator {
    /// Resolves clicks from the settled collection-view layout at the event
    /// location, avoiding stale callbacks from reused `NSCollectionViewItem`s.
    ///
    /// Example:
    ///     The user rapidly clicks a nested "Social Media" folder while
    ///     opening and closing it. Each click triggers `reloadData()`, so the
    ///     next mouse-down can arrive before AppKit has finished laying out the
    ///     collection view again. Settling layout first keeps that click mapped
    ///     to the nested folder row instead of a reused/root row.
    internal func clickItem(in collectionView: NSCollectionView, event: NSEvent) {
        // Rapid folder toggles call `reloadData()`, so AppKit can have a stale
        // layout when the next mouse-down arrives.
        collectionView.layoutSubtreeIfNeeded()

        let point = collectionView.convert(event.locationInWindow, from: nil)
        guard
            let indexPath = collectionView.indexPathForItem(at: point),
            let node = itemLookup(indexPath)
        else { return }

        switch node {
        case .tab(let tab):
            clickedTab(tab)
        case .folder(let folder):
            clickedFolder(folder)
        }
    }
}
