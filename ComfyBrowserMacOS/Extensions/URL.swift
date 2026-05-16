//
//  URL.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import Foundation

extension URL {
    func extractSearchQuery() -> String? {
        let url = self
        guard
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let raw = comps.queryItems?.first(where: { $0.name == "q" })?.value
        else { return nil }
        
        // Google uses "+" for spaces
        return raw.replacingOccurrences(of: "+", with: " ")
    }
}
