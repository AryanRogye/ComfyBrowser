//
//  SidebarRowViewModel.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import SwiftUI

/// Keeping this in a VM lets me NOT redraw the entire sidebarRow
/// for example when toggling isSelected
@Observable
final class SidebarRowViewModel {
    var faviconService: FaviconService
    var tab: Tab
    var isSelected = false
    var closeTab: (Tab) -> Void
    var clickedTab: (Tab) -> Void

    init(
        faviconService: FaviconService,
        tab: Tab,
        closeTab: @escaping (Tab) -> Void,
        clickedTab: @escaping (Tab) -> Void
    ) {
        self.faviconService = faviconService
        self.tab = tab
        self.closeTab = closeTab
        self.clickedTab = clickedTab
    }
}
