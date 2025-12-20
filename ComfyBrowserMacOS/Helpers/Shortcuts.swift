//
//  Shortcuts.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/18/25.
//

import LocalShortcuts
import Foundation

extension LocalShortcuts.Name {
    static let toggleSidebar = LocalShortcuts.Name("ToggleSidebar", .init(
        modifier: [.command],
        keys: [.s]
    ))
}

@Observable @MainActor
class Shortcuts {
    
    init() {
        
    }
    
    func register(
        onToggleSidebar: @escaping () -> Void
    ) {
        /// Register what happens on keydown for toggling the sidebar
        LocalShortcuts.Name.onKeyDown(for: .toggleSidebar) {
            onToggleSidebar()
        }
    }
}
