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
    var indentationLevel: Int

    init(
        folder: Folder,
        indentationLevel: Int
    ) {
        self.indentationLevel = indentationLevel
        self.folder = folder
    }
}
