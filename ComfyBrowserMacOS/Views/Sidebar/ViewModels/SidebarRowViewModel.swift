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
    var selectedTab: Tab?
    var isSelected = false
    var isHovered: Bool = false

    var indentationLevel: Int?

    var closeTab: (Tab) -> Void

    init(
        faviconService: FaviconService,
        tab: Tab,
        selectedTab: Tab?,
        closeTab: @escaping (Tab) -> Void
    ) {
        self.faviconService = faviconService
        self.tab = tab
        self.selectedTab = selectedTab
        self.closeTab = closeTab
    }
}
