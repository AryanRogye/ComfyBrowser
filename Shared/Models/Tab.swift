//
//  Tab.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/23/25.
//

import Foundation
import WebKit

struct NavigationEntry: Hashable, Codable {
    var url: URL
    var title: String?
    var visitedAt: Date
}

struct Tab: Hashable, Identifiable, Equatable {

    let id: UUID
    var title: String
    var url: URL
    var isActive: Bool
    
    var history: [NavigationEntry] = []
    var historyIndex: Int = 0
    
    var retainedWebView: WKWebView?

    init(
        title: String,
        url: URL,
        isActive: Bool,
    ) {
        self.id = UUID()
        self.title = title
        self.url = url
        self.isActive = isActive
    }
    static func == (lhs: Tab, rhs: Tab) -> Bool {
        lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.url == rhs.url
            && lhs.isActive == rhs.isActive
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
