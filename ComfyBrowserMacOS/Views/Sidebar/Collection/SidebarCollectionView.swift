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

    override func layout() {
        super.layout()

        guard let flowLayout = collectionViewLayout as? NSCollectionViewFlowLayout else { return }

        let inset = flowLayout.sectionInset.left + flowLayout.sectionInset.right

        flowLayout.itemSize.width = max(0, bounds.width - inset)
    }

    private func setup() {
        isSelectable = true
        backgroundColors = [.clear]
        
        let layout = makeLayout()
        collectionViewLayout = layout

        registerCollectionViewItems()
    }
}

// MARK: - Layout
extension SidebarCollectionView {
    internal func makeLayout() -> NSCollectionViewCompositionalLayout {
        NSCollectionViewCompositionalLayout { sectionIndex, environment in

            let itemLayout = self.determineLayoutForItems(with: sectionIndex)

            let sectionValue = SidebarSectionKind(rawValue: sectionIndex)
            let hidesHeader  = sectionValue == .pinned || sectionValue == .saved

            /// let items take up full width with cell height
            /// represents ONE rendered item/cell
            let itemSize = NSCollectionLayoutSize(
                widthDimension: itemLayout.width,
                heightDimension: itemLayout.height
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: sectionValue == .pinned ? 2 : 0,
                leading: sectionValue == .pinned ? 4 : 0,
                bottom: sectionValue == .pinned ? 2 : 0,
                trailing: sectionValue == .pinned ? 4 : 0
            )

            /// Group Height, this is cuz NSCollectionView is used for multiple
            /// rows and cols, but we only have 1 col
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(self.cellHeight)
            )

            let group = self.determineLayoutGroup(
                with: sectionIndex,
                item: item,
                size: groupSize
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 6
            section.contentInsets = NSDirectionalEdgeInsets(
                top: hidesHeader ? 10 : 0,
                leading: 0,
                bottom: 0,
                trailing: 0
            )

            if !hidesHeader {
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
}

// MARK: - Registering
extension SidebarCollectionView {
    internal func registerCollectionViewItems() {
        /// Registering For Pinned Tab
        register(
            SidebarPinnedTabItem.self,
            forItemWithIdentifier: SidebarPinnedTabItem.identifier
        )
        /// Registering For Regular Tab
        register(
            SidebarTabItem.self,
            forItemWithIdentifier: SidebarTabItem.identifier
        )
        /// Registering For Saved Tab
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
}

// MARK: - Helpers
extension SidebarCollectionView {

    typealias Layout = (width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension)

    internal func determineLayoutForItems(with sectionIndex: Int) -> Layout {

        let sectionValue = SidebarSectionKind(rawValue: sectionIndex)
        let isPinnedSection = sectionValue == .pinned

        if isPinnedSection {
            return Layout(width: .fractionalWidth(0.5), height: .absolute(self.cellHeight))
        } else {
            return Layout(width: .fractionalWidth(1.0), height: .absolute(self.cellHeight))
        }
    }

    internal func determineLayoutGroup(
        with sectionIndex: Int,
        item: NSCollectionLayoutItem,
        size: NSCollectionLayoutSize,
    ) -> NSCollectionLayoutGroup {

        let sectionValue = SidebarSectionKind(rawValue: sectionIndex)
        let isPinnedSection = sectionValue == .pinned

        if isPinnedSection {
            return NSCollectionLayoutGroup.horizontal(
                layoutSize: size,
                subitems: [item, item]
            )
        } else {
            return NSCollectionLayoutGroup.vertical(
                layoutSize: size,
                subitems: [item]
            )
        }
    }
}
