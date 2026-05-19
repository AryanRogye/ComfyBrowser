//
//  SidebarFolderItem.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/19/26.
//

import AppKit
import SwiftUI

// MARK: - SidebarTabItem
/// This shows the actual content for each `Tab`
final class SidebarFolderItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier("SidebarFolderItem")

    /// swiftui content in here
    private var hostingView: NSHostingView<SidebarFolderRow>?

    override func loadView() {
        let v = SidebarItemView()
        v.onTap = { [weak self] in
            guard let self, let vm else { return }
            vm.clickedFolder(vm.folder)
        }
        v.onHover = { [weak self] hovering in
            guard let self, let vm else { return }
            vm.isHovered = hovering
        }
        view = v
    }

    override var isSelected: Bool {
        didSet {
            vm?.folder.isExpanded = isSelected
        }
    }

    private var vm: SidebarFolderRowViewModel?

    func configure(
        with folder: Folder,
        clickedFolder: @escaping (Folder) -> Void
    ) {
        if let vm {
            vm.folder = folder
            vm.isHovered = false
            setup(with: vm)
        } else {
            let vm = SidebarFolderRowViewModel(folder: folder, clickedFolder: clickedFolder)
            self.vm = vm
            vm.isHovered = false
            setup(with: vm)
        }
    }

    private func setup(with vm: SidebarFolderRowViewModel) {
        let row = SidebarFolderRow(
            vm: vm
        )

        /// Update
        if let hostingView {
            hostingView.rootView = row
        }
        /// Doesnt Exist
        else {
            let hosting = NSHostingView(rootView: row)
            /// Apple said disabling unnecessary size constraints on NSHostingView for performance
            /// if the view is always flexibly sized,
            /// since by default hosting views create constraints
            /// for minimum, intrinsic, and maximum size
            hosting.sizingOptions = []
            hosting.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(hosting)

            NSLayoutConstraint.activate([
                hosting.topAnchor.constraint(equalTo: view.topAnchor),
                hosting.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])

            hostingView = hosting
        }
    }
}
