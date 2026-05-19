//
//  SidebarFolderRowViewModel.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/19/26.
//

import SwiftUI

@Observable
@MainActor
final class SidebarFolderRowViewModel {
    var folder: Folder
    var isHovered: Bool = false
    var clickedFolder: (Folder) -> Void

    init(
        folder: Folder,
        clickedFolder: @escaping (Folder) -> Void
    ) {
        self.folder = folder
        self.clickedFolder = clickedFolder
    }
}
