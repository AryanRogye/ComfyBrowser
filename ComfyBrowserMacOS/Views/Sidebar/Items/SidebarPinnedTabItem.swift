//
//  SidebarPinnedTabItem.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/20/26.
//

import AppKit
import SwiftUI

final class SidebarPinnedTabItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier("SidebarPinnedTabItem")

    private var hostingView: NSHostingView<SidebarPinnedRow>?

    private var vm: SidebarRowViewModel?

    override func loadView() {
        let v = SidebarItemView()
        v.onHover = { [weak self] hovering in
            guard let self, let vm else { return }
            vm.isHovered = hovering
        }
        view = v
    }

    override var isSelected: Bool {
        didSet {
            vm?.isSelected = isSelected
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        vm?.isHovered = false
    }

    func configure(
        faviconService: FaviconService,
        with tab: Tab,
        selectedTab: Tab?,
        closeTab: @escaping (Tab) -> Void,
        clickedRow: @escaping (NSEvent) -> Void,
    ) {
        if let vm {
            vm.tab = tab
            vm.isSelected = isSelected
            vm.faviconService = faviconService
            vm.isHovered = (view as? SidebarItemView)?.isMouseInside ?? false
            vm.selectedTab = selectedTab
            setup(with: vm)
        } else {
            let vm = SidebarRowViewModel(
                faviconService: faviconService,
                tab: tab,
                selectedTab: selectedTab,
                closeTab: closeTab
            )
            vm.isSelected = isSelected
            vm.isHovered = (view as? SidebarItemView)?.isMouseInside ?? false
            vm.selectedTab = selectedTab
            self.vm = vm
            setup(with: vm)
        }
    }

    private func setup(with vm: SidebarRowViewModel) {
        let row = SidebarPinnedRow(vm: vm)

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
