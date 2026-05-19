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
    var clickedTab: (Tab) -> Void
    var closeTab: (Tab) -> Void
    
    func makeCoordinator() -> SidebarCollectionCoordinator {
        SidebarCollectionCoordinator(
            faviconService: faviconService,
            sidebar: sidebar,
            closeTab: closeTab,
            clickedTab: clickedTab
        )
    }
    
    func makeNSView(context: Context) -> SidebarScrollView {
        /// set tabs very start
        context.coordinator.sidebar = sidebar

        let v = SidebarScrollView()
        
        /// set delegates
        v.collectionView.dataSource = context.coordinator
        v.collectionView.delegate = context.coordinator
        
        return v
    }
    
    func updateNSView(_ nsView: SidebarScrollView, context: Context) {
        context.coordinator.sidebar = sidebar
        nsView.collectionView.reloadData()
    }
}
