//
//  SidebarCollectionView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import SwiftUI

// MARK: - SidebarCollectionView
/// Collection "Container" for the items
class SidebarCollectionView: NSCollectionView {
    
    let distanceFromTop: CGFloat = 40
    let leftInset: CGFloat = 0
    let rightInset: CGFloat = 0
    let bottomInset: CGFloat = 0


    let cellWidth: CGFloat = 200
    let cellHeight: CGFloat = 36
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        isSelectable = true
        backgroundColors = [.clear]
        
        let layout = NSCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        /// set cell width/height
        layout.itemSize = NSSize(
            width: cellWidth,
            height: cellHeight
        )
        layout.minimumLineSpacing = 6
        
        /// Padding For Container
        layout.sectionInset = NSEdgeInsets(
            
            top: distanceFromTop,
            left: leftInset,
            bottom: bottomInset,
            right: rightInset
        )
        
        collectionViewLayout = layout

        /// Registering For Regular Tab
        register(
            SidebarTabItem.self,
            forItemWithIdentifier: SidebarTabItem.identifier
        )
        register(
            SidebarFolderItem.self,
            forItemWithIdentifier: SidebarFolderItem.identifier
        )

        /// Register Section Views
        register(
            SidebarSectionHeaderView.self,
            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
            withIdentifier: SidebarSectionHeaderView.identifier
        )
    }
    
    override func layout() {
        super.layout()
        
        guard let flowLayout = collectionViewLayout as? NSCollectionViewFlowLayout else { return }
        
        let inset = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        
        flowLayout.itemSize.width = max(0, bounds.width - inset)
    }
}
