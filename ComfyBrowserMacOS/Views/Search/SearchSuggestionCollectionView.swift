//
//  SearchSuggestionCollectionView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import AppKit

// MARK: - SearchSuggestionCollectionView
/// Fast AppKit collection view for omnibar suggestions.
///
/// The structure intentionally matches `SidebarCollectionView`: AppKit handles
/// row reuse and scrolling, while individual rows are hosted SwiftUI views.
class SearchSuggestionCollectionView: NSCollectionView {
    
    let distanceFromTop: CGFloat = 0
    let paddingAround: CGFloat = 10
    
    let cellWidth: CGFloat = 520
    let cellHeight: CGFloat = 46
    let lineSpacing: CGFloat = 2
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        isSelectable = false
        backgroundColors = [.clear]
        
        let layout = NSCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = NSSize(
            width: cellWidth,
            height: cellHeight
        )
        layout.minimumLineSpacing = lineSpacing
        
        layout.sectionInset = NSEdgeInsets(
            top: distanceFromTop,
            left: paddingAround,
            bottom: paddingAround,
            right: paddingAround
        )
        
        collectionViewLayout = layout
        
        register(
            SearchSuggestionItem.self,
            forItemWithIdentifier: SearchSuggestionItem.identifier
        )
    }
    
    override func layout() {
        super.layout()
        
        guard let flowLayout = collectionViewLayout as? NSCollectionViewFlowLayout else { return }
        
        let inset = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        flowLayout.itemSize.width = max(0, bounds.width - inset)
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }
    
    /// Returns the document height needed for every suggestion row.
    ///
    /// Example:
    ///     Three rows need top inset + bottom inset + three row heights + two
    ///     line spacings, so all rows live inside the clickable document view.
    func documentHeight(for itemCount: Int) -> CGFloat {
        guard itemCount > 0 else {
            return distanceFromTop + paddingAround
        }
        
        let rowHeights = CGFloat(itemCount) * cellHeight
        let spacings = CGFloat(max(0, itemCount - 1)) * lineSpacing
        
        return distanceFromTop + rowHeights + spacings + paddingAround
    }
}
