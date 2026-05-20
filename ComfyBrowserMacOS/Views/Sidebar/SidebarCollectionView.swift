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

    let headerHeight: CGFloat = 28

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
        
        let layout = makeLayout()
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

    private func makeLayout() -> NSCollectionViewCompositionalLayout {
        NSCollectionViewCompositionalLayout { sectionIndex, environment in

            /// let items take up full width with cell height
            /// represents ONE rendered item/cell
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(self.cellHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            /// Group Height, this is cuz NSCollectionView is used for multiple
            /// rows and cols, but we only have 1 col
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(self.cellHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )


            /// our sidebar has multiple sections
            ///
            /// pinned
            /// saved
            /// regular

            let pinnedHeader = sectionIndex == 0

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 6
            section.contentInsets = NSDirectionalEdgeInsets(
                top: pinnedHeader ? 10 : 0,
                leading: 0,
                bottom: 0,
                trailing: 0
            )

            if !pinnedHeader {
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(self.headerHeight)
                )

                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: NSCollectionView.elementKindSectionHeader,
                    alignment: .top
                )

                section.boundarySupplementaryItems = [header]
            }

            return section
        }
    }

    override func layout() {
        super.layout()
        
        guard let flowLayout = collectionViewLayout as? NSCollectionViewFlowLayout else { return }
        
        let inset = flowLayout.sectionInset.left + flowLayout.sectionInset.right

        flowLayout.itemSize.width = max(0, bounds.width - inset)
    }
}
