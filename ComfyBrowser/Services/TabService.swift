//
//  TabService.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/22/25.
//

import WebKit
import Combine

protocol TabService {
    var tabs: [Tab] { get }
    var tabsPublisher: AnyPublisher<[Tab], Never> { get }
    var webViews: [UUID: WKWebView] { get set }
    
    /// Function will Create a Tab and return it
    /// Function will also add to webViews, and tabs array
    func createTab() -> Tab
    func createTab(with request: URLRequest) -> Tab
    
    /// Function will create a temporary tab without adding to tabs array or webViews dictionary
    func createTempTab() -> Tab
    func createTempTab(with url: URL) -> Tab
    
    func addTab(_ tab: Tab)
    func getTabView(by id: UUID) -> WKWebView?
    func getTab(at index: Int) -> Tab?
    func getTabCount() -> Int
    func setTabResponse(for id: UUID, with response: URLResponse)
}
