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
    private var onTap: (() -> Void)?
    
    private var vm : SearchSuggestionRowViewModel?
    
    override func loadView() {
        let view = SearchSuggestionItemView()
        view.onTap = { [weak self] in
            guard let self else { return }
            onTap?()
        }
        view.onHover = { [weak self] isHovering in
            guard let self else { return }
            
            vm?.isHovering = isHovering
        }
        self.view = view
    }
    
    func configure(
        with suggestion: SearchSuggestion,
        faviconService: FaviconService,
        onTap: @escaping () -> Void
    ) {
        self.onTap = onTap
        self.vm = SearchSuggestionRowViewModel(
            faviconService: faviconService,
            suggestion: suggestion
        )
        
        setup(
            faviconService: faviconService,
            suggestion: suggestion,
        )
    }
    
    private func setup(
        faviconService: FaviconService,
        suggestion: SearchSuggestion,
    ) {
        guard let vm else { return }
        let row = SearchSuggestionRow(
            vm: vm,
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
