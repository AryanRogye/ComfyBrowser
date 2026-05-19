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
    @Binding var sidebar : SidebarModel
    @Binding var selectedTab: Tab?
    var clickedTab: (Tab) -> Void
    var closeTab: (Tab) -> Void
    var clickedFolder: (Folder) -> Void
}

// MARK: - Make Coordinator
extension SidebarView {
    /// Assigns what happens when we:
    ///
    /// 1. close a tab
    /// 2. click a tab
    ///
    /// Set only once at creation
    func makeCoordinator() -> SidebarCollectionCoordinator {
        SidebarCollectionCoordinator(
            faviconService: faviconService,
            sidebar: sidebar,
            selectedTab: selectedTab,
            closeTab: closeTab,
            clickedTab: clickedTab,
            clickedFolder: clickedFolder
        )
    }
}

// MARK: - Make View
extension SidebarView {
    func makeNSView(context: Context) -> SidebarScrollView {
        /// set tabs very start
        context.coordinator.sidebar = sidebar
        context.coordinator.selectedTab = selectedTab

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
}

// MARK: - Update View
extension SidebarView {
    func updateNSView(_ nsView: SidebarScrollView, context: Context) {
        context.coordinator.sidebar = sidebar
        context.coordinator.selectedTab = selectedTab
        nsView.collectionView.reloadData()
    }
}
