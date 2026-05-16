//
//  LocalShortcuts+Defaults.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/15/26.
//

import LocalShortcuts

extension LocalShortcuts.Name {
    static let toggleSidebar = LocalShortcuts.Name("ToggleSidebar", .init(
        modifier: [.command],
        keys: [.s]
    ))
    static let search = LocalShortcuts.Name("Search", .init(
        modifier: [.command],
        keys: [.t]
    ))
}
