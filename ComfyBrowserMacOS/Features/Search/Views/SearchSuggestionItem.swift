//
//  SearchSuggestionItem.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import AppKit
import SwiftUI

// MARK: - SearchSuggestionItem
/// Reusable AppKit collection item that hosts one SwiftUI suggestion row.
///
/// This mirrors `SidebarTabItem`: the AppKit item owns the reusable cell shell,
/// and `NSHostingView` renders the actual SwiftUI row content.
final class SearchSuggestionItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier("SearchSuggestionItem")
    
    private var hostingView: NSHostingView<SearchSuggestionRow>?
    private var suggestion: SearchSuggestion?
    private var onHighlight: ((SearchSuggestion.ID?) -> Void)?
    private var onSelect: ((SearchSuggestion) -> Void)?
    
    override func loadView() {
        let view = SearchSuggestionItemView()
        view.onTap = { [weak self] in
            guard let self, let suggestion else { return }
            onSelect?(suggestion)
        }
        view.onHover = { [weak self] isHovering in
            guard let self, let suggestion else { return }
            onHighlight?(isHovering ? suggestion.id : nil)
        }
        self.view = view
    }
    
    func configure(
        with suggestion: SearchSuggestion,
        isHighlighted: Bool,
        faviconService: FaviconService,
        onHighlight: @escaping (SearchSuggestion.ID?) -> Void,
        onSelect: @escaping (SearchSuggestion) -> Void
    ) {
        self.suggestion = suggestion
        self.onHighlight = onHighlight
        self.onSelect = onSelect
        setup(
            faviconService: faviconService,
            suggestion: suggestion,
            isHighlighted: isHighlighted
        )
    }
    
    private func setup(
        faviconService: FaviconService,
        suggestion: SearchSuggestion,
        isHighlighted: Bool
    ) {
        let row = SearchSuggestionRow(
            faviconService: faviconService,
            suggestion: suggestion,
            isHighlighted: isHighlighted
        )
        
        if let hostingView {
            hostingView.rootView = row
        } else {
            let hosting = NSHostingView(rootView: row)
            hosting.sizingOptions = []
            hosting.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(hosting)
            
            NSLayoutConstraint.activate([
                hosting.topAnchor.constraint(equalTo: view.topAnchor),
                hosting.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
            
            hostingView = hosting
        }
    }
}
