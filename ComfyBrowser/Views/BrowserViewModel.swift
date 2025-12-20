//
//  BrowserViewModel.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/22/25.
//

import Combine
import Foundation
import WebKit

protocol BrowserDeps {
    var tabService : TabService { get }
}

//@MainActor
//class BrowserViewModel: ObservableObject {
//    
//    @Published var search: String = ""
//    /// We do ! because we always initialize it in init()
//    @Published var currentRequest: URLRequest?
//    
//    @Published var newTabResponse: URLResponse? = nil
//    @Published var shouldShowNewTab: Bool = false
//    
//    var tabService: TabService
//    
//    @Published var currentTab: Tab?
//    
//    var tabToAdd : Tab?
//    
//    init(deps: BrowserDeps) {
//        tabService = deps.tabService
//        //        loadDefault()
//    }
//    
//    public func getCurrentWebView() -> WKWebView? {
//        guard let currentTab = currentTab else { return nil }
//        return tabService.getTabView(by: currentTab.id)
//    }
//    /// Function to get current Tab Count
//    public func getCurrentTabCount() -> Int {
//        return tabService.getTabCount()
//    }
//    /// Function to create a new tab with a URLResponse
//    public func createNewTab(with response: URLResponse) {
//        tabToAdd = tabService.createTempTab()
//    }
//    public func createNewTab() {
//        currentTab = tabService.createTab()
//    }
//    public func setCurrentTab(index: Int)  {
//        currentTab = tabService.getTab(at: index)
//        currentRequest = URLRequest(url: currentTab?.url ?? URL(string: "https://google.com/")!)
//    }
//    
//    // MARK: - Perform Search
//    public func performSearch() {
//        guard !search.isEmpty else { return }
//        
//        if search.contains(".") {
//            // Looks like a URL
//            let formatted = search.hasPrefix("http") ? search : "https://\(search)"
//            self.currentRequest = URLRequest(url: URL(string: formatted)!)
//        } else {
//            self.currentRequest = URLRequest(url: URL(string: "https://google.com/search?q=\(self.search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)
//        }
//    }
//    
//    //    // MARK: - Load Defaults At Start
//    //    public func loadDefault() {
//    //        self.currentRequest = URLRequest(url: URL(string: "https://google.com/")!)
//    //    }
//    
//    
//    
//    
//    
//    // MARK: - Tab Changing Handling
//    public func clearTabResponse() {
//        self.newTabResponse = nil
//    }
//    public func goToTabResponse() {
//        self.currentRequest = URLRequest(url: self.newTabResponse?.url ?? URL(string: "https://google.com/")!)
//        self.newTabResponse = nil
//        shouldShowNewTab = true
//        
//        guard let tab = tabToAdd, let response = newTabResponse else { return }
//        
//        print("Added new Tab")
//        tabService.addTab(tab)
//        tabService.setTabResponse(for: tab.id, with: response)
//    }
//}
