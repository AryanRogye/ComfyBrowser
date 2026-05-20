//
//  SidebarScrollView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import AppKit

// MARK: - SidebarScrollView
/// Allows Sidebar to be scrollable
/// This has to wrap the `SidebarCollectionView`
class SidebarScrollView: NSScrollView {
    
    let collectionView = SidebarCollectionView()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        documentView = collectionView
        
        hasVerticalScroller = false
        hasHorizontalScroller = false
        
        drawsBackground = false
        backgroundColor = .clear
    }
}

