//
//  SidebarItemView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import AppKit

class SidebarItemView: NSView {
    var onTap: ((NSEvent) -> Void)?
    var onHover: ((Bool) -> Void)?

    var isMouseInside: Bool {
        guard let window else { return false }
        let point = convert(window.mouseLocationOutsideOfEventStream, from: nil)
        return bounds.contains(point)
    }

    override func mouseDown(with event: NSEvent) {
        onTap?(event)
    }

    override func mouseEntered(with event: NSEvent) {
        onHover?(true)
    }
    override func mouseExited(with event: NSEvent) {
        onHover?(false)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach { removeTrackingArea($0) }
        addTrackingArea(NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect],
            owner: self,
            userInfo: nil
        ))
    }
}
