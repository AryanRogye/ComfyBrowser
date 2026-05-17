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
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
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
