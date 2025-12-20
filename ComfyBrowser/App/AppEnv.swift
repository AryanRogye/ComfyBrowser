//
//  AppEnv.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/23/25.
//

class AppEnv: BrowserDeps, GridViewDeps, BrowserViewDeps {
    @MainActor
    var tabService: any TabService = TabManager()
}
