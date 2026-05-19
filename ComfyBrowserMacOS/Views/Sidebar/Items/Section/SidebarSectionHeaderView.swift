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
    
    private let label = NSTextField(labelWithString: "")
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func configure(title: String) {
        label.stringValue = title
    }
    
    private func setup() {
        wantsLayer = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .secondaryLabelColor
        
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -6),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
        ])
    }
}
