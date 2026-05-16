//
//  SearchSuggestionScrollView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import AppKit

// MARK: - SearchSuggestionScrollView
/// Scroll container for omnibar suggestion rows.
///
/// This mirrors `SidebarScrollView`, wrapping the collection view so suggestion
/// lists stay fast even when the history-backed result set grows.
class SearchSuggestionScrollView: NSScrollView {
    
    let collectionView = SearchSuggestionCollectionView()
    
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
        
        hasVerticalScroller = true
        hasHorizontalScroller = false
        
        drawsBackground = false
        backgroundColor = .clear
        
        autohidesScrollers = true
    }
}
