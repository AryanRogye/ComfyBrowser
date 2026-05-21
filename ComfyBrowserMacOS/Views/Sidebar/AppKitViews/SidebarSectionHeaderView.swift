//
//  SidebarSectionHeaderView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/18/26.
//

import AppKit
import SwiftUI

/// AppKit supplementary view used as a section title.
final class SidebarSectionHeaderView: NSView {
    static let identifier = NSUserInterfaceItemIdentifier("SidebarSectionHeaderView")
    
    private var hostingView: NSHostingView<SidebarHeaderRow>?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {

        let row = SidebarHeaderRow()

        /// Update
        if let hostingView {
            hostingView.rootView = row
        }
        /// Doesnt Exist
        else {
            let hosting = NSHostingView(rootView: row)

            hosting.sizingOptions = []
            hosting.translatesAutoresizingMaskIntoConstraints = false

            addSubview(hosting)

            NSLayoutConstraint.activate([
                hosting.topAnchor.constraint(equalTo: topAnchor),
                hosting.bottomAnchor.constraint(equalTo: bottomAnchor),
                hosting.leadingAnchor.constraint(equalTo: leadingAnchor),
                hosting.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])

            hostingView = hosting
        }
    }
}
