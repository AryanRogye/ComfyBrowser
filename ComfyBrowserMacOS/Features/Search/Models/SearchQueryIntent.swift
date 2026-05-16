//
//  SearchQueryIntent.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import Foundation

/// The resolved meaning of raw text typed into the omnibar.
///
/// This keeps "what the user typed" separate from "what the browser should do."
///
/// Examples:
///     "github.com" -> `.url(URL(string: "https://github.com")!)`
///     "swiftui layout" -> `.search(query: "swiftui layout", url: duckDuckGoURL)`
enum SearchQueryIntent: Equatable, Sendable {
    /// The input is blank or cannot produce a useful navigation action.
    case empty
    
    /// The input should be opened directly as a URL.
    case url(URL)
    
    /// The input should be sent to the selected search engine.
    case search(query: String, url: URL)
}
