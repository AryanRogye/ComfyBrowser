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
    static let navigateBack = LocalShortcuts.Name("NavigateBack", .init(
        modifier: [.command],
        keys: [.leftBracket]
    ))
    static let navigateForward = LocalShortcuts.Name("NavigateForward", .init(
        modifier: [.command],
        keys: [.rightBracket]
    ))
}
