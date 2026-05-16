//
//  SidebarItemView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import AppKit

class SidebarItemView: NSView {
    var onTap: (() -> Void)?
    
    override func mouseDown(with event: NSEvent) {
        onTap?()
    }
}
