//
//  SidebarFolderItem.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/18/26.
//

import AppKit
import SwiftUI

/// AppKit row shell for a pinned folder.
final class SidebarFolderItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier("SidebarFolderItem")
    
    private var hostingView: NSHostingView<SidebarFolderRow>?
    private var folder: TabFolder?
    private var toggleFolder: ((UUID) -> Void)?
    
    override func loadView() {
        let v = SidebarItemView()
        v.onTap = { [weak self] in
            guard let self, let folder else { return }
            toggleFolder?(folder.id)
        }
        view = v
    }
    
    func configure(
        with folder: TabFolder,
        toggleFolder: @escaping (UUID) -> Void
    ) {
        self.folder = folder
        self.toggleFolder = toggleFolder
        setup(with: folder)
    }
    
    private func setup(with folder: TabFolder) {
        let row = SidebarFolderRow(folder: folder)
        
        if let hostingView {
            hostingView.rootView = row
        } else {
            let hosting = NSHostingView(rootView: row)
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
