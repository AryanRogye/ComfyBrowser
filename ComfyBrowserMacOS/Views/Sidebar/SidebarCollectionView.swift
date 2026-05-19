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
    let paddingAround: CGFloat = 4
    
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
        layout.headerReferenceSize = NSSize(
            width: cellWidth,
            height: 20
        )
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 0
        
        /// Padding For Container
        layout.sectionInset = NSEdgeInsets(
            
            top: 8,
            left: paddingAround,
            bottom: 14,
            right: paddingAround
        )
        
        collectionViewLayout = layout
        
        register(
            SidebarTabItem.self,
            forItemWithIdentifier: SidebarTabItem.identifier
        )
        register(
            SidebarFolderItem.self,
            forItemWithIdentifier: SidebarFolderItem.identifier
        )
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
