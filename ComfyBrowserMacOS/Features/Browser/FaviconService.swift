//
//  FaviconService.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/15/26.
//

import AppKit
import SwiftUI
import FaviconFinder

@Observable
final class FaviconService {
    
    var favicons: [String: NSImage] = [:]
    
    private var inFlight: Set<String> = []
    private var failedDomains: Set<String> = []
    
    func favicon(for url: URL?) -> NSImage? {
        guard let domain = normalizedDomain(from: url) else {
            return nil
        }
        
        if let cached = favicons[domain] {
            return cached
        }
        if failedDomains.contains(domain) {
            return nil
        }
        
        fetch(for: domain)
        return nil
    }
    
    private func fetch(for domain: String) {
        guard !inFlight.contains(domain) else { return }
        
        inFlight.insert(domain)
        
        Task {
            defer {
                Task { @MainActor in
                    self.inFlight.remove(domain)
                }
            }
            
            guard let siteURL = URL(string: "https://\(domain)") else {
                return
            }
            
            do {
                let favicon = try await FaviconFinder(url: siteURL)
                    .fetchFaviconURLs()
                    .download()
                    .largest()
                
                guard let image = favicon.image?.image else {
                    await MainActor.run {
                        _ = self.failedDomains.insert(domain)
                    }
                    return
                }
                
                await MainActor.run {
                    self.favicons[domain] = image
                }
                
            } catch {
                await MainActor.run {
                    _ = self.failedDomains.insert(domain)
                }
            }
        }
    }
    
    private func normalizedDomain(from url: URL?) -> String? {
        guard let host = url?.host else { return nil }
        
        let lower = host.lowercased()
        
        if lower.hasPrefix("www.") {
            return String(lower.dropFirst(4))
        }
        
        return lower
    }
}
