//
//  ComfyBrowserViewModel.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/23/25.
//

import Combine
import Foundation
import SwiftUI

class ComfyBrowserViewModel: ObservableObject {
    
    var tabsService: TabService
    
    @Published var currentRequest : URLRequest? = nil
    
    /// Used For Search Bar
    @Published var search: String = ""
    
    @Published var requestedRequest: URLRequest? = nil
    
    @Published var shouldUseRequest: Bool = false
    
    var tabs: [Tab] = []
    @Binding var tab: Tab
    var cancellables = Set<AnyCancellable>()
    
    init(
        deps: BrowserViewDeps,
        tab: Binding<Tab>
    ) {
        tabsService = deps.tabService
        self._tab = tab
        
        tabsService.tabsPublisher.sink { tabs in
            self.tabs = tabs
        }
        .store(in: &cancellables)
        
        currentRequest = URLRequest(url: tab.url.wrappedValue)
    }
    
    
    /// MARK: - Searching Function
    public func performSearch() {
        guard !search.isEmpty else { return }
        
        if search.contains(".") {
            // Looks like a URL
            let formatted = search.hasPrefix("http") ? search : "https://\(search)"
            self.currentRequest = URLRequest(url: URL(string: formatted)!)
        } else {
            self.currentRequest = URLRequest(url: URL(string: "https://google.com/search?q=\(self.search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)
        }
    }
    
    public func getCurrentTabCount() -> Int {
        return self.tabs.count
    }
    
    public func addTab(with url: URL) {
        requestedRequest = URLRequest(url: url)
    }
    
    public func useRequestedRequest() {
        requestedRequest = nil
        
        let _ = self.tabsService.createTab(with: currentRequest ?? URLRequest(url: URL(string: "google.con")!))
        
    }
    public func clearRequestedRequest() {
        requestedRequest = nil
    }
}
