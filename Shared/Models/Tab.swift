//
//  Tab.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/23/25.
//

import Foundation

final class Tab: Identifiable, Equatable {
    
    let id: UUID
    var title: String
    var url: URL
    var isActive: Bool
    
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
    static func == (lhs: Tab, rhs: Tab) -> Bool { lhs.id == rhs.id }
}
