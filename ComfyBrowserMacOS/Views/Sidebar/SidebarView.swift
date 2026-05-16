//
//  SidebarView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import AppKit
import SwiftUI

/// SwiftUI Entry into AppKit
struct SidebarView: NSViewRepresentable {
    
    @Bindable var faviconService: FaviconService
    @Binding var tabs : [Tab]
    var clickedTab: (Tab) -> Void
    var closeTab: (Tab) -> Void
    
    func makeCoordinator() -> SidebarCollectionCoordinator {
        SidebarCollectionCoordinator(
            faviconService: faviconService,
            tabs: tabs,
            closeTab: closeTab,
            clickedTab: clickedTab
        )
    }
    
    func makeNSView(context: Context) -> SidebarScrollView {
        /// set tabs very start
        context.coordinator.tabs = tabs
        
        let v = SidebarScrollView()
        
        /// set delegates
        v.collectionView.dataSource = context.coordinator
        v.collectionView.delegate = context.coordinator
        
        return v
    }
    
    func updateNSView(_ nsView: SidebarScrollView, context: Context) {
        context.coordinator.tabs = tabs
        nsView.collectionView.reloadData()
    }
}

// MARK: - SidebarScrollView
/// Allows Sidebar to be scrollable
/// This has to wrap the `SidebarCollectionView`
class SidebarScrollView: NSScrollView {
    
    let collectionView = SidebarCollectionView()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        documentView = collectionView
        
        hasVerticalScroller = true
        hasHorizontalScroller = false
        
        drawsBackground = false
        backgroundColor = .clear
        
        autohidesScrollers = true
    }
}

// MARK: - SidebarCollectionView
/// Collection "Container" for the items
class SidebarCollectionView: NSCollectionView {
    
    let distanceFromTop: CGFloat = 40
    let paddingAround: CGFloat = 4
    
    let cellWidth: CGFloat = 200
    let cellHeight: CGFloat = 36
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        isSelectable = true
        backgroundColors = [.clear]
        
        let layout = NSCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        /// set cell width/height
        layout.itemSize = NSSize(
            width: cellWidth,
            height: cellHeight
        )
        layout.minimumLineSpacing = 6
        
        /// Padding For Container
        layout.sectionInset = NSEdgeInsets(
            
            top: distanceFromTop,
            left: paddingAround,
            bottom: paddingAround,
            right: paddingAround
        )
        
        collectionViewLayout = layout
        
        register(
            SidebarTabItem.self,
            forItemWithIdentifier: SidebarTabItem.identifier
        )
    }
    
    override func layout() {
        super.layout()
        
        guard let flowLayout = collectionViewLayout as? NSCollectionViewFlowLayout else { return }
        
        let inset = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        
        flowLayout.itemSize.width = max(0, bounds.width - inset)
    }
}

// MARK: - SidebarCollectionCoordinator
/// Class is responsible for coordinating with the NSCollectionView to display
/// tabs
final class SidebarCollectionCoordinator: NSObject, NSCollectionViewDataSource, NSCollectionViewDelegate {
    var tabs: [Tab] = []
    var faviconService: FaviconService
    let closeTab: (Tab) -> Void
    let clickedTab: (Tab) -> Void
    
    init(
        faviconService: FaviconService,
        tabs: [Tab],
        closeTab: @escaping (Tab) -> Void,
        clickedTab: @escaping (Tab) -> Void
    ) {
        self.faviconService = faviconService
        self.tabs = tabs
        self.closeTab = closeTab
        self.clickedTab = clickedTab
    }
    
    /// Asks the data source for the number of items in the specified section
    func collectionView(
        _ collectionView: NSCollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        tabs.count
    }
    
    /// Asks the data source to provide an `NSCollectionViewItem` for the specified represented object.
    /// In our case this is the `SidebarTabItem`
    ///
    /// This method must always return a valid item instance.
    func collectionView(
        _ collectionView: NSCollectionView,
        itemForRepresentedObjectAt indexPath: IndexPath
    ) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: SidebarTabItem.identifier,
            for: indexPath
        ) as! SidebarTabItem
        
        item.configure(
            faviconService: faviconService,
            with: tabs[indexPath.item],
            closeTab: closeTab,
            clickedTab: clickedTab
        )
        return item
    }
}

// MARK: - SidebarTabItem
/// This shows the actual content for each `Tab`
final class SidebarTabItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier("SidebarTabItem")
    
    /// swiftui content in here
    private var hostingView: NSHostingView<SidebarRow>?
    
    private var vm: SidebarRowViewModel?
    
    override func loadView() {
        let v = SidebarItemView()
        v.onTap = { [weak self] in
            guard let self, let vm else { return }
            vm.clickedTab(vm.tab)
        }
        view = v
    }
    
    override var isSelected: Bool {
        didSet {
            vm?.isSelected = isSelected
        }
    }
    
    
    @objc private func handleClick() {
        if let vm {
            vm.clickedTab(vm.tab)
        }
    }
    
    func configure(
        faviconService: FaviconService,
        with tab: Tab,
        closeTab: @escaping (Tab) -> Void,
        clickedTab: @escaping (Tab) -> Void
    ) {
        if let vm {
            vm.tab = tab
            vm.isSelected = isSelected
            vm.faviconService = faviconService
            setup(with: vm)
        } else {
            let vm = SidebarRowViewModel(faviconService: faviconService, tab: tab, closeTab: closeTab, clickedTab: clickedTab)
            vm.isSelected = isSelected
            self.vm = vm
            setup(with: vm)
        }
    }
    
    private func setup(with vm: SidebarRowViewModel) {
        let row = SidebarRow(
            vm: vm,
        )
        
        /// Update
        if let hostingView {
            hostingView.rootView = row
        }
        /// Doesnt Exist
        else {
            let hosting = NSHostingView(rootView: row)
            /// Apple said disabling unnecessary size constraints on NSHostingView for performance
            /// if the view is always flexibly sized,
            /// since by default hosting views create constraints
            /// for minimum, intrinsic, and maximum size
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

class SidebarItemView: NSView {
    var onTap: (() -> Void)?
    
    override func mouseDown(with event: NSEvent) {
        onTap?()
    }
}
