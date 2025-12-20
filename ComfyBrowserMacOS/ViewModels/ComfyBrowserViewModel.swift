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
    
    init() {
        shortcuts.register(
            onToggleSidebar: toggleSidebarOpenClose
        )
        observeHoveringOverSidebar()
    }
    func observeHoveringOverSidebar() {
        withObservationTracking {
            _ = isHoveringOverSidebarSide
        } onChange: {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                print("IsHovering: \(isHoveringOverSidebarSide)")
                if isHoveringOverSidebarSide && sidebarState == .closed {
                    sidebarState = .floating
                } else {
                    sidebarState = .closed
                }
                self.observeHoveringOverSidebar()
            }
        }
    }
    
    func toggleSidebarOpenClose() {
        sidebarState = (sidebarState == .open) ? .closed : .open
    }
}
