//
//  SidebarModel.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/19/26.
//

import Foundation
import AppKit
import WebKit

struct SidebarModel: Codable, Hashable, Sendable {
    //    var pinned: [Tab] = []
    //    var saved: [SidebarNode] = []
    //    var regular: [Tab] = []
    /// MOCK DELETE WHEN MERGING TO MAIN
    var pinned: [Tab] = [
        .init(title: "Reddit", url: URL(string: "https://reddit.com")!, isActive: false),
        .init(title: "GitHub", url: URL(string: "https://github.com")!, isActive: false),
        .init(title: "YouTube", url: URL(string: "https://youtube.com")!, isActive: false),
    ]
    var saved: [SidebarNode] = [
        .folder(.init(title: "My Folder", children: [
            .tab(.init(title: "X", url: URL(string: "https://x.com")!, isActive: false),),
            .folder(.init(title: "Social Media", children: [
                .tab(.init(title: "X", url: URL(string: "https://x.com")!, isActive: false),),
                .tab(.init(title: "Reddit", url: URL(string: "https://reddit.com")!, isActive: false),),
                .tab(.init(title: "Instagram", url: URL(string: "https://instagram.com")!, isActive: false),),
                .tab(.init(title: "Facebook", url: URL(string: "https://facebook.com")!, isActive: false),),
            ]))
        ]))
    ]
    var regular: [Tab] = [
        .init(title: "X", url: URL(string: "https://x.com")!, isActive: false),
        .init(title: "Hacker News", url: URL(string: "https://news.ycombinator.com")!, isActive: false),
        .init(title: "Linear", url: URL(string: "https://linear.app")!, isActive: false),
    ]


    var tabs: [Tab] {
        pinned + saved.allTabs() + regular
    }

    var isRegularTabsEmpty: Bool {
        regular.isEmpty
    }

    func findTab(id: UUID) -> Tab? {
        pinned.findTab(id: id)
        ?? saved.findTab(id: id)
        ?? regular.findTab(id: id)
    }

    func item(at indexPath: IndexPath) -> (SidebarSectionKind, SidebarNode) {
        switch indexPath.section {
        case 0: return (.pinned, .tab(pinned[indexPath.item]))
        case 1: return (.saved, savedRows[indexPath.item])
        case 2: return (.regular, .tab(regular[indexPath.item]))
        default: fatalError()
        }
    }

    var savedRows: [SidebarNode] {
        saved.visibleRows()
    }

    mutating func moveTab(
        id: UUID,
        to sectionKind: SidebarSectionKind,
        index: Int
    ) {
        guard let tab = removeTab(id: id) else { return }
        insert(.tab(tab), into: sectionKind, at: index)
    }

    mutating func insert(
        _ node: SidebarNode,
        into sectionKind: SidebarSectionKind,
        at index: Int
    ) {
        switch sectionKind {
        case .pinned:
            switch node {
            case .tab(let tab):
                pinned.insertClamped(tab, at: index)
            default:
                return
            }
        case .saved:
            saved.insertClamped(node, at: index)
        case .regular:
            switch node {
            case .tab(let tab):
                regular.insertClamped(tab, at: index)
            default:
                return
            }
        }
    }

    mutating func insert(
        _ node: SidebarNode,
        into sectionKind: SidebarSectionKind
    ) {
        /// clamps nicely
        insert(node, into: sectionKind, at: Int.max)
    }


    @discardableResult
    mutating func closeTab(id: UUID) -> Tab? {
        guard var tab = removeTab(id: id) else { return nil }

        tab.retainedWebView?.stopLoading()
        tab.retainedWebView = nil

        return tab
    }

    mutating func updateTab(
        id: UUID,
        _ update: (inout Tab) -> Void
    ) {
        if pinned.updateTab(id: id, update) { return }
        if saved.updateTab(id: id, update) { return }
        if regular.updateTab(id: id, update) { return }
    }

    mutating func removeTab(id: UUID) -> Tab? {
        pinned.removeTab(id: id)
        ?? saved.removeTab(id: id)
        ?? regular.removeTab(id: id)
    }

    mutating func removeFolder(id: UUID) -> Folder? {
        saved.removeFolder(id: id)
    }

    mutating func updateFolder(id: UUID, _ update: (inout Folder) -> Void) {
        if saved.updateFolder(id: id, update) { return }
    }
}
