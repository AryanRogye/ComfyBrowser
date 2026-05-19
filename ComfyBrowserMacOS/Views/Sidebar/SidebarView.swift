//
//  SidebarView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import AppKit
import SwiftUI

/// SwiftUI Entry into AppKit
struct SidebarView: NSViewRepresentable {
    
    @Bindable var faviconService: FaviconService
    @Binding var pinnedNodes: [SidebarNode]
    @Binding var tabs : [Tab]
    var clickedTab: (Tab) -> Void
    var closeTab: (Tab) -> Void
    var toggleFolder: (UUID) -> Void
    var movePinnedTab: (UUID, Int) -> Void
    var movePinnedFolder: (UUID, Int) -> Void
    var moveRegularTab: (UUID, Int) -> Void
    var moveTabIntoFolder: (UUID, UUID) -> Void
    var unpinTab: (UUID) -> Void
    
    func makeCoordinator() -> SidebarCollectionCoordinator {
        SidebarCollectionCoordinator(
            faviconService: faviconService,
            pinnedNodes: pinnedNodes,
            tabs: tabs,
            closeTab: closeTab,
            clickedTab: clickedTab,
            toggleFolder: toggleFolder,
            movePinnedTab: movePinnedTab,
            movePinnedFolder: movePinnedFolder,
            moveRegularTab: moveRegularTab,
            moveTabIntoFolder: moveTabIntoFolder,
            unpinTab: unpinTab
        )
    }
    
    func makeNSView(context: Context) -> SidebarScrollView {
        /// set sidebar data at the very start
        context.coordinator.pinnedNodes = pinnedNodes
        context.coordinator.tabs = tabs
        
        let v = SidebarScrollView()
        
        /// set delegates
        v.collectionView.dataSource = context.coordinator
        v.collectionView.delegate = context.coordinator
        v.collectionView.registerForDraggedTypes([
            SidebarCollectionCoordinator.dragType
        ])
        v.collectionView.setDraggingSourceOperationMask(
            .move,
            forLocal: true
        )
        
        return v
    }
    
    func updateNSView(_ nsView: SidebarScrollView, context: Context) {
        context.coordinator.pinnedNodes = pinnedNodes
        context.coordinator.tabs = tabs
        nsView.collectionView.reloadData()
    }
}
