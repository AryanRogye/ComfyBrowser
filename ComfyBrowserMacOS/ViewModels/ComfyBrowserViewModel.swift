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

    var navigateBack: (() -> Void)?
    var navigateForward: (() -> Void)?

    public func assign(navigateBack: @escaping () -> Void, navigateForward: @escaping () -> Void) {
        if self.navigateBack != nil && self.navigateForward != nil {
            return
        }
        self.navigateBack = navigateBack
        self.navigateForward = navigateForward
    }

    init() {
        shortcuts.register(
            onToggleSidebar: toggleSidebarOpenClose,
            onSearch: onSearch,
            navigateBack: navBack,
            navigateForward: navForward
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

    func navBack() {
        navigateBack?()
    }

    func navForward() {
        navigateForward?()
    }

    func onSearch() {
        isShowingNewTabSearch = true
    }
    
    func toggleSidebarOpenClose() {
        sidebarState = (sidebarState == .open) ? .closed : .open
    }
}
