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
    private var itemCount: Int = 0
    
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
    
    override func layout() {
        super.layout()
        resizeDocumentView()
    }
    
    /// Reloads rows and resizes the document view to contain every item.
    ///
    /// Example:
    ///     If suggestions grow from one row to five rows, the collection view's
    ///     document height grows too, so all five rows are inside the clickable
    ///     AppKit hit-test area.
    func reloadData(itemCount: Int) {
        self.itemCount = itemCount
        resizeDocumentView()
        collectionView.reloadData()
    }
    
    private func resizeDocumentView() {
        let width = contentView.bounds.width
        let height = max(
            contentView.bounds.height,
            collectionView.documentHeight(for: itemCount)
        )
        
        collectionView.frame = NSRect(
            x: 0,
            y: 0,
            width: width,
            height: height
        )
        collectionView.collectionViewLayout?.invalidateLayout()
    }
}
