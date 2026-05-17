//
//  SearchSuggestionItemView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import AppKit

/// AppKit shell view for a suggestion item.
///
/// The view captures click and hover events for the collection item, while the
/// visible row remains SwiftUI inside `SearchSuggestionRow`.
final class SearchSuggestionItemView: NSView {
    
    var onTap: (() -> Void)?
    var onHover: ((Bool) -> Void)?
    
    private var trackingArea: NSTrackingArea?
    
    /// Makes the whole collection item behave like one clickable row.
    ///
    /// Without this, the embedded SwiftUI `NSHostingView` can become the hit
    /// target, which makes `mouseDown` on this shell feel inconsistent.
    ///
    /// Example:
    ///     Clicking the row title or favicon still lands on this item view.
    override func hitTest(_ point: NSPoint) -> NSView? {
        bounds.contains(point) ? self : nil
    }
    
    override func mouseDown(with event: NSEvent) {
        onTap?()
    }
    
    override func mouseEntered(with event: NSEvent) {
        onHover?(true)
    }
    
    override func mouseExited(with event: NSEvent) {
        onHover?(false)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let trackingArea {
            removeTrackingArea(trackingArea)
        }
        
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect],
            owner: self
        )
        
        addTrackingArea(area)
        trackingArea = area
    }
}
