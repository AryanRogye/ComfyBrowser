//
//  GridViewModel.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/22/25.
//

import SwiftUI
import Combine

class GridViewModel: ObservableObject {
    
    private var canc = Set<AnyCancellable>()
    
    private let tabService: TabService
    
    @Published var tabs: [Tab] = []
    
    init(deps: GridViewDeps) {
        self.tabService = deps.tabService
        
        
        tabService.tabsPublisher.sink { tabs in
            self.tabs = tabs
        }
        .store(in: &canc)
    }
    
    public func createNewTab() {
        /// Dont Do Anything With the Instance, It Internally Also Holds it
        /// TODO: Remove return value once API Fixes
        _ = tabService.createTab()
    }
    
    public func getCurrentTabCount() -> Int {
        return tabs.count
    }
}
