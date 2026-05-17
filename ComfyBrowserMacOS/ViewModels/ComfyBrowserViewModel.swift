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

    private var lastNavigationTime = Date.distantPast
    private let navigationCooldown: TimeInterval = 0.2


    func onSearch() {
        isShowingNewTabSearch = true
    }
    
    func toggleSidebarOpenClose() {
        sidebarState = (sidebarState == .open) ? .closed : .open
    }
}

// MARK: - Navigation
extension ComfyBrowserViewModel {
    private func canNavigate() -> Bool {
        let now = Date()

        guard now.timeIntervalSince(lastNavigationTime) > navigationCooldown else {
            return false
        }

        lastNavigationTime = now
        return true
    }

    func navBack() {
        guard canNavigate() else { return }
        navigateBack?()
    }

    func navForward() {
        guard canNavigate() else { return }
        navigateForward?()
    }
}
