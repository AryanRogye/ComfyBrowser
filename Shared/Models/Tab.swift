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

struct Tab: Codable, Hashable, Identifiable, Equatable {

    let id: UUID
    var title: String
    var url: URL
    var isActive: Bool
    
    var history: [NavigationEntry]
    var historyIndex: Int = 0
    
    var retainedWebView: WKWebView?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
        case isActive
        case history
        case historyIndex
    }

    init(
        title: String,
        url: URL,
        isActive: Bool,
    ) {
        self.id = UUID()
        self.title = title
        self.url = url
        self.isActive = isActive
        self.history = [
            .init(url: url, title: title, visitedAt: .now)
        ]
    }
    
    /// Decodes tab metadata without trying to restore a live `WKWebView`.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decode(URL.self, forKey: .url)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        history = try container.decode([NavigationEntry].self, forKey: .history)
        historyIndex = try container.decode(Int.self, forKey: .historyIndex)
        retainedWebView = nil
    }
    
    /// Encodes only stable tab metadata.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(url, forKey: .url)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(history, forKey: .history)
        try container.encode(historyIndex, forKey: .historyIndex)
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
