//
//  ComfyBrowserState.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/18/25.
//

import Foundation
import SwiftUI

enum SidebarState {
    case closed
    case open
    case floating
}

@Observable @MainActor
final class ComfyBrowserViewModel {
    
    let shortcuts = Shortcuts()
    
    var sidebarState: SidebarState = .open
    var isHoveringOverSidebarSide: Bool = false
    var shouldSidebarShowButton: Bool = false
    var isShowingNewTabSearch: Bool = false
    
    init() {
        shortcuts.register(
            onToggleSidebar: toggleSidebarOpenClose,
            onSearch: onSearch
        )
        observeHoveringOverSidebar()
    }
    
    func observeHoveringOverSidebar() {
        withObservationTracking {
            _ = isHoveringOverSidebarSide
        } onChange: { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                print("IsHovering: \(self.isHoveringOverSidebarSide)")
                if self.isHoveringOverSidebarSide && self.sidebarState == .closed {
                    self.sidebarState = .floating
                } else {
                    self.sidebarState = .closed
                }
                self.observeHoveringOverSidebar()
            }
        }
    }
    
    func onSearch() {
        isShowingNewTabSearch = true
    }
    
    func toggleSidebarOpenClose() {
        sidebarState = (sidebarState == .open) ? .closed : .open
    }
}
